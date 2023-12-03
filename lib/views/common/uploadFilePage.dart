import 'dart:io';

import 'package:doctor_dash/models/availability_model.dart';
import 'package:doctor_dash/models/clinic_model.dart';
import 'package:doctor_dash/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_model.dart';
import '../../models/appointment_model.dart';
import '../../controllers/patient_controller.dart';
import '../../controllers/appointment_controller.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/clinic_controller.dart';
import '../../controllers/availability_controller.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_detail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UploadFilePage extends StatefulWidget {
  final String appointmentId;

  const UploadFilePage({required this.appointmentId});

  @override
  _UploadFilePageState createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  final AppointmentService appointmentService = AppointmentService();
  final PatientService patientService = PatientService();
  late AppointmentModel appointment;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  bool isPatient = false;

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

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
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

  Future<void> _selectImage() async {
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Image'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_image != null)
                  Image.file(
                    File(_image!.path),
                    height: 100,
                    width: 100, 
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImageFromCamera();
                        setState(() {});
                      },
                      child: const Text('Camera'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImageFromGallery();
                        setState(() {});
                      },
                      child: const Text('Gallery'),
                    ),
                  ],
                ),
                if (_image != null)
                  ElevatedButton(
                    onPressed: () {
                      _uploadImage();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Upload'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
    if (_image != null) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _uploadImage() async {
    try {
      final downloadURL = await appointmentService.uploadImage(
          _image, appointment.appointmentId);
      print('Download URL: $downloadURL');
      if (isPatient) {
        if (appointment.patientFilesPath == null) {
          appointment.patientFilesPath = [];
        }
        appointment.patientFilesPath!.add(downloadURL!);
      } else {
        if (appointment.doctorFilesPath == null) {
          appointment.doctorFilesPath = [];
        }
        appointment.doctorFilesPath!.add(downloadURL!);
      }
      await appointmentService.updateAppointment(appointment);
      _image = null;
      setState(() {});
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> _deleteImage(int index, bool isPatient) async {
    try {
      var imageUrl = appointment.patientFilesPath![index];
      var uri = Uri.parse(imageUrl);
      var filePath = uri.path.split('o/').last.split('?alt').first;
      filePath = Uri.decodeComponent(filePath);
      var firebaseStorageRef = FirebaseStorage.instance.ref().child(filePath);
      await firebaseStorageRef.delete();
      if (isPatient) {
        appointment.patientFilesPath!.removeAt(index);
      } else {
        appointment.doctorFilesPath!.removeAt(index);
      }
      await appointmentService.updateAppointment(appointment);
      setState(() {});
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View/Upload Files'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _selectImage,
            child: const Text('Select Image'),
          ),
          const Text('Patient Files',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: appointment.patientFilesPath == null ||
                    appointment.patientFilesPath!.isEmpty
                ? const Center(child: Text('No patient files'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemCount: appointment.patientFilesPath!.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Image.network(
                                        appointment.patientFilesPath![index]),
                                  );
                                },
                              );
                            },
                            child: Image.network(
                                appointment.patientFilesPath![index]),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteImage(index, isPatient);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Text('Doctor Files',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: appointment.doctorFilesPath == null ||
                    appointment.doctorFilesPath!.isEmpty
                ? const Center(child: Text('No doctor files'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemCount: appointment.doctorFilesPath!.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Image.network(
                                        appointment.patientFilesPath![index]),
                                  );
                                },
                              );
                            },
                            child: Image.network(
                                appointment.doctorFilesPath![index]),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteImage(index, isPatient);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
