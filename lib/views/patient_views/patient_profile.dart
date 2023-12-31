import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_model.dart';
import '../../controllers/patient_controller.dart';
import '../patient_views/edit_patient_profile.dart';
import '../common/appointments.dart';

class PatientProfilePage extends StatefulWidget {
  final String patientId;

  PatientProfilePage({required this.patientId});

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final PatientService patientService = PatientService();
  final _formKey = GlobalKey<FormState>();
  Future<PatientModel> getPatientData() async {
    try {
      QuerySnapshot patientSnapshot =
          await patientService.getPatient(widget.patientId);
      if (patientSnapshot.docs.isNotEmpty) {
        return PatientModel.fromMap(patientSnapshot.docs.first);
      } else {
        throw Exception('Patient not found');
      }
    } catch (e) {
      print('Error retrieving patient data: $e');
      throw Exception('Failed to retrieve patient data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
      ),
      body: FutureBuilder<PatientModel>(
        future: getPatientData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            PatientModel patient = snapshot.data!;
            return Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(15),
                  child: Card(
                    margin: const EdgeInsets.all(15),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Name:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(patient.name),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Phone:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(patient.phone),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Email:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(patient.email),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Age:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('${patient.age}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Weight:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('${patient.weight}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Height:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('${patient.height}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Street:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(patient.street),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('City:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(patient.city),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Province:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(patient.province),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Postal Code:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(patient.postalCode),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 27,
                  right: 27,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final updatedPatient = await Navigator.push<PatientModel>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditPatientProfile(patient: patient),
                        ),
                      );
                      if (updatedPatient != null) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                Column(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Column(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(top: 300),
                                  width: constraints.maxWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AppointmentPage(
                                                    userId: widget.patientId),
                                          ),
                                        );
                                      },
                                      child: const Text('Appointments'),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
