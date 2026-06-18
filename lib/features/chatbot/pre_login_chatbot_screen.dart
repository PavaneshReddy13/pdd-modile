import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/careflow_neon_background.dart';
import '../../core/widgets/careflow_glass_card.dart';

class PreLoginChatbotScreen extends StatefulWidget {
  const PreLoginChatbotScreen({super.key});

  @override
  State<PreLoginChatbotScreen> createState() => _PreLoginChatbotScreenState();
}

class _PreLoginChatbotScreenState extends State<PreLoginChatbotScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'bot',
      'text': 'Hello! I am the CareFlow Assistant. How can I help you today?'
    }
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messageController.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      String reply =
          "I'm sorry, I don't understand that. Please login to speak to a real doctor or receptionist.";
      final lower = text.toLowerCase();
      if (lower.contains('appointment') || lower.contains('book')) {
        reply =
            "To book an appointment, please create a Patient account and login. Then select 'Book Appointment' from your dashboard.";
      } else if (lower.contains('hello') || lower.contains('hi')) {
        reply = "Hi there! Welcome to CareFlow.";
      } else if (lower.contains('emergency')) {
        reply =
            "If this is a medical emergency, please call your local emergency services immediately (e.g. 911/108).";
      }

      if (mounted) {
        setState(() {
          _messages.add({'role': 'bot', 'text': reply});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CareFlowNeonBackground(
      showGrid: true,
      showOrb: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('CareFlow Assistant',
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryNeon),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/role-select');
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(colors: [
                                AppTheme.primaryNeon,
                                AppTheme.cyanAccent
                              ])
                            : null,
                        color: isUser ? null : AppTheme.cardBg,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft:
                              isUser ? const Radius.circular(18) : Radius.zero,
                          bottomRight:
                              isUser ? Radius.zero : const Radius.circular(18),
                        ),
                        border: isUser
                            ? null
                            : Border.all(color: AppTheme.borderCol),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser
                              ? AppTheme.background
                              : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight:
                              isUser ? FontWeight.bold : FontWeight.normal,
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CareFlowGlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 22,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.primaryNeon),
                      onPressed: _sendMessage,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
