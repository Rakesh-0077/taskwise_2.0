import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_store.dart';
import 'ai_voice_assistant_screen.dart';
import 'daily_plan_screen.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    if (store.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = store.items.length;
    final done = store.items.where((t) => t.isDone).length;
    final pending = total - done;

    return Scaffold(
      appBar: AppBar(
        title: Text('${store.userName} (${store.userMode})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.amber),
            tooltip: 'Ding Notification Popup',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('🔔 Task Reminder (Ding!)'),
                  content: Text('You have $pending pending tasks scheduled. Stay on track!'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.blueAccent),
            tooltip: 'Voice Assistant',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIVoiceAssistantScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.userMode == 'Student' ? '📚 Student Hub: Quizzes & Notes Active' : '💼 Employee Hub: Clean Workflow',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('Account: ${store.userEmail}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _DashCard(title: 'Total', count: '$total', icon: Icons.list_alt, color: Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _DashCard(title: 'Done', count: '$done', icon: Icons.check_circle, color: Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _DashCard(title: 'Pending', count: '$pending', icon: Icons.hourglass_top, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily AI Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyPlanScreen())),
                  child: const Text('View Full Plan'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            store.schedule.isEmpty
                ? const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No active schedule. Add tasks to populate timetable!')))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: store.schedule.length > 3 ? 3 : store.schedule.length,
              itemBuilder: (context, idx) {
                final session = store.schedule[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.access_time, color: Color(0xFF3B82F6)),
                    title: Text(session.taskTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${session.startTime} - ${session.endTime} • ${session.subject}'),
                    trailing: Chip(label: Text(session.resourceType, style: const TextStyle(fontSize: 10))),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen())),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _DashCard({required this.title, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }
}