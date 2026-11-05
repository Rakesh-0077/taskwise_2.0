import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../providers/task_store.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskItem? taskToEdit;
  const AddEditTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subjectController;
  late TextEditingController _deadlineController;
  String _difficulty = 'Medium';
  int _duration = 45;

  @override
  void initState() {
    super.initState();
    final t = widget.taskToEdit;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _subjectController = TextEditingController(text: t?.subject ?? 'General');
    _deadlineController = TextEditingController(text: t?.deadline ?? DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))));
    _difficulty = t?.difficulty ?? 'Medium';
    _duration = t?.estimatedDurationMinutes ?? 45;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final store = context.read<TaskStore>();

    if (widget.taskToEdit == null) {
      store.add(TaskItem(
        id: DateTime.now().toIso8601String(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        subject: _subjectController.text.trim(),
        deadline: _deadlineController.text.trim(),
        difficulty: _difficulty,
        estimatedDurationMinutes: _duration,
        createdAt: DateTime.now().toIso8601String(),
      ));
    } else {
      widget.taskToEdit!.title = _titleController.text.trim();
      widget.taskToEdit!.description = _descController.text.trim();
      widget.taskToEdit!.subject = _subjectController.text.trim();
      widget.taskToEdit!.deadline = _deadlineController.text.trim();
      widget.taskToEdit!.difficulty = _difficulty;
      widget.taskToEdit!.estimatedDurationMinutes = _duration;
      store.updateTask(widget.taskToEdit!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.taskToEdit == null ? 'Add Task & Sync Calendar' : 'Edit Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Subject or Category', border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextFormField(controller: _deadlineController, decoration: const InputDecoration(labelText: 'Deadline Date (yyyy-MM-dd)', border: OutlineInputBorder())),
              const SizedBox(height: 14),
              Text('Estimated Duration: $_duration mins'),
              Slider(
                value: _duration.toDouble(),
                min: 15,
                max: 180,
                divisions: 11,
                label: '$_duration mins',
                onChanged: (v) => setState(() => _duration = v.toInt()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _save,
                child: const Text('Save Task', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}