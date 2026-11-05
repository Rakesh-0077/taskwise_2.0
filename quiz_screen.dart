
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizScreen extends StatefulWidget {
  final String topic;
  final String subject;
  final int questionLimit;

  const QuizScreen({
    super.key,
    required this.topic,
    required this.subject,
    required this.questionLimit,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];

  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedOption;

  bool _isLoading = true;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    // Local fallback questions keep the quiz usable without an API.
    // Replace these with topic-specific questions or connect a secure
    // backend to generate questions using Gemini.
    final fallbackQuestions = <Map<String, dynamic>>[
      {
        'question': 'What does JVM stand for?',
        'options': [
          'Java Variable Machine',
          'Java Virtual Machine',
          'Java Verified Method',
          'Java Visual Model',
        ],
        'answer': 1,
      },
      {
        'question': 'Which keyword is used to inherit a class in Java?',
        'options': [
          'implements',
          'inherits',
          'extends',
          'instance',
        ],
        'answer': 2,
      },
      {
        'question': 'Which method is the entry point of a Java program?',
        'options': [
          'start()',
          'run()',
          'main()',
          'execute()',
        ],
        'answer': 2,
      },
      {
        'question': 'Which of these is not a Java primitive type?',
        'options': [
          'int',
          'boolean',
          'String',
          'double',
        ],
        'answer': 2,
      },
      {
        'question': 'Which keyword creates an object in Java?',
        'options': [
          'class',
          'new',
          'this',
          'static',
        ],
        'answer': 1,
      },
    ];

    if (!mounted) return;

    setState(() {
      _questions = fallbackQuestions
          .take(widget.questionLimit.clamp(1, fallbackQuestions.length))
          .toList();
      _isLoading = false;
    });
  }

  void _nextQuestion() {
    if (_selectedOption == null) return;

    final correctAnswer =
    _questions[_currentQuestion]['answer'] as int;

    if (_selectedOption == correctAnswer) {
      _score++;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
      });
    } else {
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _selectedOption = null;
      _isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No questions available.'),
        ),
      );
    }

    if (_isSubmitted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your score: $_score / ${_questions.length}',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _restartQuiz,
                  child: const Text('Try Again'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestion];
    final options = question['options'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.topic,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
            ),
            const SizedBox(height: 12),
            Text(
              'Question ${_currentQuestion + 1} of ${_questions.length}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Text(
              question['question'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: RadioListTile<int>(
                      title: Text(options[index].toString()),
                      value: index,
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                _selectedOption == null ? null : _nextQuestion,
                child: Text(
                  _currentQuestion == _questions.length - 1
                      ? 'Submit Quiz'
                      : 'Next Question',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
