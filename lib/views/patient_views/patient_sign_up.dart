import 'package:doctor_dash/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctor_dash/models/patient_model.dart';
import 'package:doctor_dash/controllers/patient_controller.dart';
import 'package:doctor_dash/utils/utils.dart';

class PatientSignUp extends StatefulWidget {
  const PatientSignUp({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<PatientSignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  final PatientService _patientService = PatientService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(labelText: 'Street'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your street';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _provinceController,
                  decoration: InputDecoration(labelText: 'Province'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your province';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(labelText: 'Postal code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Postal code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _submitForm();
                    }
                  },
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    try {
      String userId = _auth.currentUser!.uid;

      String? userEmail = _auth.currentUser!.email;

      // Create a PatientModel instance using the entered data
      PatientModel newPatient = PatientModel(
        patientId: userId, // Set the patientId to the user ID
        name: _nameController.text,
        phone: _phoneController.text,
        email: userEmail ?? '',
        age: int.parse(_ageController.text),
        weight: int.parse(_weightController.text),
        height: int.parse(_heightController.text),
        street: _streetController.text,
        city: _cityController.text,
        province: _provinceController.text,
        postalCode: _postalCodeController.text,
      );

      _patientService.addPatient(newPatient);
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    // TODO: Navigate to Patient Home Screen (Search Page)
    // Navigate to the next screen or perform other navigation actions
    // Example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(
                  title: 'Search Page',
                )));
  }
}
