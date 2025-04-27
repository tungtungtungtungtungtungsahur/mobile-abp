import 'package:flutter/material.dart';
import 'services/chat_service.dart';

class ChatDatabaseTest extends StatefulWidget {
  const ChatDatabaseTest({super.key});

  @override
  State<ChatDatabaseTest> createState() => _ChatDatabaseTestState();
}

class _ChatDatabaseTestState extends State<ChatDatabaseTest> {
  String _status = 'Ready to recreate chat database';
  bool _isLoading = false;

  Future<void> _recreateDatabase() async {
    setState(() {
      _isLoading = true;
      _status = 'Recreating chat database...';
    });

    try {
      await ChatService.recreateChatDatabase();
      setState(() {
        _status = 'Chat database recreated successfully! ✅';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e ❌';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Database Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _recreateDatabase,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Recreate Chat Database'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
