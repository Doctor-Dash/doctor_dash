import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_dash/models/doctor_model.dart';
import 'package:doctor_dash/views/auth_views/doctor_or_patient_choice_view.dart';
import 'package:doctor_dash/views/patient_views/doctor_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import './views/doctor_views/doctor_signup.dart';
import './views/doctor_views/doctor_signin.dart';
import './views/auth_views/doctor_or_patient_choice_view.dart';
import 'views/patient_views/patient_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return FutureBuilder<bool>(
              future: isPatient(),
              builder: (context, patientSnapshot) {
                if (patientSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (patientSnapshot.data == true) {
                  // return const MyHomePage(title: "Patient's Search Page:"); //TODO: should be Patient's Search page
                  // Creating a DoctorModel object from the data
                  DoctorModel doctor = DoctorModel(
                    doctorId: 'D1234',
                    name: 'Dr. John Doe',
                    phone: '123-456-7890',
                    email: 'john.doe@example.com',
                    speciality: 'Cardiologist',
                    clinicId: ['clinic1', 'clinic2'],
                    availability: ['Monday', 'Wednesday', 'Friday'],
                    appointmentId: ['app1', 'app2'],
                    feedbackId: ['feedback1', 'feedback2'],
                  );

                  return DoctorDetails(doctor);
                } else {
                  // return const MyHomePage(title: "Doctor's Profile Page:"); //TODO: should be doctor profile page
                  DoctorModel doctor = DoctorModel(
                    doctorId: 'D1234',
                    name: 'Dr. John Doe',
                    phone: '123-456-7890',
                    email: 'john.doe@example.com',
                    speciality: 'Cardiologist',
                    clinicId: ['clinic1'],
                    availability: ['Monday', 'Wednesday', 'Friday'],
                    appointmentId: ['app1', 'app2'],
                    feedbackId: ['feedback1', 'feedback2'],
                  );

                  return DoctorDetails(doctor);
                }
              },
            );
          } else {
            DoctorModel doctor = DoctorModel(
              doctorId: 'D1234',
              name: 'Dr. John Doe',
              phone: '123-456-7890',
              email: 'john.doe@example.com',
              speciality: 'Cardiologist',
              clinicId: ['clinic1'],
              availability: ['Monday', 'Wednesday', 'Friday'],
              appointmentId: ['app1', 'app2'],
              feedbackId: ['feedback1', 'feedback2'],
            );

            return DoctorDetails(doctor);
          }
        },
      ),
    );
  }

  Future<bool> isPatient() async {
    try {
      var patientCollection = FirebaseFirestore.instance.collection('patients');
      var currentUser = FirebaseAuth.instance.currentUser;
      var patientDocument = await patientCollection.doc(currentUser!.uid).get();

      return patientDocument.exists;
    } catch (e) {
      throw ('Failed to check if user is a patient: $e');
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const DoctorOrPatientChoice(),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            String userId = FirebaseAuth.instance.currentUser!.uid;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PatientProfilePage(patientId: userId)),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
