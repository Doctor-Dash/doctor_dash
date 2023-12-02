import 'package:flutter/material.dart';
import '../../models/patient_model.dart';
import '../../controllers/patient_controller.dart';

class EditPatientProfile extends StatefulWidget {
  final PatientModel patient;

  EditPatientProfile({required this.patient});

  @override
  _EditPatientProfileState createState() => _EditPatientProfileState();
}

class _EditPatientProfileState extends State<EditPatientProfile> {
  final PatientService patientService = PatientService();
  final _formKey = GlobalKey<FormState>();
  late PatientModel patient = widget.patient;

  late String patientId;
  late String name;
  late String phone;
  late String email;
  late int age;
  late int weight;
  late int height;
  late String street;
  late String city;
  late String province;
  late String postalCode;
  late List<String>? appointments;

  @override
  void initState() {
    super.initState();
    patientId = widget.patient.patientId;
    name = widget.patient.name;
    phone = widget.patient.phone;
    email = widget.patient.email;
    age = widget.patient.age;
    weight = widget.patient.weight;
    height = widget.patient.height;
    street = widget.patient.street;
    city = widget.patient.city;
    province = widget.patient.province;
    postalCode = widget.patient.postalCode;
    appointments = widget.patient.appointments;
  }

  Future<void> _updatePatientData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      PatientModel updatedPatient = PatientModel(
        patientId: patientId,
        name: name,
        phone: phone,
        email: email,
        age: age,
        weight: weight,
        height: height,
        street: street,
        city: city,
        province: province,
        postalCode: postalCode,
        appointments: appointments,
      );
      await patientService.updatePatient(updatedPatient);
      Navigator.pop(context, updatedPatient);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              initialValue: patient.name,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                name = value!;
              },
            ),
            TextFormField(
              initialValue: patient.phone,
              decoration: InputDecoration(labelText: 'Phone'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
              onSaved: (value) {
                phone = value!;
              },
            ),
            TextFormField(
              initialValue: patient.email,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: false, 
            ),
            TextFormField(
              initialValue: patient.age.toString(),
              decoration: InputDecoration(labelText: 'Age'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                return null;
              },
              onSaved: (value) {
                age = int.parse(value!);
              },
            ),
            TextFormField(
              initialValue: patient.weight.toString(),
              decoration: InputDecoration(labelText: 'Weight'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                return null;
              },
              onSaved: (value) {
                weight = int.parse(value!);
              },
            ),
            TextFormField(
              initialValue: patient.height.toString(),
              decoration: InputDecoration(labelText: 'Height'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your height';
                }
                return null;
              },
              onSaved: (value) {
                height = int.parse(value!);
              },
            ),
            TextFormField(
              initialValue: patient.street,
              decoration: InputDecoration(labelText: 'Street'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your street';
                }
                return null;
              },
              onSaved: (value) {
                street = value!;
              },
            ),
            TextFormField(
              initialValue: patient.city,
              decoration: InputDecoration(labelText: 'City'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
              onSaved: (value) {
                city = value!;
              },
            ),
            TextFormField(
              initialValue: patient.province,
              decoration: InputDecoration(labelText: 'Province'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your province';
                }
                return null;
              },
              onSaved: (value) {
                province = value!;
              },
            ),
            TextFormField(
              initialValue: patient.postalCode,
              decoration: InputDecoration(labelText: 'Postal Code'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your postal code';
                }
                return null;
              },
              onSaved: (value) {
                postalCode = value!;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0),
              child: ElevatedButton(
                onPressed: _updatePatientData,
                child: Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
