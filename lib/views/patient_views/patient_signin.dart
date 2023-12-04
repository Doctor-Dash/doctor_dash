import 'package:doctor_dash/views/auth_views/password_reset_view.dart';
import 'package:doctor_dash/views/patient_views/patient_signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_dash/views/patient_views/patient_home.dart';

class PatientSignIn extends StatefulWidget {
  const PatientSignIn({super.key});

  @override
  _PatientSignInState createState() => _PatientSignInState();
}

class _PatientSignInState extends State<PatientSignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _errorMessage = '';

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PatientHome()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        final regex = RegExp(r'\[([^)]+)\]');
        final match = regex.firstMatch(e.message ?? '');
        String extractedError = match?.group(1) ?? 'Invalid email';
        _errorMessage = extractedError.toLowerCase().replaceAll('_', ' ');
        _errorMessage =
            _errorMessage[0].toUpperCase() + _errorMessage.substring(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_errorMessage,
                    style: const TextStyle(color: Colors.black)),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => PatientSignUp()),
                );
              },
              child: const Text('Don’t have an account? Sign up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PasswordResetView()),
                );
              },
              child: const Text('Forgot Password? Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
