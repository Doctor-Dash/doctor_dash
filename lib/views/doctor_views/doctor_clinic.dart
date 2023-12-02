import 'package:flutter/material.dart';
import 'package:doctor_dash/views/doctor_views/create_doctor.dart'; 
import 'package:doctor_dash/models/clinic_model.dart';
import 'package:doctor_dash/controllers/clinic_controller.dart';
class ClinicViewPage extends StatefulWidget {
  const ClinicViewPage({Key? key}) : super(key: key);

  @override
  _ClinicViewPageState createState() => _ClinicViewPageState();
}

class _ClinicViewPageState extends State<ClinicViewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final ClinicService _clinicService = ClinicService(); // Clinic service instance

  void _submitClinic() async {
    if (_formKey.currentState!.validate()) {
      // Create a new ClinicModel
      ClinicModel clinic = ClinicModel(
        clinicId: '', // Firestore will auto-generate this ID
        name: _nameController.text,
        street: _streetController.text,
        city: _cityController.text,
        province: _provinceController.text,
        postalCode: _postalCodeController.text,
        phoneNumber: _phoneNumberController.text,
        email: '', // Email field is not included
        doctors: [] // List of doctors is not included
      );

      // Save the clinic details using ClinicService
      _clinicService.addClinic(clinic).then((docRef) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Clinic details submitted successfully')),
        );
        // Optionally clear the form fields here
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit clinic details: $error')),
        );
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Clinic Details'),
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Clinic Name'),
              validator: (value) => value != null && value.isEmpty ? 'Please enter clinic name' : null,
            ),
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(labelText: 'Street Address'),
              validator: (value) => value != null && value.isEmpty ? 'Please enter street address' : null,
            ),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
              validator: (value) => value != null && value.isEmpty ? 'Please enter city' : null,
            ),
            TextFormField(
              controller: _provinceController,
              decoration: InputDecoration(labelText: 'Province'),
              validator: (value) => value != null && value.isEmpty ? 'Please enter province' : null,
            ),
            TextFormField(
              controller: _postalCodeController,
              decoration: InputDecoration(labelText: 'Postal Code'),
              validator: (value) => value != null && value.isEmpty ? 'Please enter postal code' : null,
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                // Add additional validation logic for phone number format if required
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitClinic,
              child: Text('Submit Clinic'),
            ),
          ],
        ),
      ),
    ),
  );
}
}