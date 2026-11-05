import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesViewScreen extends StatelessWidget {
  final String taskTitle;
  final String subject;
  const NotesViewScreen({super.key, required this.taskTitle, required this.subject});

  Future<void> _openLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String query = Uri.encodeComponent('$subject $taskTitle');

    return Scaffold(
      appBar: AppBar(title: Text('Notes & Links: $taskTitle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📖 Study Guide & References for $subject', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  const Text('• Core Concepts Overview:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Comprehensive breakdown and key principles required to master "$taskTitle" successfully.\n'),
                  const Text('• Recommended Study Web Resources:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.language, color: Colors.blue),
                      title: const Text('Official Documentation & Reference'),
                      subtitle: Text('Search live docs for $taskTitle'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => _openLink('https://www.google.com/search?q=$query+documentation'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.menu_book, color: Colors.green),
                      title: const Text('GeeksforGeeks & W3Schools Tutorials'),
                      subtitle: Text('Step-by-step guides for $subject'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => _openLink('https://www.geeksforgeeks.org/search/?q=$query'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.code, color: Colors.orange),
                      title: const Text('Interactive Code Examples & Cheatsheet'),
                      subtitle: const Text('Explore syntax & practice implementations'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => _openLink('https://devdocs.io/'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}