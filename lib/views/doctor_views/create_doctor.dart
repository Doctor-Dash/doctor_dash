import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_dash/controllers/doctor_controller.dart';
import 'package:doctor_dash/models/doctor_model.dart';
import 'package:doctor_dash/utils/specialties.dart';
import 'package:doctor_dash/controllers/clinic_controller.dart';
import 'doctor-clinic.dart'; 

class DoctorSignUpPage extends StatefulWidget {
  const DoctorSignUpPage({super.key});

  @override
  _DoctorSignUpPageState createState() => _DoctorSignUpPageState();
}

class _DoctorSignUpPageState extends State<DoctorSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? selectedSpecialty;
  String? selectedClinicId;
  List<Map<String, String>> clinics = [];
  final ClinicService clinicService = ClinicService(); 

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  void _loadClinics() async {
    var fetchedClinics = await clinicService.streamClinicNamesAndIds();
    setState(() {
      clinics = fetchedClinics;
    });
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No authenticated user found. Please log in.')),
        );
        return;
      }

      try {
        String userId = currentUser.uid;
        String userEmail = currentUser.email ?? '';
        DoctorModel doctor = DoctorModel(
          doctorId: userId,
          name: nameController.text,
          phone: phoneController.text,
          email: userEmail,
          speciality: selectedSpecialty ?? '',
          clinicId: selectedClinicId != null ? [selectedClinicId!] : [],
          availability: [],
          appointmentId: [],
          feedbackId: [],
        );

        DoctorService doctorService = DoctorService();
        await doctorService.addDoctor(doctor);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor details successfully added')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add doctor details: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> specialtyItems = MedicalSpecialistsUtil.getSpecialists()
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Signup'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Speciality'),
                onChanged: (newValue) {
                  setState(() {
                    selectedSpecialty = newValue;
                  });
                },
                items: specialtyItems,
                validator: (value) => value == null ? 'Please select your specialty' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Clinic'),
                value: selectedClinicId,
                onChanged: (newValue) {
                  setState(() {
                    selectedClinicId = newValue;
                  });
                },
                items: clinics.map((clinic) {
                  return DropdownMenuItem<String>(
                    value: clinic['id'],
                    child: Text(clinic['name'] ?? 'Unknown Clinic'),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a clinic' : null,
              ),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
