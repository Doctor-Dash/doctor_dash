// import 'package:doctor_dash/main.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:flutter/material.dart';

// class PatientSignIn extends StatelessWidget {
//   const PatientSignIn({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return SignInScreen(
//             providers: [
//               EmailAuthProvider(),
//             ],
//             subtitleBuilder: (context, action) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: action == AuthAction.signIn
//                     ? const Text(
//                         'Welcome to Doctor Dash, please sign in as a Patient!')
//                     : const Text(
//                         'Welcome to Doctor Dash, please sign up as a Patient!'),
//               );
//             },
//           );
//         }

//         return const MyHomePage(
//             title:
//                 'Flutter Demo Home Page'); //TODO: should be patient sign up page
//       },
//     );
//   }
// }
