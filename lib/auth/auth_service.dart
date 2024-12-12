import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    // Step 1: Sign up the user
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Step 2: Check if the sign-up was successful and insert user data into the 'users' table
    if (response.user != null) {
      final userId = response.user!.id; // Get the user ID
      final createdAt = DateTime.now()
          .toIso8601String(); // Current date and time in ISO format

      try {
        await _supabase.from('users').insert(
          {
            'id': userId,
            'email': email,
            'created_at': createdAt, // Add the date explicitly
          },
        );
      } catch (e) {
        print('Error inserting user data: $e');
      }
    }
    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  String? getCurrentUserid() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }
}
