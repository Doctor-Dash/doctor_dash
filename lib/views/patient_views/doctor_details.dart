import 'package:doctor_dash/controllers/clinic_controller.dart';
import 'package:doctor_dash/models/clinic_model.dart';

import '../../controllers/doctor_controller.dart';
import '../../models/doctor_model.dart';
import 'package:flutter/material.dart';
import '../../controllers/availability_controller.dart';

class DoctorDetails extends StatelessWidget {
  final DoctorModel doctor;
  final ClinicService clinicService = ClinicService();

  DoctorDetails(this.doctor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Doctor Info Section
            Text(
              'Doctor Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Name: ${doctor.name}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Speciality: ${doctor.speciality}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: ${doctor.phone}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${doctor.email}',
              style: TextStyle(fontSize: 18),
            ),
            // Add additional doctor details here

            // Clinic Info Section
            SizedBox(height: 16),
            Text(
              'Clinic Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<ClinicModel?>(
              future: clinicService.getClinicOfDoctor(doctor.doctorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while fetching data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data != null) {
                  ClinicModel clinic = snapshot.data!;
                  return Column(
                    children: [
                      Text(
                        'Name: ${clinic.name}',
                        style: TextStyle(fontSize: 20),
                      ),
                      // Add other clinic details here
                    ],
                  );
                } else {
                  return Text('No clinic information available');
                }
              },
            ),
            // Add clinic details here

            ElevatedButton(
              onPressed: () async {
                // Navigate to the create availability screen or show a modal
                // You can use Navigator to push a new screen or showModalBottomSheet for a modal
                // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAvailabilityScreen(doctor)));
                ClinicModel? clinic =
                    await clinicService.getClinicOfDoctor(doctor.doctorId);
                print(clinic);
                print(clinic?.name);
              },
              child: const Text('getClinicOfDoctor'),
            ),
          ],
        ),
      ),
    );
  }
}
