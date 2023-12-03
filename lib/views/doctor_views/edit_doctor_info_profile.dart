import 'package:flutter/material.dart';
import 'package:doctor_dash/controllers/doctor_controller.dart';
import 'package:doctor_dash/models/doctor_model.dart';

class EditDoctorProfile extends StatefulWidget {
  final DoctorModel doctor;
  EditDoctorProfile({required this.doctor});

  @override
  _EditDoctorProfileState createState() => _EditDoctorProfileState();
}

class _EditDoctorProfileState extends State<EditDoctorProfile> {
  final DoctorService _doctorService = DoctorService();
  final _formKey = GlobalKey<FormState>();
  late DoctorModel doctor = widget.doctor;

  late String name;
  late String phone;
  late String email;
  late String specialty;

  @override
  void initState() {
    super.initState();
    name = widget.doctor.name;
    phone = widget.doctor.phone;
    email = widget.doctor.email;
    specialty = widget.doctor.speciality;
  }

  Future<void> _updateDoctorData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      DoctorModel updatedDoctor = DoctorModel(
        doctorId: doctor.doctorId,
        name: name,
        phone: phone,
        email: email,
        speciality: specialty,
        clinicId: doctor.clinicId,
        availability: doctor.availability,
        appointmentId: doctor.appointmentId,
        feedbackId: doctor.feedbackId,
      );
      await _doctorService.updateDoctor(updatedDoctor);
      Navigator.pop(context, updatedDoctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Doctor Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              initialValue: doctor.name,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value!.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                name = value!;
              },
            ),
            TextFormField(
              initialValue: doctor.phone,
              decoration: InputDecoration(labelText: 'Phone'),
              validator: (value) {
                if (value == null || value!.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
              onSaved: (value) {
                phone = value!;
              },
            ),
            TextFormField(
              initialValue: doctor.email,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: false, // Email is not editable
            ),
            TextFormField(
              initialValue: doctor.speciality,
              decoration: InputDecoration(labelText: 'Specialty'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your specialty';
                }
                return null;
              },
              onSaved: (value) {
                specialty = value!;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0),
              child: ElevatedButton(
                onPressed: _updateDoctorData,
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
