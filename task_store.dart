import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../models/scheduled_session.dart';
import '../services/task_service.dart';

class TaskStore extends ChangeNotifier {
  final service = TaskService();
  List<TaskItem> items = [];
  List<ScheduledSession> schedule = [];
  bool loading = true;
  String? error;

  bool isLoggedIn = false;
  String userName = 'User';
  String userEmail = 'student@taskwise.com';
  String userMode = 'Student';
  String themeModeSetting = 'System';
  bool notificationsEnabled = true;
  String studyStartTime = '08:30';

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await service.loadPreferences();
      isLoggedIn = prefs['isLoggedIn'];
      userName = prefs['userName'];
      userEmail = prefs['userEmail'];
      userMode = prefs['userMode'];
      themeModeSetting = prefs['themeMode'];
      notificationsEnabled = prefs['notifications'];
      studyStartTime = prefs['startTime'];

      if (isLoggedIn && userEmail.isNotEmpty) {
        items = await service.fetchAllLocal(userEmail);
        schedule = await service.fetchSchedule(userEmail);
      }

      if (schedule.isEmpty && items.isNotEmpty) {
        generateDailyPlan();
      }
    } catch (e) {
      error = 'Could not load your data';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> login(String name, String email, String mode) async {
    userName = name;
    userEmail = email;
    userMode = mode;
    isLoggedIn = true;

    await service.savePreference('is_logged_in', true);
    await service.savePreference('user_email', email);
    await service.savePreference('user_name_$email', name);
    await service.savePreference('user_mode_$email', mode);

    items = await service.fetchAllLocal(userEmail);
    schedule = await service.fetchSchedule(userEmail);
    generateDailyPlan();

    notifyListeners();
  }

  Future<void> logout() async {
    isLoggedIn = false;
    await service.savePreference('is_logged_in', false);
    notifyListeners();
  }

  void setThemeMode(String mode) async {
    themeModeSetting = mode;
    await service.savePreference('theme_mode', mode);
    notifyListeners();
  }

  void setNotificationsEnabled(bool val) async {
    notificationsEnabled = val;
    await service.savePreference('notifications_enabled', val);
    notifyListeners();
  }

  void add(TaskItem task) async {
    items.insert(0, task);
    notifyListeners();
    if (userEmail.isNotEmpty) {
      await service.saveAllLocal(userEmail, items);
      generateDailyPlan();
    }
  }

  void updateTask(TaskItem updatedTask) async {
    final index = items.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      items[index] = updatedTask;
      notifyListeners();
      if (userEmail.isNotEmpty) {
        await service.saveAllLocal(userEmail, items);
        generateDailyPlan();
      }
    }
  }

  void delete(String id) async {
    items.removeWhere((t) => t.id == id);
    notifyListeners();
    if (userEmail.isNotEmpty) {
      await service.saveAllLocal(userEmail, items);
      generateDailyPlan();
    }
  }

  void clearAllTasks() async {
    items.clear();
    schedule.clear();
    if (userEmail.isNotEmpty) {
      await service.clearAllLocal(userEmail);
    }
    notifyListeners();
  }

  void toggleTaskStatusById(String id) async {
    final task = items.firstWhere((t) => t.id == id);
    task.isDone = !task.isDone;
    notifyListeners();
    if (userEmail.isNotEmpty) {
      await service.saveAllLocal(userEmail, items);
      generateDailyPlan();
    }
  }

  void generateDailyPlan() {
    if (userEmail.isEmpty) return;
    final pending = items.where((t) => !t.isDone).toList();
    pending.sort((a, b) => a.deadline.compareTo(b.deadline));

    List<ScheduledSession> newSessions = [];
    TimeOfDay currentTime = _parseTime(studyStartTime);

    for (var task in pending) {
      final startStr = _formatTimeOfDay(currentTime);
      final duration = task.estimatedDurationMinutes;
      currentTime = _addMinutes(currentTime, duration);
      final endStr = _formatTimeOfDay(currentTime);

      newSessions.add(
        ScheduledSession(
          taskId: task.id,
          taskTitle: task.title,
          startTime: startStr,
          endTime: endStr,
          subject: task.subject,
          resourceType: userMode == 'Student' ? 'Notes & Quiz' : 'Work Stream',
        ),
      );
      currentTime = _addMinutes(currentTime, 15);
    }

    schedule = newSessions;
    service.saveSchedule(userEmail, schedule);
    notifyListeners();
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 30,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  TimeOfDay _addMinutes(TimeOfDay time, int mins) {
    int totalMins = time.hour * 60 + time.minute + mins;
    int newHour = (totalMins ~/ 60) % 24;
    int newMin = totalMins % 60;
    return TimeOfDay(hour: newHour, minute: newMin);
  }
}