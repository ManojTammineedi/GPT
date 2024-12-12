import 'package:flutter/material.dart';
import 'package:gpt/home.dart';
import 'package:gpt/pages/login_or_register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Checking if the auth state is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If the user is logged in
          final session = snapshot.hasData ? snapshot.data!.session : null;
          if (session != null) {
            return const HomePage(); // Show HomePage if logged in
          }

          // If the user is NOT logged in
          else {
            return const LoginOrRegisterPage(); // Show LoginOrRegisterPage if not logged in
          }
        },
      ),
    );
  }
}
