import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoHome(),
    );
  }
}

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? taskData = prefs.getString('tasks');

    if (taskData != null) {
      final List decoded = json.decode(taskData);
      tasks = decoded.map((e) => Task.fromMap(e)).toList();
      setState(() {});
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        json.encode(tasks.map((e) => e.toMap()).toList());
    await prefs.setString('tasks', encoded);
  }

  void addTask(String title) {
    tasks.add(Task(title: title));
    saveTasks();
    setState(() {});
  }

  void editTask(int index, String title) {
    tasks[index].title = title;
    saveTasks();
    setState(() {});
  }

  void deleteTask(int index) {
    tasks.removeAt(index);
    saveTasks();
    setState(() {});
  }

  void toggleStatus(int index) {
    tasks[index].isCompleted = !tasks[index].isCompleted;
    saveTasks();
    setState(() {});
  }

  void showTaskDialog({int? index}) {
    final controller = TextEditingController(
        text: index != null ? tasks[index].title : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? 'Add Task' : 'Edit Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter task'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                index == null
                    ? addTask(controller.text)
                    : editTask(index, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: tasks.isEmpty
          ? const Center(child: Text('No Tasks'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index].isCompleted,
                    onChanged: (_) => toggleStatus(index),
                  ),
                  title: Text(
                    tasks[index].title,
                    style: TextStyle(
                      decoration: tasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showTaskDialog(index: index)),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteTask(index)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}