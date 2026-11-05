class TaskItem {
  final String id;
  String title;
  String description;
  String subject;
  String deadline;
  String difficulty;
  int estimatedDurationMinutes;
  bool isDone;
  String createdAt;

  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    this.subject = 'General',
    required this.deadline,
    this.difficulty = 'Medium',
    this.estimatedDurationMinutes = 45,
    this.isDone = false,
    required this.createdAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String? ?? DateTime.now().toIso8601String(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      subject: json['subject'] as String? ?? 'General',
      deadline: json['deadline'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int? ?? 45,
      isDone: json['isDone'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'subject': subject,
    'deadline': deadline,
    'difficulty': difficulty,
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'isDone': isDone,
    'createdAt': createdAt,
  };
}