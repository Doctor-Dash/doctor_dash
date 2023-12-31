import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_dash/models/doctor_model.dart';
import 'package:doctor_dash/utils/specialties.dart';
import 'package:doctor_dash/controllers/clinic_controller.dart';
import 'package:doctor_dash/controllers/doctor_controller.dart';
import 'package:doctor_dash/controllers/availability_controller.dart';
import 'package:doctor_dash/views/doctor_views/doctor_profile.dart';
import 'package:doctor_dash/views/doctor_views/doctor_clinic.dart';

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
  final AvailabilityService _availabilityService = AvailabilityService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  void _loadClinics() async {
    try {
      var fetchedClinics = await clinicService.streamClinicNamesAndIds();
      setState(() {
        clinics = fetchedClinics;
      });
    } catch (error) {
      print('Error loading clinics: $error');
    }
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No authenticated user found. Please log in.')),
        );
        setState(() => _isLoading = false); 
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
        await _availabilityService.createAvailabilitySignup(userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorProfilePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add doctor details: ${e.toString()}')),
        );
        setState(() => _isLoading = false); 
      } finally {
        setState(() => _isLoading = false); 
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
                validator: (value) =>
                    value == null ? 'Please select your specialty' : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                      validator: (value) =>
                          value == null ? 'Please select a clinic' : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ClinicViewPage()),
                      );

                      if (result == true) {
                        _loadClinics();
                      }
                    },
                    child: const Text('Add Clinic'),
                  ),
                ],
              ),
              _isLoading 
                ? Center(child: CircularProgressIndicator()) 
                : ElevatedButton(
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
