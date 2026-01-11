import 'dart:async';
import 'dart:io'; // موجود أصلاً
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:safe_space/analysis_screen.dart'; // موجود وصحيح

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}

class _VoiceSettings {
  final String language;
  final String voiceType;

  _VoiceSettings({required this.language, required this.voiceType});
}

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? chatTitle;
  final String? selectedLanguage;

  const ChatScreen({
    super.key,
    this.chatId,
    this.chatTitle,
    this.selectedLanguage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showChatHistory = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _serverUrl = 'http://172.20.10.12.:5000';
  User? _currentUser;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  _VoiceSettings _voiceSettings = _VoiceSettings(language: 'en-US', voiceType: 'male');
  String? _currentChatId;
  bool _isDarkMode = false;
  ChatMessage? _typingMessage;

  // Colors inspired by the logo
  static const Color primaryTeal = Color(0xFF2DB5A5);
  static const Color darkTeal = Color(0xFF1A8B7F);
  static const Color lightTeal = Color(0xFF4DD0C0);
  static const Color accentTeal = Color(0xFF7FDED6);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
        if (_currentUser != null) {
          if (_currentChatId == null) {
            _messages.insert(
              0,
              ChatMessage(
                text: "Hello ${_currentUser!.displayName ?? 'friend'}! How can I assist you today?",
                isUserMessage: false,
                timestamp: DateTime.now(),
              ),
            );
          }
          if (_currentChatId != null) {
            _loadChatHistory();
          }
        }
      });
    });
    _initTts();
    _initSpeech();
    _currentChatId = widget.chatId;
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<void> _initTts() async {
    await _updateTtsSettings();
    List<dynamic> voices = await _flutterTts.getVoices;
    debugPrint('Available voices: $voices');
  }

  Future<void> _updateTtsSettings() async {
    await _flutterTts.setLanguage(_voiceSettings.language);
    await _flutterTts.setPitch(_voiceSettings.voiceType == 'female' ? 1.2 : 0.8);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);

    List<dynamic> voices = await _flutterTts.getVoices;
    String? selectedVoice;
    for (var voice in voices) {
      if (voice['locale'] == _voiceSettings.language &&
          voice['name'].toLowerCase().contains(_voiceSettings.voiceType)) {
        selectedVoice = voice['name'];
        break;
      }
    }
    if (selectedVoice != null) {
      await _flutterTts.setVoice({'name': selectedVoice, 'locale': _voiceSettings.language});
    }
  }

  Future<void> _speak(String text) async {
    if (!_isSpeaking) {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
      await _flutterTts.awaitSpeakCompletion(true);
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        _showSnackBar('Speech recognition error: ${error.errorMsg}');
      },
    );
    if (!available && mounted) {
      _showSnackBar('Speech recognition is not available');
    }
  }

  void _startListening() async {
    if (!_isListening) {
      await _initSpeech();
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _textController.text = _recognizedText;
          });
          if (result.finalResult) {
            if (_recognizedText.isNotEmpty) {
              _handleSubmitted(_recognizedText);
            }
            setState(() => _isListening = false);
          }
        },
        localeId: _voiceSettings.language,
      );
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _showVoiceSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? darkCard : darkTeal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Voice Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _voiceSettings.language,
                dropdownColor: _isDarkMode ? darkCard : darkTeal,
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'en-US', child: Text('English')),
                  DropdownMenuItem(value: 'ar-SA', child: Text('Arabic')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _voiceSettings = _VoiceSettings(
                        language: value,
                        voiceType: _voiceSettings.voiceType,
                      );
                    });
                    _updateTtsSettings();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _voiceSettings.voiceType,
                dropdownColor: _isDarkMode ? darkCard : darkTeal,
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male Voice')),
                  DropdownMenuItem(value: 'female', child: Text('Female Voice')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _voiceSettings = _VoiceSettings(
                        language: _voiceSettings.language,
                        voiceType: value,
                      );
                    });
                    _updateTtsSettings();
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: lightTeal, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    if (_currentChatId == null || _currentUser == null) return;

    try {
      final query = await _firestore
          .collection('chats')
          .where('chat_id', isEqualTo: _currentChatId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _messages.clear();
        for (var doc in query.docs) {
          final data = doc.data();
          _messages.add(ChatMessage(
            text: data['prompt'],
            isUserMessage: true,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          ));
          _messages.add(ChatMessage(
            text: data['response'],
            isUserMessage: false,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          ));
        }
      });
    } catch (e) {
      _showSnackBar('Error loading chat history: $e');
    }
  }

  Future<Map<String, dynamic>> _analyzeMentalState() async {
    if (_currentUser == null) {
      return {'status': 'error', 'message': 'User is not logged in'};
    }
    try {
      final query = await _firestore
          .collection('chats')
          .where('user_id', isEqualTo: _currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();

      final allMessages = query.docs.map((doc) => doc.data()).toList();

      final response = await http.post(
        Uri.parse('$_serverUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': allMessages,
          'user_id': _currentUser!.uid,
        }),
      );

      if (response.statusCode == 500) {
        return jsonDecode(response.body);
      }
      return {'status': 'empty', 'message': 'Server returned no data'};
    } on SocketException {
      return {
        'status': 'empty',
        'message': 'Server is not available. Analysis data will be empty during testing.',
        'dominant_emotion': null,
        'needs_specialist': false,
        'specialist_type': null,
        'advice': [],
        'risk_level': null
      };
    } on TimeoutException {
      return {
        'status': 'empty',
        'message': 'Request timed out. Analysis data will be empty during testing.',
        'dominant_emotion': null,
        'needs_specialist': false,
        'specialist_type': null,
        'advice': [],
        'risk_level': null
      };
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        return {
          'status': 'error',
          'message': 'Please create an index in Firebase Console for user_id and timestamp'
        };
      }
      return {'status': 'error', 'message': e.toString()};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  void _navigateToAnalysis() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final result = await _analyzeMentalState();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['status'] != 'error') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisScreen(
            analysisResult: result,
            userName: _currentUser?.displayName ?? 'User',
          ),
        ),
      );
    } else {
      _showSnackBar(result['message']);
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading || _currentUser == null) return;

    _textController.clear();

    final userMsg = ChatMessage(
      text: text,
      isUserMessage: true,
      timestamp: DateTime.now(),
    );

    final typingMsg = ChatMessage(
      text: 'Saraa is typing...',
      isUserMessage: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMsg);
      _typingMessage = typingMsg;
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': text,
          'user_id': _currentUser!.uid,
          'chat_id': _currentChatId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'language': _voiceSettings.language,
        }),
      ).timeout(const Duration(minutes: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['response']?.toString() ?? 'Sorry, I could not process your request.';

        setState(() {
          _messages.remove(_typingMessage);
          _typingMessage = null;
          _messages.insert(
            0,
            ChatMessage(
              text: botResponse,
              isUserMessage: false,
              timestamp: DateTime.now(),
            ),
          );
        });

        await _saveChatToFirestore(text, botResponse);
        if (_voiceSettings.language == 'en-US') {
          await _speak(botResponse);
        }
      } else {
        _showSnackBar('Server error: ${response.statusCode}');
      }
    } on SocketException {
      _showSnackBar('Network error: Server is not available. Please try again later.');
    } on TimeoutException {
      _showSnackBar('Request timed out. Please try again.');
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _typingMessage = null;
        });
      }
    }
  }

  Future<void> _saveChatToFirestore(String prompt, String response) async {
    if (_currentUser == null) return;

    try {
      final chatId = _currentChatId ?? DateTime.now().millisecondsSinceEpoch.toString();
      _currentChatId = chatId;

      await _firestore.collection('chats').add({
        'user_id': _currentUser!.uid,
        'chat_id': chatId,
        'prompt': prompt,
        'response': response,
        'timestamp': FieldValue.serverTimestamp(),
        'language': _voiceSettings.language,
      });
    } catch (e) {
      _showSnackBar('Error saving chat: $e');
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle ?? 'Safe Space Chat'),
        backgroundColor: _isDarkMode ? darkSurface : primaryTeal,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded),
            tooltip: 'Analyze Mental State',
            onPressed: _navigateToAnalysis,
          ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: _toggleDarkMode,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Chat History',
            onPressed: () {
              setState(() => _showChatHistory = !_showChatHistory);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _isDarkMode
              ? const LinearGradient(
                  colors: [darkBackground, darkSurface],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [primaryTeal, darkTeal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _showChatHistory ? _buildChatHistory() : _buildChatList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

Widget _buildChatList() {
  final totalMessages = [..._messages];
  if (_typingMessage != null) {
    totalMessages.insert(0, _typingMessage!);
  }

  return ListView.builder(
    reverse: true,
    padding: const EdgeInsets.all(16),
    itemCount: totalMessages.length,
    itemBuilder: (context, index) {
      final message = totalMessages[index];
      return _buildMessageBubble(message);
    },
  );
}

  Widget _buildMessageBubble(ChatMessage message) {
    final isUserMessage = message.isUserMessage;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isDarkMode ? darkCard : accentTeal.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? (_isDarkMode ? lightTeal.withOpacity(0.8) : lightTeal)
                    : (_isDarkMode ? darkCard : Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isUserMessage ? const Radius.circular(16) : const Radius.circular(4),
                  topRight: isUserMessage ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUserMessage
                      ? (_isDarkMode ? lightTeal : Colors.white.withOpacity(0.3))
                      : (_isDarkMode ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUserMessage) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isDarkMode ? darkCard : lightTeal.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ],
          if (!isUserMessage) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.volume_up_rounded),
              color: lightTeal,
              onPressed: () => _isSpeaking ? _stopSpeaking() : _speak(message.text),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where('user_id', isEqualTo: _currentUser?.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading chat history', style: TextStyle(color: Colors.white)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: lightTeal));
        }
        final chats = snapshot.data?.docs ?? [];
        final groupedChats = <String, List<DocumentSnapshot>>{};
        for (var doc in chats) {
          final chatId = doc['chat_id'] as String;
          groupedChats.putIfAbsent(chatId, () => []).add(doc);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedChats.keys.length,
          itemBuilder: (context, index) {
            final chatId = groupedChats.keys.elementAt(index);
            final chatDocs = groupedChats[chatId]!;
            final firstMessage = chatDocs.first.data() as Map<String, dynamic>;
            final title = firstMessage['prompt']?.toString().substring(0, 30) ?? 'Chat $chatId';

            return Card(
              color: _isDarkMode ? darkCard : Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format((firstMessage['timestamp'] as Timestamp).toDate()),
                  style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.white70),
                ),
                onTap: () {
                  setState(() {
                    _currentChatId = chatId;
                    _showChatHistory = false;
                  });
                  _loadChatHistory();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? darkSurface : darkTeal,
        border: Border(top: BorderSide(color: _isDarkMode ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off_rounded : Icons.mic_rounded),
            color: lightTeal,
            onPressed: _startListening,
            tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
          ),
          IconButton(
            icon: const Icon(Icons.settings_voice_rounded),
            color: lightTeal,
            onPressed: _showVoiceSettingsDialog,
            tooltip: 'Voice Settings',
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.white70),
                filled: true,
                fillColor: _isDarkMode ? darkCard : Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator(color: lightTeal)
                : const Icon(Icons.send_rounded),
            color: lightTeal,
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
            tooltip: 'Send Message',
          ),
        ],
      ),
    );
  }
}