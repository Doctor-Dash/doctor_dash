import 'package:doctor_dash/main.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class DoctorSignIn extends StatelessWidget {
  const DoctorSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
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
        }

        return const MyHomePage(
            title:
                'Doctor Sign Up Page'); //TODO: should be doctor sign up page
      },
    );
  }
}
