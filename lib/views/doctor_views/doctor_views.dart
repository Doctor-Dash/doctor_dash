import 'package:flutter/material.dart';

class DoctorSignUpPage extends StatefulWidget {
  @override
  _DoctorSignUpPageState createState() => _DoctorSignUpPageState();
}

class _DoctorSignUpPageState extends State<DoctorSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Define controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController clinicNameController = TextEditingController();
  TextEditingController clinicLocationController = TextEditingController();
  TextEditingController specialtyController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      await _selectTime(context, isStartTime: true);
      await _selectTime(context, isStartTime: false);
    }
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? startTime ?? TimeOfDay.now()
          : endTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  void _editTime(BuildContext context) async {
    if (selectedDate != null) {
      await _selectTime(context, isStartTime: true);
      await _selectTime(context, isStartTime: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: clinicNameController,
                decoration: InputDecoration(labelText: 'Clinic Name'),
              ),
              TextFormField(
                controller: clinicLocationController,
                decoration: InputDecoration(labelText: 'Clinic Location'),
              ),
              TextFormField(
                controller: specialtyController,
                decoration: InputDecoration(labelText: 'Specialty'),
              ),
              SizedBox(height: 16.0),
              OutlinedButton(
                onPressed: () => _selectDate(context),
                child: Text(selectedDate == null
                    ? 'Select Appointment Date and Time'
                    : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}, Time: ${startTime?.format(context)} - ${endTime?.format(context)}'),
              ),
              if (selectedDate != null)
                TextButton(
                  onPressed: () => _editTime(context),
                  child: Text('Edit Time'),
                ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Validate form
                  // TODO: Send data to Firestore (handled in controller)
                  // Replace with actual data handling when controller is ready
                  // For now, just print the data
                  print('Name: ${nameController.text}');
                  print('Phone: ${phoneController.text}');
                  // ... other prints
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
