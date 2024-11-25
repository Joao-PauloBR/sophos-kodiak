import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

final logger = Logger();

class MainScreen extends StatefulWidget {
  final String userName;

  const MainScreen({super.key, required this.userName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isDropdownVisible = false;
  final FocusNode _focusNode = FocusNode();
  bool _isVoiceInputActive = false;
  bool _isLoading = false;
  final List<Map<String, String>> _suggestions = [
    {
      'title': 'Preveja quais clientes estão',
      'subtitle': 'mais propensos a cancelar o serviço'
    },
    {'title': 'Quais produtos têm a', 'subtitle': 'maior margem de lucro?'},
    {
      'title': 'Qual é a previsão de vendas',
      'subtitle': 'para os próximos três meses?'
    },
  ];
  final List<ChatMessage> _messages = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      if (_focusNode.hasFocus) {
        _isDropdownVisible = false;
      }
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
      if (_isDropdownVisible) {
        _focusNode.unfocus();
      }
    });
  }

  void _toggleVoiceInput() async {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      bool available = await _speech.initialize(
        onStatus: (val) => logger.d('onStatus: $val'),
        onError: (val) => logger.e('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _messageController.text = val.recognizedWords;
          }),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: userMessage,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = true;
      });

      _messageController.clear();
      _focusNode.unfocus();

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/gemini'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'pergunta': userMessage}),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _messages.add(
              ChatMessage(
                text: data['resposta'],
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          });
        } else {
          _showErrorDialog('Erro no servidor: ${response.statusCode}');
        }
      } catch (e) {
        _showErrorDialog('Erro de comunicação: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildChatArea(),
                ),
                _buildSuggestionsCarousel(),
                _buildInputArea(),
              ],
            ),
            if (_isDropdownVisible)
              Positioned(
                top: 60,
                right: 16,
                child: _buildProfileDropdown(),
              ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Image.asset(
            'assets/img/sophos_kodiak_logo.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          Text(
            'Olá, ',
            style: const TextStyle(
              color: Color(0xFFE6E6E6),
              fontSize: 24,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            widget.userName,
            style: const TextStyle(
              color: Color(0xFFF6790F),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _toggleDropdown,
            child: const Icon(
              Icons.account_circle,
              color: Color(0xFFE6E6E6),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[_messages.length - 1 - index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFFF6790F)
              : const Color(0xFF454545),
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsCarousel() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildSuggestionButton(
            _suggestions[index]['title']!,
            _suggestions[index]['subtitle']!,
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              logger.d("Nova conversa iniciada");
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF5C5C5C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFFB8B8B8),
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF454545),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? const Color(0xFFF6790F)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      scrollPhysics: BouncingScrollPhysics(),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Mensagem',
                        hintStyle: TextStyle(color: Color(0xFFB8B8B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleVoiceInput,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening
                          ? const Color(0xFFF6790F)
                          : const Color(0xFFB8B8B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE6E6E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Color(0xFF2E2E2E),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDropdownItem(Icons.person_outline, 'Conta'),
          _buildDropdownItem(Icons.history, 'Histórico'),
          _buildDropdownItem(Icons.notifications_none, 'Notificações'),
          const Divider(color: Color(0xFF454545), height: 1),
          _buildDropdownItem(
            Icons.logout,
            'Sair',
            textColor: Colors.red,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(
      IconData icon,
      String text, {
        Color textColor = Colors.white,
        Color iconColor = Colors.white,
      }) {
    return InkWell(
      onTap: () {
        logger.d("Clicou em: $text");
        _toggleDropdown();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionButton(String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _messageController.text = '$title $subtitle';
          _sendMessage();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF454545),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFB8B8B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}