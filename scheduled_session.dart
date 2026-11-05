class ScheduledSession {
  final String taskId;
  final String taskTitle;
  final String startTime;
  final String endTime;
  final String subject;
  final String resourceType;
  bool isDone;

  ScheduledSession({
    required this.taskId,
    required this.taskTitle,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.resourceType,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'taskTitle': taskTitle,
    'startTime': startTime,
    'endTime': endTime,
    'subject': subject,
    'resourceType': resourceType,
    'isDone': isDone,
  };

  factory ScheduledSession.fromJson(Map<String, dynamic> json) {
    return ScheduledSession(
      taskId: json['taskId'] ?? '',
      taskTitle: json['taskTitle'] ?? '',
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '10:00',
      subject: json['subject'] ?? 'General',
      resourceType: json['resourceType'] ?? 'Study',
      isDone: json['isDone'] ?? false,
    );
  }
}