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
import 'uploadFilePage.dart';
import 'upload_note_page.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class AppointmentDetailsPage extends StatefulWidget {
  final String userId;
  final String appointmentId;

  AppointmentDetailsPage({required this.appointmentId, required this.userId});

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final PatientService patientService = PatientService();
  final AppointmentService appointmentService = AppointmentService();
  final DoctorService doctorService = DoctorService();
  final ClinicService clinicService = ClinicService();
  final AvailabilityService availabilityService = AvailabilityService();
  bool isPatient = false;
  bool isPast = false;

  @override
  void initState() {
    super.initState();
    checkPatient();
    fetchData();
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

  Future<AppointmentDetails> fetchData() async {
    try {
      QuerySnapshot appointmentSnapshot =
          await appointmentService.getAppointment(widget.appointmentId);

      AppointmentModel appointment =
          AppointmentModel.fromMap(appointmentSnapshot.docs.first);

      QuerySnapshot doctorSnapshot =
          await doctorService.getDoctor(appointment.doctorId);
      DoctorModel doctor = DoctorModel.fromMap(doctorSnapshot.docs.first);

      QuerySnapshot patientSnapshot =
          await patientService.getPatient(appointment.patientId);
      PatientModel patient = PatientModel.fromMap(patientSnapshot.docs.first);

      QuerySnapshot clinicSnapshot =
          await clinicService.getClinic(appointment.clinicId);
      ClinicModel clinic = ClinicModel.fromMap(clinicSnapshot.docs.first);

      QuerySnapshot availabilitySnapshot =
          await availabilityService.getAvailability(appointment.availabilityId);
      AvailabilityModel availability =
          AvailabilityModel.fromMap(availabilitySnapshot.docs.first);

      AppointmentDetails appointmentDetails = AppointmentDetails(
        appointmentId: appointment.appointmentId,
        doctor: doctor,
        patient: patient,
        clinic: clinic,
        availability: availability,
        doctorFilesPath: appointment.doctorFilesPath,
        patientFilesPath: appointment.patientFilesPath,
        doctorNotes: appointment.doctorNotes,
        patientNotes: appointment.patientNotes,
      );
      return appointmentDetails;
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Detail'),
      ),
      body: FutureBuilder<AppointmentDetails>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            AppointmentDetails appointment = snapshot.data!;
            final appointmentTime = appointment.availability;
            final dateFormatDate = DateFormat('d MMM yyyy');
            final dateFormatTime = DateFormat('h:mm a');
            final date = dateFormatDate.format(appointmentTime!.startTime);
            final startTime = dateFormatTime.format(appointmentTime.startTime);
            final endTime = dateFormatTime.format(appointmentTime.endTime);
            return ListView(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Card(
                    margin: const EdgeInsets.all(15),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Center(
                              child: Text(
                                'Appointment Info',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Name:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(isPatient
                                    ? appointment.doctor!.name
                                    : appointment.patient!.name),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text('Time:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('$date : $startTime - $endTime'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                    isPatient
                                        ? 'Clinic Phone:'
                                        : 'Patient Phone:',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(isPatient
                                    ? appointment.clinic!.phoneNumber
                                    : appointment.patient!.phone),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  isPatient
                                      ? 'Clinic Address:'
                                      : 'Patient Address:',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Flexible(
                                  child: Text(
                                    isPatient
                                        ? '${appointment.clinic!.street} ${appointment.clinic!.city} ${appointment.clinic!.province} ${appointment.clinic!.postalCode}'
                                        : '${appointment.patient!.street} ${appointment.patient!.city} ${appointment.patient!.province} ${appointment.patient!.postalCode}',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                isPatient
                    ? Container()
                    : Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: Card(
                          margin: const EdgeInsets.all(15),
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Center(
                                    child: Text(
                                      'Patient Info',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text('Age:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('${appointment.patient!.age}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text('Weight:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('${appointment.patient!.weight}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text('Height:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('${appointment.patient!.height}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UploadFilePage(
                                        appointmentId:
                                            appointment.appointmentId),
                                  ),
                                );
                              },
                              child: Text('Upload File'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UploadNotePage(
                                        appointmentId:
                                            appointment.appointmentId),
                                  ),
                                );
                              },
                              child: Text('Upload Notes'),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await generatePDF(appointment);
                          },
                          child: Text('Download as PDF'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Uint8List?> loadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      return response.bodyBytes;
    } catch (e) {
      throw Exception('Could not load image $imageUrl: $e');
    }
  }

  Future<void> generatePDF(AppointmentDetails appointment) async {
    var doctorImages = await Future.wait(
      (appointment.doctorFilesPath?.map((path) async {
                try {
                  if (path.isNotEmpty) {
                    var image = await loadImage(path);
                    return image;
                  } else {
                    return null;
                  }
                } catch (e) {
                  throw Exception('Error loading doctor image: $e');
                }
              }) ??
              const Iterable<Future<Uint8List?>>.empty())
          .toList(),
    );

    var patientImages = await Future.wait(
      (appointment.patientFilesPath?.map((path) async {
                try {
                  if (path.isNotEmpty) {
                    var image = await loadImage(path);
                    return image;
                  } else {
                    return null;
                  }
                } catch (e) {
                  throw Exception('Error loading patient image: $e');
                }
              }) ??
              const Iterable<Future<Uint8List?>>.empty())
          .toList(),
    );

    var patientNotes =
        (appointment.patientNotes?.map((note) => note).toList()) ?? [];

    var doctorNotes =
        (appointment.doctorNotes?.map((note) => note).toList()) ?? [];

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(child: pw.Text('Appointment Details')),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text('Doctor: ${appointment.doctor!.name}')),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text('Patient: ${appointment.patient!.name}')),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text('Clinic: ${appointment.clinic!.name}')),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                  'Clinic Address: ${appointment.clinic!.street} ${appointment.clinic!.city} ${appointment.clinic!.province} ${appointment.clinic!.postalCode}')),
          pw.SizedBox(height: 10),
          pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                  'Appointment Time: ${DateFormat('h:mm a d MMM yyyy').format(appointment.availability!.startTime)}')),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Doctor Notes:')),
          doctorNotes.isNotEmpty
              ? pw.Column(
                  children: doctorNotes
                      .map((note) => pw.Padding(
                          padding: const pw.EdgeInsets.all(5.0),
                          child: pw.Column(
                            children: [
                              pw.Text(note),
                              pw.SizedBox(height: 10),
                            ],
                          )))
                      .toList(),
                )
              : pw.Center(child: pw.Text('Not available')),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Patient Notes:')),
          patientNotes.isNotEmpty
              ? pw.Column(
                  children: patientNotes
                      .map((note) => pw.Padding(
                          padding: const pw.EdgeInsets.all(5.0),
                          child: pw.Column(
                            children: [
                              pw.Text(note),
                              pw.SizedBox(height: 10),
                            ],
                          )))
                      .toList(),
                )
              : pw.Center(child: pw.Text('Not available')),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Doctor Files:')),
          doctorImages.any((image) => image != null)
              ? pw.Center(
                  child: pw.Wrap(
                    alignment: pw.WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: doctorImages
                        .map((image) => image != null
                            ? pw.Container(
                                width: 200,
                                height: 200,
                                child: pw.Image(pw.MemoryImage(image)),
                              )
                            : pw.Container())
                        .toList(),
                  ),
                )
              : pw.Center(child: pw.Text('Not available')),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('Patient Files:')),
          patientImages.any((image) => image != null)
              ? pw.Center(
                  child: pw.Wrap(
                    alignment: pw.WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: patientImages
                        .map((image) => image != null
                            ? pw.Container(
                                width: 200,
                                height: 200,
                                child: pw.Image(pw.MemoryImage(image)),
                              )
                            : pw.Container())
                        .toList(),
                  ),
                )
              : pw.Center(child: pw.Text('Not available')),
        ],
      ),
    );

    DateTime startTime = appointment.availability!.startTime;
    String formattedTime = DateFormat('h:mm a d MMM yyyy').format(startTime);

    String fileName =
        '${isPatient ? appointment.doctor!.name : appointment.patient!.name}$formattedTime${appointment.clinic!.street}${appointment.clinic!.city}${appointment.clinic!.province}${appointment.clinic!.postalCode}.pdf';

    await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
  }
}
