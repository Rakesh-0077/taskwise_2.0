
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_store.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final selectedDateString = formatDate(selectedDate);

    final tasksForDay = store.items.where((task) {
      return task.deadline == selectedDateString;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Calendar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tasks for $selectedDateString',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: tasksForDay.isEmpty
                ? const Center(
              child: Text('No tasks due on this date.'),
            )
                : ListView.builder(
              itemCount: tasksForDay.length,
              itemBuilder: (context, index) {
                final task = tasksForDay[index];

                return ListTile(
                  leading: Icon(
                    task.isDone
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    color: task.isDone
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text(task.title),
                  subtitle: Text(task.subject),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
