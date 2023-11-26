import 'package:doctor_dash/main.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'doctor_signup.dart'; // Adjust the import path as necessary

class DoctorSignIn extends StatelessWidget {
  const DoctorSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // User is not signed in, show the sign-in screen
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to Doctor Dash, please sign in as a Doctor!')
                    : const Text('Welcome to Doctor Dash, please sign up as a Doctor!'),
              );
            },
          );
        } else {
          // User is signed in, show the main app screen or dashboard
          return DoctorSignUpPage();  // You need to define this widget according to your app's structure
        }
      },
    );
  }
}
