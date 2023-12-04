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
import '../patient_views/booking_page.dart';
import '../patient_views/doctor_feedback.dart';
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

  Future<Map<String, List<AppointmentDetails>>> fetchData() async {
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

      DateTime now = DateTime.now().add(Duration(days: 2));
      List<AppointmentDetails> upcomingAppointments = [];
      List<AppointmentDetails> pastAppointments = [];

      for (var detail in appointmentDetailsList) {
        if (detail.availability!.startTime.isAfter(now)) {
          upcomingAppointments.add(detail);
        } else {
          pastAppointments.add(detail);
        }
      }

      return {'upcoming': upcomingAppointments, 'past': pastAppointments};
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
      body: FutureBuilder<Map<String, List<AppointmentDetails>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Center(child: Text('You have no appointments'));
          }

          var upcomingAppointments = snapshot.data?['upcoming'] ?? [];
          var pastAppointments = snapshot.data?['past'] ?? [];

          return Column(
            children: [
              _buildSection(
                  'Upcoming Appointments', upcomingAppointments, false),
              _buildSection('Past Appointments', pastAppointments, true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<AppointmentDetails> appointments,
      bool isPastAppointment) {
    if (appointments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No $title'),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) =>
                  _buildAppointmentTile(appointments[index], isPastAppointment),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(
      AppointmentDetails appointmentDetails, bool isPastAppointment) {
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPastAppointment)
                ElevatedButton(
                  onPressed: () => _navigateToBookingPage(appointmentDetails),
                  child: const Text('Reschedule'),
                ),
              if (isPastAppointment)
                ElevatedButton(
                  onPressed: () =>
                      _navigateToFeedbackPage(appointmentDetails.doctor!),
                  child: const Text('Feedback'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBookingPage(AppointmentDetails appointmentDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BookingPage(
                doctorId: appointmentDetails.doctor!.doctorId,
                clinicId: appointmentDetails.clinic!.clinicId,
                existingAppointmentId: appointmentDetails.appointmentId,
                existingAvailabilityId:
                    appointmentDetails.availability!.availabilityId,
                isEdit: true,
              )),
    ).then((_) {
      setState(() {});
    });
  }

  void _navigateToFeedbackPage(DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorFeedback(doctor)),
    ).then((_) {
      setState(() {});
    });
  }

  void _navigateToAppointmentDetails(String appointmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsPage(
            appointmentId: appointmentId, userId: widget.userId),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}
