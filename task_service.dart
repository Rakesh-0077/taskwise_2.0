
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_item.dart';
import '../models/scheduled_session.dart';

class TaskService {
  // Load all locally saved tasks.
  Future<List<TaskItem>> fetchAllLocal(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('taskwise_tasks_$email');

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) {
      return TaskItem.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  // Save all tasks locally.
  Future<void> saveAllLocal(
      String email,
      List<TaskItem> tasks,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final taskData = tasks.map((task) => task.toJson()).toList();

    await prefs.setString(
      'taskwise_tasks_$email',
      jsonEncode(taskData),
    );
  }

  // Clear saved tasks and schedule.
  Future<void> clearAllLocal(String email) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('taskwise_tasks_$email');
    await prefs.remove('taskwise_schedule_$email');
  }

  // Load user preferences.
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final email =
        prefs.getString('user_email') ?? 'student@taskwise.com';

    return {
      'isLoggedIn': prefs.getBool('is_logged_in') ?? false,
      'userName': prefs.getString('user_name_$email') ?? 'User',
      'userEmail': email,
      'userMode': prefs.getString('user_mode_$email') ?? 'Student',
      'themeMode': prefs.getString('theme_mode') ?? 'System',
      'notifications':
      prefs.getBool('notifications_enabled') ?? true,
      'startTime': prefs.getString('start_time') ?? '08:30',
    };
  }

  // Save an individual preference.
  Future<void> savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  // Load the saved daily schedule.
  Future<List<ScheduledSession>> fetchSchedule(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('taskwise_schedule_$email');

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) {
      return ScheduledSession.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  // Save the daily schedule.
  Future<void> saveSchedule(
      String email,
      List<ScheduledSession> sessions,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final scheduleData =
    sessions.map((session) => session.toJson()).toList();

    await prefs.setString(
      'taskwise_schedule_$email',
      jsonEncode(scheduleData),
    );
  }
}
