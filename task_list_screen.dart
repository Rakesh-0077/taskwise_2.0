import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_store.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        actions: [
          if (store.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: 'Clear All Tasks',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All Tasks?'),
                    content: const Text('This will remove all tasks and schedules permanently.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          store.clearAllTasks();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: store.items.isEmpty
          ? const Center(child: Text('No tasks created yet.'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: store.items.length,
        itemBuilder: (context, index) {
          final task = store.items[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Checkbox(value: task.isDone, onChanged: (_) => store.toggleTaskStatusById(task.id)),
              title: Text(task.title, style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold)),
              subtitle: Text('${task.subject} • Due: ${task.deadline}'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id))),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
