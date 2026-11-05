import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeSearchScreen extends StatelessWidget {
  final String query;
  const YouTubeSearchScreen({super.key, required this.query});

  Future<void> _launchUrl(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final encodedQuery = Uri.encodeComponent(query);
    final searchUrl = 'https://www.youtube.com/results?search_query=$encodedQuery';

    return Scaffold(
      appBar: AppBar(title: Text('YouTube: $query')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎥 Video Matcher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Showing matched tutorials for: "$query"', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.play_circle_fill, color: Colors.red, size: 40),
              title: Text('$query - Comprehensive Guide'),
              subtitle: const Text('Matched via TaskWise Search Engine'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _launchUrl(searchUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}