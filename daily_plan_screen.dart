import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_store.dart';

class DailyPlanScreen extends StatelessWidget {
  const DailyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Timetable & Schedule')),
      body: store.schedule.isEmpty
          ? const Center(child: Text('No schedule generated yet. Add tasks with deadlines!'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('AI Automated Timelines:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...store.schedule.map((session) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.schedule, size: 18)),
                title: Text(session.taskTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${session.startTime} - ${session.endTime} • ${session.subject}'),
                trailing: Chip(label: Text(session.resourceType, style: const TextStyle(fontSize: 10))),
              ),
            );
          }),
        ],
      ),
    );
  }
}
