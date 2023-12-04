import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/appointment_controller.dart';

class UploadNotePage extends StatefulWidget {
  final String appointmentId;

  const UploadNotePage({required this.appointmentId});

  @override
  _UploadNotePageState createState() => _UploadNotePageState();
}

class _UploadNotePageState extends State<UploadNotePage> {
  final AppointmentService appointmentService = AppointmentService();
  final PatientService patientService = PatientService();
  late AppointmentModel appointment;
  bool isPatient = false;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    checkPatient();
  }

  Future<void> checkPatient() async {
    try {
      isPatient = await patientService.isPatient();
      setState(() {});
    } catch (e) {
      print('Error checking patient: $e');
      rethrow;
    }
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot appointmentSnapshot =
          await appointmentService.getAppointment(widget.appointmentId);
      if (appointmentSnapshot.docs.isNotEmpty) {
        appointment = AppointmentModel.fromMap(appointmentSnapshot.docs.first);
        setState(() {});
      } else {
        throw Exception('Appointment not found');
      }
    } catch (e) {
      print('Error retrieving appointment data: $e');
      rethrow;
    }
  }

  void addNote(String note) async {
    try {
      if (isPatient) {
        if (appointment.patientNotes == null) {
          appointment.patientNotes = [];
        }
        appointment.patientNotes!.add(note);
      } else {
        if (appointment.doctorNotes == null) {
          appointment.doctorNotes = [];
        }
        appointment.doctorNotes!.add(note);
      }
      await appointmentService.updateAppointment(appointment);
      setState(() {});
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  void deleteNote(int index, bool isPatientNote) async {
    try {
      if (isPatientNote) {
        appointment.patientNotes!.removeAt(index);
      } else {
        appointment.doctorNotes!.removeAt(index);
      }
      await appointmentService.updateAppointment(appointment);
      setState(() {});
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  Future<void> showAddNoteDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: TextField(
            controller: noteController,
            maxLength: 200,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                addNote(noteController.text);
                noteController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View/Upload Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddNoteDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add Note',
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Text('Patient Notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: appointment.patientNotes?.length ?? 0,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                  child: Card(
                    child: ListTile(
                      title: Text(appointment.patientNotes![
                          appointment.patientNotes!.length - 1 - index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteNote(
                              appointment.patientNotes!.length - 1 - index,
                              true);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 5),
          Center(
            child: Text('Doctor Notes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: appointment.doctorNotes?.length ?? 0,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                  child: Card(
                    child: ListTile(
                      title: Text(appointment.doctorNotes![
                          appointment.doctorNotes!.length - 1 - index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteNote(
                              appointment.doctorNotes!.length - 1 - index,
                              false);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
