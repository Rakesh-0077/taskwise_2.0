import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_store.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedMode = 'Student';

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;
    final store = context.read<TaskStore>();
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    await store.login(name.isEmpty ? 'User' : name, email, _selectedMode);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lock_outline, size: 60, color: Color(0xFF3B82F6)),
                const SizedBox(height: 16),
                const Text('Welcome to TaskWise', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Sign in to access AI Quizzes & Smart Planning', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Student', label: Text('Student Mode')),
                    ButtonSegment(value: 'Employee', label: Text('Employee Mode')),
                  ],
                  selected: {_selectedMode},
                  onSelectionChanged: (val) => setState(() => _selectedMode = val.first),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email ID', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: (v) => v!.length < 4 ? 'Min 4 characters required' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitAuth,
                  child: const Text('Continue to TaskWise', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}