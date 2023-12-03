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

  @override
  void initState() {
    super.initState();
    checkPatient();
  }

  Future<void> checkPatient() async {
    isPatient = await patientService.isPatient();
    setState(() {});
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

      print(appointmentDetails);
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
            final date = dateFormatDate.format(appointmentTime.startTime);
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
                                    ? appointment.doctor.name
                                    : appointment.patient.name),
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
                                    ? appointment.clinic.phoneNumber
                                    : appointment.patient.phone),
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
                                        fontWeight: FontWeight.bold)),
                                Text(isPatient
                                    ? '${appointment.clinic.street} ${appointment.clinic.city} ${appointment.clinic.province} ${appointment.clinic.postalCode}'
                                    : '${appointment.patient.street} ${appointment.patient.city} ${appointment.patient.province} ${appointment.patient.postalCode}'),
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
                                      Text('${appointment.patient.age}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text('Weight:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('${appointment.patient.weight}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      const Text('Height:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('${appointment.patient.height}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
}
