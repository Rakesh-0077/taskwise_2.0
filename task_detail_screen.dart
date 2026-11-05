import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_item.dart';
import '../providers/task_store.dart';
import 'notes_view_screen.dart';
import 'youtube_search_screen.dart';
import 'quiz_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final task = store.items.firstWhere((t) => t.id == taskId, orElse: () => TaskItem(id: '', title: 'Not Found', deadline: '', createdAt: ''));

    if (task.id.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Task not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Chip(label: Text('${task.subject} • Due: ${task.deadline}')),
          const SizedBox(height: 16),
          const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(task.description.isEmpty ? 'No description.' : task.description),
          const SizedBox(height: 24),
          if (store.userMode == 'Student') ...[
            const Text('Learning Resources & Matched Videos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book, color: Colors.blue),
                title: const Text('Study Material & Curated Links'),
                subtitle: const Text('Official documentation & verified study guides'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesViewScreen(taskTitle: task.title, subject: task.subject))),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_library, color: Colors.red),
                title: const Text('Matched YouTube Videos'),
                subtitle: const Text('Instantly curated for your exact task'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => YouTubeSearchScreen(query: '${task.subject} ${task.title}'))),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.quiz, color: Colors.green),
                title: const Text('Practice Quiz via Gemini AI (10 - 100 Questions)'),
                subtitle: const Text('Configure question limit & topic-based test'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      int selectedLimit = 10;
                      return AlertDialog(
                        title: const Text('Select Quiz Question Limit'),
                        content: StatefulBuilder(
                          builder: (context, setStateModal) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Choose how many questions you want: $selectedLimit', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Slider(
                                  value: selectedLimit.toDouble(),
                                  min: 10,
                                  max: 100,
                                  divisions: 9,
                                  label: '$selectedLimit',
                                  onChanged: (val) => setStateModal(() => selectedLimit = val.toInt()),
                                ),
                              ],
                            );
                          },
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(topic: task.title, subject: task.subject, questionLimit: selectedLimit),
                                ),
                              );
                            },
                            child: const Text('Start Quiz'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            const Text('Employee Productivity Workflow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Simple workflow tracker synced with calendar deadlines.'))),
          ],
        ],
      ),
    );
  }
}