import 'package:flutter/material.dart';
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
  final TextEditingController _emailController = TextEditingController();

  final ClinicService _clinicService = ClinicService();

 void _submitClinic() async {
  if (_formKey.currentState!.validate()) {
    try {
      await _clinicService.addClinic(
        name: _nameController.text,
        street: _streetController.text,
        city: _cityController.text,
        province: _provinceController.text,
        postalCode: _postalCodeController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        doctors: [] // Assuming an empty list of doctors for now
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Clinic details submitted successfully')),
      );

      // Pop with true to indicate a successful clinic addition
      Navigator.of(context).pop(true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit clinic details: $error')),
      );
    }
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter clinic name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(labelText: 'Street Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _provinceController,
                decoration: InputDecoration(labelText: 'Province'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter province';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(labelText: 'Postal Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter postal code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
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
