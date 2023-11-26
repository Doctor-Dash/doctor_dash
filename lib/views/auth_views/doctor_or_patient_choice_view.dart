// import 'package:doctor_dash/views/doctor_views/doctor_signin.dart';
// import 'package:doctor_dash/views/patient_views.dart/patient_signin.dart';
// import 'package:flutter/material.dart';

// class DoctorOrPatientChoice extends StatelessWidget {
//   const DoctorOrPatientChoice({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Doctor-Patient Sign Up/Login'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Choose your role:',
//               style: TextStyle(fontSize: 20),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const DoctorSignIn()),
//                 );
//               },
//               child: const Text('Doctor'),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const PatientSignIn()),
//                 );
//               },
//               child: const Text('Patient'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
