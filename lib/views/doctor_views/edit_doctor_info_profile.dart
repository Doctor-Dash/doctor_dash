import 'package:flutter/material.dart';
import 'package:doctor_dash/controllers/doctor_controller.dart';
import 'package:doctor_dash/models/doctor_model.dart';
import 'package:doctor_dash/utils/specialties.dart';

class EditDoctorProfile extends StatefulWidget {
  final DoctorModel doctor;
  EditDoctorProfile({required this.doctor});

  @override
  _EditDoctorProfileState createState() => _EditDoctorProfileState();
}

class _EditDoctorProfileState extends State<EditDoctorProfile> {
  final DoctorService _doctorService = DoctorService();
  final _formKey = GlobalKey<FormState>();
  late DoctorModel doctor;
  
  late String name;
  late String phone;
  late String email;
  late String currentSpecialty;  

  @override
  void initState() {
    super.initState();
    doctor = widget.doctor;  
    name = doctor.name;
    phone = doctor.phone;
    email = doctor.email;
    currentSpecialty = doctor.speciality;  
  }

  Future<void> _updateDoctorData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      DoctorModel updatedDoctor = DoctorModel(
        doctorId: doctor.doctorId,
        name: name,
        phone: phone,
        email: email,
        speciality: currentSpecialty,  
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
              enabled: false, 
            ),
 DropdownButtonFormField<String>(
              value: currentSpecialty,
              decoration: InputDecoration(
                labelText: 'Specialty',
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  currentSpecialty = newValue!;
                });
              },
              items: MedicalSpecialistsUtil.getSpecialists().map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) => value == null ? 'Please select a specialty' : null,
              onSaved: (value) {
                 currentSpecialty = value!;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
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
