import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gpt/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  late String currentEmail = '';
  late String currentId = '';
  late ChatUser _user;
  final supabase = Supabase.instance.client;
  void logout() async {
    await authService.signOut();
  }

  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  // ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
  }

  void _getCurrentUserEmail() async {
    final email = await authService.getCurrentUserEmail();
    final id = await authService.getCurrentUserid();
    setState(() {
      currentEmail = email ?? ''; // Set currentEmail to an empty string if null
      currentId = id ?? ''; // Set currentEmail to an empty string if null
      print('this is my $email');
      _user = ChatUser(
          id: currentId,
          gmail: currentEmail); // Initialize _user with the current email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black87, // Set background color to black
        iconTheme:
            IconThemeData(color: Colors.white), // Set icon color to white
        title: Center(
          child: Text(
            "GPT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Set text color to white
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(
              Icons.logout,
              color: Colors.white, // Ensure logout icon is white
            ),
          )
        ],
      ),
      body: currentEmail.isEmpty &&
              currentId.isEmpty // Check if the email is empty
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            )) // Show loading if the email is not fetched
          : _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: _user,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  Future<void> storeMessage(String userId, String content) async {
    print(DateTime.now().toLocal().toIso8601String());
    try {
      final response = await supabase.from('messages').insert([
        {
          'user_id': userId,
          'content': content,
          'created_at': DateTime.now()
              .toLocal()
              .toIso8601String(), // Explicitly set the timestamp
        }
      ]);

      if (response.error != null) {
        print('Error storing message: ${response.error?.message}');
      } else {
        print('Message stored successfully');
      }
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      print(chatMessage);
      await storeMessage(_user.id, question); // Store user message

      gemini
          .streamGenerateContent(
        question,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(
            () {
              messages = [lastMessage!, ...messages];
            },
          );
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
