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

  List<AppointmentModel> appointments = [];
  List<AppointmentDetails> appointmentDetailsList = [];
  bool isPatient = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isPatient = await patientService.isPatient();
      QuerySnapshot appointmentSnapshot;

      if (isPatient) {
        appointmentSnapshot =
            await appointmentService.getAppointmentsForPatient(widget.userId);
      } else {
        appointmentSnapshot =
            await appointmentService.getAppointmentsForDoctor(widget.userId);
      }

      appointments = appointmentSnapshot.docs
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
          b.availability.startTime.compareTo(a.availability.startTime));
      setState(() {});
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
      body: appointmentDetailsList.isEmpty
          ? const Center(child: Text('You have no appointments'))
          : ListView.builder(
              itemCount: appointmentDetailsList.length,
              itemBuilder: (context, index) {
                final appointmentDetails = appointmentDetailsList[index];
                final appointmentTime = appointmentDetails.availability;
                final dateFormatDate = DateFormat('d MMM yyyy');
                final dateFormatTime = DateFormat('h:mm a');
                final date = dateFormatDate.format(appointmentTime.startTime);
                final startTime =
                    dateFormatTime.format(appointmentTime.startTime);
                final endTime = dateFormatTime.format(appointmentTime.endTime);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        // Handle card tap
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isPatient
                              ? appointmentDetails.doctor.name
                              : appointmentDetails.patient.name),
                          Text('$date : $startTime - $endTime'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
