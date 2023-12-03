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
  late AppointmentModel appointment;
  late AppointmentDetails appointmentDetails;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isPatient = await patientService.isPatient();
      QuerySnapshot appointmentSnapshot;

      appointmentSnapshot =
          await appointmentService.getAppointment(widget.userId);

      if (isPatient) {
        appointmentSnapshot =
            await appointmentService.getAppointmentsForPatient(widget.userId);
      } else {
        appointmentSnapshot =
            await appointmentService.getAppointmentsForDoctor(widget.userId);
      }

      appointment = AppointmentModel.fromMap(appointmentSnapshot.docs.first);

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

      appointmentDetails = AppointmentDetails(
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

      print(appointmentDetails);
      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
