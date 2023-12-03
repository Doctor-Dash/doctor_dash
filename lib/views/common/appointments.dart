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
import 'appointmentDetails.dart';

class AppointmentPage extends StatefulWidget {
  final String userId;

  AppointmentPage({required this.userId});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final PatientService patientService = PatientService();
  final AppointmentService appointmentService = AppointmentService();
  final DoctorService doctorService = DoctorService();
  final ClinicService clinicService = ClinicService();
  final AvailabilityService availabilityService = AvailabilityService();
  bool isPatient = false;

  @override
  void initState() {
    super.initState();
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

  Future<List<AppointmentDetails>> fetchData() async {
    try {
      QuerySnapshot appointmentSnapshot;
      List<AppointmentDetails> appointmentDetailsList = [];

      if (isPatient) {
        appointmentSnapshot =
            await appointmentService.getAppointmentsForPatient(widget.userId);
      } else {
        appointmentSnapshot =
            await appointmentService.getAppointmentsForDoctor(widget.userId);
      }

      List<AppointmentModel> appointments = appointmentSnapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc))
          .toList();

      for (var appointment in appointments) {
        QuerySnapshot doctorSnapshot =
            await doctorService.getDoctor(appointment.doctorId);
        DoctorModel doctor = DoctorModel.fromMap(doctorSnapshot.docs.first);

        QuerySnapshot patientSnapshot =
            await patientService.getPatient(appointment.patientId);
        PatientModel patient = PatientModel.fromMap(patientSnapshot.docs.first);

        QuerySnapshot clinicSnapshot =
            await clinicService.getClinic(appointment.clinicId);
        ClinicModel clinic = ClinicModel.fromMap(clinicSnapshot.docs.first);

        QuerySnapshot availabilitySnapshot = await availabilityService
            .getAvailability(appointment.availabilityId);
        AvailabilityModel availability =
            AvailabilityModel.fromMap(availabilitySnapshot.docs.first);

        appointmentDetailsList.add(AppointmentDetails(
          appointmentId: appointment.appointmentId,
          doctor: doctor,
          patient: patient,
          clinic: clinic,
          availability: availability,
          doctorFilesPath: appointment.doctorFilesPath,
          patientFilesPath: appointment.patientFilesPath,
          doctorNotes: appointment.doctorNotes,
          patientNotes: appointment.patientNotes,
        ));
      }
      appointmentDetailsList.sort((a, b) =>
          b.availability!.startTime.compareTo(a.availability!.startTime));

      return appointmentDetailsList;
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
      body: FutureBuilder<List<AppointmentDetails>>(
        future: fetchData(),
        builder: (context, snapshot) => _buildBodyBasedOnSnapshot(snapshot),
      ),
    );
  }

  Widget _buildBodyBasedOnSnapshot(
      AsyncSnapshot<List<AppointmentDetails>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('You have no appointments'));
    }
    return _buildAppointmentList(snapshot.data!);
  }

  Widget _buildAppointmentList(
      List<AppointmentDetails> appointmentDetailsList) {
    return ListView.builder(
      itemCount: appointmentDetailsList.length,
      itemBuilder: (context, index) =>
          _buildAppointmentTile(appointmentDetailsList[index]),
    );
  }

  Widget _buildAppointmentTile(AppointmentDetails appointmentDetails) {
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');
    final startTime =
        dateFormat.format(appointmentDetails.availability!.startTime);
    final endTime = dateFormat.format(appointmentDetails.availability!.endTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: ListTile(
          onTap: () =>
              _navigateToAppointmentDetails(appointmentDetails.appointmentId),
          title: Text(isPatient
              ? appointmentDetails.doctor!.name
              : appointmentDetails.patient!.name),
          subtitle: Text('$startTime - $endTime'),
        ),
      ),
    );
  }

  void _navigateToAppointmentDetails(String appointmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsPage(
            appointmentId: appointmentId, userId: widget.userId),
      ),
    );
  }
}
