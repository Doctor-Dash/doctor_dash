import 'package:flutter/material.dart';
import 'package:doctor_dash/controllers/clinic_controller.dart';
import 'package:doctor_dash/models/clinic_model.dart';

class EditClinicInfoProfile extends StatefulWidget {
  final ClinicModel clinic;

  EditClinicInfoProfile({required this.clinic});

  @override
  _EditClinicInfoProfileState createState() => _EditClinicInfoProfileState();
}

class _EditClinicInfoProfileState extends State<EditClinicInfoProfile> {
  final ClinicService _clinicService = ClinicService();
  final _formKey = GlobalKey<FormState>();

  late String name;
  late String street;
  late String city;
  late String province;
  late String postalCode;

  @override
  void initState() {
    super.initState();
    name = widget.clinic.name;
    street = widget.clinic.street;
    city = widget.clinic.city;
    province = widget.clinic.province;
    postalCode = widget.clinic.postalCode;
  }

  Future<void> _updateClinicData() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    ClinicModel updatedClinic = ClinicModel(
      clinicId: widget.clinic.clinicId,
      name: name,
      street: street,
      city: city,
      province: province,
      postalCode: postalCode,
      phoneNumber: widget.clinic.phoneNumber,
      email: widget.clinic.email,
      doctors: widget.clinic.doctors,
    );

    try {
      await _clinicService.updateClinic(updatedClinic);
      Navigator.pop(context, updatedClinic);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update clinic: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Clinic Info'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildTextField(
              initialValue: name,
              label: 'Name',
              onSaved: (value) => name = value!,
            ),
            _buildTextField(
              initialValue: street,
              label: 'Street',
              onSaved: (value) => street = value!,
            ),
            _buildTextField(
              initialValue: city,
              label: 'City',
              onSaved: (value) => city = value!,
            ),
            _buildTextField(
              initialValue: province,
              label: 'Province',
              onSaved: (value) => province = value!,
            ),
            _buildTextField(
              initialValue: postalCode,
              label: 'Postal Code',
              onSaved: (value) => postalCode = value!,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: _updateClinicData,
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String label,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}
