import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskList(),
      child: MaterialApp(
        title: 'Lista de Tareas',
        theme: ThemeData(
          primarySwatch: Colors.blue, // Cambiar el color primario a azul
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue, // Cambiar el color primario a azul
            accentColor: Colors.yellow, // Cambiar el color de acento a amarillo
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TaskListScreen(),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: Consumer<TaskList>(
        builder: (context, taskList, child) {
          return ListView.builder(
            itemCount: taskList.tasks.length,
            itemBuilder: (context, index) {
              final task = taskList.tasks[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(task.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: task.completed,
                        onChanged: (value) {
                          taskList.toggleTaskCompletion(index);
                        },
                        activeColor: Colors.yellowAccent, // Cambiar el color del checkbox a amarillo claro
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditTaskScreen(task: task, onUpdate: () {
                                // Handle update notification here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Tarea modificada correctamente')),
                                );
                              }),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          taskList.deleteTask(index);
                          // Handle delete notification here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tarea eliminada correctamente')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditTaskScreen(onUpdate: () {
              // Handle add notification here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tarea agregada correctamente')),
              );
            })),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final VoidCallback onUpdate;

  const AddEditTaskScreen({Key? key, this.task, required this.onUpdate}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.deadline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Editar Tarea' : 'Agregar Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
              ),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text(
                _selectedDate != null
                    ? 'Fecha límite: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                    : 'Seleccionar fecha límite',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final description = _descriptionController.text;
                if (title.isNotEmpty) {
                  if (widget.task != null) {
                    widget.task!.title = title;
                    widget.task!.description = description;
                    widget.task!.deadline = _selectedDate;
                    widget.onUpdate();
                  } else {
                    Provider.of<TaskList>(context, listen: false).addTask(
                      Task(
                        title: title,
                        description: description,
                        deadline: _selectedDate,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(widget.task != null ? 'Guardar cambios' : 'Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            if (task.deadline != null) // Mostrar la fecha límite si está definida
              SizedBox(height: 16),
              Text(
                'Fecha límite: ${DateFormat('yyyy-MM-dd').format(task.deadline!)}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Task {
  late String title;
  late String description;
  bool completed;
  DateTime? deadline;

  Task({
    required this.title,
    required this.description,
    this.completed = false,
    this.deadline,
  });
}

class TaskList extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void toggleTaskCompletion(int index) {
    _tasks[index].completed = !_tasks[index].completed;
    notifyListeners();
  }
}
