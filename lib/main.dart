import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'todo.dart'; // Todo sınıfını içe aktardık

void main() {
  runApp(const MyApp());
}

const Color backgroundColor = Color.fromARGB(255, 0, 128, 128);
const Color appbarColor = Color.fromARGB(255, 47, 79, 79);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.deepPurple[900],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey[800],
            fontSize: 20,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Todo> _todos = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // Yeni açıklama controller'ı

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> todoStrings =
        _todos.map((todo) => json.encode(todo.toJson())).toList();
    prefs.setStringList('todos', todoStrings);
  }

  void _removeTodoAt(int index) {
    setState(() {
      _todos.removeAt(index);
      _saveTodos();
    });
  }

  void _editDueDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _todos[index].dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _todos[index].dueDate = picked;
        _saveTodos();
      });
    }
  }

  void _addTodo() {
    final String taskText = _taskController.text.trim();
    final String descriptionText =
        _descriptionController.text.trim(); // Yeni açıklama
    if (taskText.isNotEmpty) {
      setState(() {
        _todos.add(Todo(
          task: taskText,
          description: descriptionText, // Yeni açıklama
        ));
        _taskController.clear();
        _descriptionController.clear(); // Yeni açıklama
        _saveTodos();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // Arka plan rengini değiştirdik
      appBar: AppBar(
        backgroundColor: appbarColor,
        title: const Text('To-Do List App'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Yeni görev girin',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController, // Yeni açıklama alanı
                  decoration: const InputDecoration(
                    labelText: 'Görev hakkında açıklama',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            _todos[index].task,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      decoration: _todos[index].completed
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _todos[index].description != null
                                  ? Text(
                                      'Açıklama: ${_todos[index].description}')
                                  : const SizedBox.shrink(),
                              _todos[index].dueDate != null
                                  ? Text(
                                      'Son Teslim: ${DateFormat.yMd().format(_todos[index].dueDate!)}')
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          leading: Checkbox(
                            value: _todos[index].completed,
                            onChanged: (bool? value) {
                              setState(() {
                                _todos[index].completed = value ?? false;
                                _saveTodos();
                              });
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _editDueDate(index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeTodoAt(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 1,
            left: 1,
            child: Text(
              'Designed by Ahmet Koca',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo, // Doğru işlev ataması
        tooltip: 'Görev Ekle',
        child: const Icon(Icons.add), // 'child' parametresini en sona taşıdık
      ),
    );
  }
}
