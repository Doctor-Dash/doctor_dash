import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_model.dart';
import 'availability_model.dart';
import 'clinic_model.dart';
import 'doctor_model.dart';
import 'patient_model.dart';

class AppointmentDetails {
  final String appointmentId;
  final DoctorModel doctor;
  final PatientModel patient;
  final ClinicModel clinic;
  final AvailabilityModel availability;
  final List<String>? doctorFilesPath;
  final List<String>? patientFilesPath;
  final List<String>? doctorNotes;
  final List<String>? patientNotes;

  AppointmentDetails({
    required this.appointmentId,
    required this.doctor,
    required this.patient,
    required this.clinic,
    required this.availability,
    this.doctorFilesPath,
    this.patientFilesPath,
    this.doctorNotes,
    this.patientNotes,
  });

  static AppointmentDetails fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return AppointmentDetails(
      appointmentId: doc.id,
      doctor: DoctorModel.fromMap(map['doctor']),
      patient: PatientModel.fromMap(map['patient']),
      clinic: ClinicModel.fromMap(map['clinic']),
      availability: AvailabilityModel.fromMap(map['availability']),
      doctorFilesPath: map['doctorFilesPath'] as List<String>?,
      patientFilesPath: map['patientFilesPath'] as List<String>?,
      doctorNotes: map['doctorNotes'] as List<String>?,
      patientNotes: map['patientNotes'] as List<String>?,
    );
  }

  @override
  String toString() {
    return 'AppointmentDetails { appointmentId: $appointmentId, doctor: $doctor, patient: $patient, clinic: $clinic, availability: $availability, doctorFilesPath: $doctorFilesPath, patientFilesPath: $patientFilesPath, doctorNotes: $doctorNotes, patientNotes: $patientNotes}';
  }
}
