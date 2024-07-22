class Todo {
  String task;
  String? description; // Yeni açıklama alanı
  DateTime? dueDate;
  bool completed;

  Todo({
    required this.task,
    this.description, // Yeni açıklama alanı
    this.dueDate,
    this.completed = false,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      task: json['task'],
      description: json['description'], // Yeni açıklama alanı
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'description': description, // Yeni açıklama alanı
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
    };
  }
}
