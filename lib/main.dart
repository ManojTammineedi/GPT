import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gpt/auth/auth_gate.dart';
import 'package:gpt/consts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


const apiKey = 'AIzaSyALJCi62Ts6X1z_Syu1j5LadXqbT4SjPf0'; // Replace with your actual Gemini API key.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://idbgbaybqckkzdckvbza.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkYmdiYXlicWNra3pkY2t2YnphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM5MjYxMjQsImV4cCI6MjA0OTUwMjEyNH0.cLvDTUOmm44fW-1q4OPAwO7VPlSslpgNAdiRAsGAG9Q',
  );
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'GPT',
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
