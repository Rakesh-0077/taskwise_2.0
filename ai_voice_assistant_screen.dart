
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/task_item.dart';
import '../providers/task_store.dart';

class AIVoiceAssistantScreen extends StatefulWidget {
  const AIVoiceAssistantScreen({super.key});

  @override
  State<AIVoiceAssistantScreen> createState() =>
      _AiVoiceAssistantScreenState();
}

class _AiVoiceAssistantScreenState
    extends State<AIVoiceAssistantScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final TextEditingController _messageController =
  TextEditingController();

  final List<Map<String, String>> _messages = [];

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;

  String _statusMessage = 'Hello! How can I help you today?';

  @override
  void initState() {
    super.initState();

    _initializeTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSpeech();
    });

    _addAssistantMessage(
      'Hello! I am your TaskWise assistant. '
          'You can ask me for help or say "add task" to create a task.',
    );
  }

  // Initialize text-to-speech.
  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        if (!mounted) return;

        setState(() {
          _isSpeaking = true;
        });
      });

      _tts.setCompletionHandler(() {
        if (!mounted) return;

        setState(() {
          _isSpeaking = false;
        });
      });

      _tts.setErrorHandler((message) {
        if (!mounted) return;

        setState(() {
          _isSpeaking = false;
        });
      });
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  // Initialize speech recognition.
  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          setState(() {
            _isListening = status == 'listening';
          });
        },
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _isListening = false;
            _statusMessage = 'Speech recognition error.';
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _speechAvailable = available;
        _statusMessage = available
            ? 'Voice assistant is ready.'
            : 'Speech recognition is unavailable.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
        _statusMessage = 'Unable to initialize microphone.';
      });
    }
  }

  // Start listening to the user's voice.
  Future<void> _startListening() async {
    if (!_speechAvailable) {
      await _initializeSpeech();

      if (!_speechAvailable) {
        _showMessage('Speech recognition is not available.');
        return;
      }
    }

    if (_isListening) return;

    try {
      await _tts.stop();

      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _messageController.text = result.recognizedWords;
            _messageController.selection =
                TextSelection.fromPosition(
                  TextPosition(
                    offset: _messageController.text.length,
                  ),
                );
          });

          if (result.finalResult) {
            final recognizedText = result.recognizedWords.trim();

            if (recognizedText.isNotEmpty) {
              _processUserCommand(recognizedText);
            }
          }
        },
        localeId: 'en_IN',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isListening = true;
        _statusMessage = 'Listening... Speak now.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isListening = false;
        _statusMessage = 'Unable to start listening.';
      });
    }
  }

  // Stop microphone listening.
  Future<void> _stopListening() async {
    try {
      await _speech.stop();

      if (!mounted) return;

      setState(() {
        _isListening = false;
        _statusMessage = 'Listening stopped.';
      });
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  // Speak the assistant's response.
  Future<void> _speak(String message) async {
    try {
      await _tts.stop();
      await _tts.speak(message);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  // Add a user message to chat.
  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });
    });
  }

  // Add an assistant message to chat.
  void _addAssistantMessage(String message) {
    if (!mounted) return;

    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': message,
      });
    });
  }

  // Display a small notification.
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Process text and voice commands.
  Future<void> _processUserCommand(String command) async {
    final text = command.trim();

    if (text.isEmpty || _isProcessing) return;

    await _stopListening();

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _messageController.clear();
      _statusMessage = 'Processing your request...';
    });

    _addUserMessage(text);

    try {
      final response = await _handleCommand(text);

      if (!mounted) return;

      _addAssistantMessage(response);

      setState(() {
        _statusMessage = 'Ready for your next command.';
      });

      await _speak(response);
    } catch (e) {
      if (!mounted) return;

      const errorMessage =
          'Sorry, something went wrong while processing your request.';

      _addAssistantMessage(errorMessage);
      _showMessage(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Understand and execute supported commands.
  Future<String> _handleCommand(String command) async {
    final normalized = command.toLowerCase().trim();

    if (normalized == 'hello' ||
        normalized == 'hi' ||
        normalized == 'hey') {
      return 'Hello! Welcome to TaskWise. '
          'I can help you create and organize your tasks.';
    }

    if (normalized.contains('help') ||
        normalized.contains('what can you do')) {
      return 'I can help you create tasks. '
          'Try saying: Add task complete Java assignment. '
          'You can also ask me to show you how to use TaskWise.';
    }

    if (normalized.contains('add task') ||
        normalized.contains('create task') ||
        normalized.contains('new task')) {
      return await _createTaskFromCommand(command);
    }

    if (normalized.contains('how many tasks') ||
        normalized.contains('show my tasks') ||
        normalized.contains('my tasks')) {
      return _getTaskSummary();
    }

    if (normalized.contains('completed tasks') ||
        normalized.contains('finished tasks')) {
      return _getCompletedTaskSummary();
    }

    if (normalized.contains('pending tasks') ||
        normalized.contains('remaining tasks')) {
      return _getPendingTaskSummary();
    }

    if (normalized.contains('thank you') ||
        normalized == 'thanks') {
      return 'You are welcome! Keep your tasks organized with TaskWise.';
    }

    if (normalized.contains('time management')) {
      return 'Try breaking large tasks into smaller activities. '
          'Set deadlines, prioritize important work, '
          'and follow your daily plan.';
    }

    return 'I can currently help with task creation, '
        'task summaries, completed tasks, pending tasks, '
        'and basic study planning. '
        'Try saying "help" to see available commands.';
  }

  // Create a task from a spoken or typed command.
  Future<String> _createTaskFromCommand(String command) async {
    String title = command;

    final lowerCommand = command.toLowerCase();

    final prefixes = [
      'please add task',
      'please create task',
      'add a new task',
      'create a new task',
      'add task',
      'create task',
      'new task',
    ];

    for (final prefix in prefixes) {
      if (lowerCommand.startsWith(prefix)) {
        title = command.substring(prefix.length).trim();
        break;
      }
    }

    if (title.isEmpty) {
      return 'Please provide a task title. '
          'For example, say "Add task complete Java assignment".';
    }

    final store = context.read<TaskStore>();

    final task = TaskItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: 'Created using TaskWise Voice Assistant.',
      subject: 'General',
      deadline: _formatDate(DateTime.now()),
      difficulty: 'Medium',
      estimatedDurationMinutes: 45,
      createdAt: DateTime.now().toIso8601String(),
      isDone: false,
    );

    store.add(task);

    return 'Your task "$title" has been added successfully. '
        'You can view it in your TaskWise task list.';
  }

  // Format date as yyyy-MM-dd.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // Get task summary.
  String _getTaskSummary() {
    final store = context.read<TaskStore>();

    final total = store.items.length;
    final completed =
        store.items.where((task) => task.isDone).length;
    final pending = total - completed;

    return 'You have $total tasks in total. '
        '$completed tasks are completed and '
        '$pending tasks are pending.';
  }

  // Get completed task summary.
  String _getCompletedTaskSummary() {
    final store = context.read<TaskStore>();

    final completed =
    store.items.where((task) => task.isDone).toList();

    if (completed.isEmpty) {
      return 'You have not completed any tasks yet.';
    }

    return 'You have completed ${completed.length} tasks. '
        'Good progress!';
  }

  // Get pending task summary.
  String _getPendingTaskSummary() {
    final store = context.read<TaskStore>();

    final pending =
    store.items.where((task) => !task.isDone).toList();

    if (pending.isEmpty) {
      return 'You have no pending tasks. '
          'Your task list is clear.';
    }

    return 'You currently have ${pending.length} pending tasks. '
        'Open your task list to review them.';
  }

  // Send typed message.
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) return;

    await _processUserCommand(message);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _messageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined),
            SizedBox(width: 10),
            Text('TaskWise Assistant'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Stop voice',
            onPressed: () async {
              await _stopListening();
              await _tts.stop();
            },
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Assistant status.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TaskWise Assistant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusMessage,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (_isProcessing)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else if (_isListening)
                  const Icon(
                    Icons.mic,
                    color: Colors.red,
                  )
                else
                  const Icon(Icons.check_circle_outline),
              ],
            ),
          ),

          // Chat messages.
          Expanded(
            child: _messages.isEmpty
                ? const Center(
              child: Text('Start a conversation with TaskWise.'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                final isUser =
                    message['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width *
                          0.78,
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context)
                          .colorScheme
                          .primary
                          : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : Theme.of(context)
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Microphone and typing controls.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(25),
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Send message',
                        onPressed:
                        _isProcessing ? null : _sendMessage,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        tooltip: _isListening
                            ? 'Stop listening'
                            : 'Start voice input',
                        onPressed: _isProcessing
                            ? null
                            : (_isListening
                            ? _stopListening
                            : _startListening),
                        icon: Icon(
                          _isListening
                              ? Icons.mic_off
                              : Icons.mic,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(60, 60),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isListening
                            ? 'Listening...'
                            : 'Tap microphone to speak',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
