import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String availabilityId;
  final String clinicId;
  List<String>? doctorFilesPath;
  List<String>? patientFilesPath;
  List<String>? doctorNotes;
  List<String>? patientNotes;

  AppointmentModel({
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.availabilityId,
    required this.clinicId,
    this.doctorFilesPath,
    this.patientFilesPath,
    this.doctorNotes,
    this.patientNotes,
  });

  static AppointmentModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      appointmentId: map['appointmentId'] as String,
      doctorId: map['doctorId'] as String,
      patientId: map['patientId'] as String,
      availabilityId: map['availabilityId'] as String,
      clinicId: map['clinicId'] as String,
      doctorFilesPath: map['doctorFilesPath'] != null
          ? (map['doctorFilesPath'] as List<dynamic>)
              .map((item) => item as String)
              .toList()
          : null,
      patientFilesPath: map['patientFilesPath'] != null
          ? (map['patientFilesPath'] as List<dynamic>)
              .map((item) => item as String)
              .toList()
          : null,
      doctorNotes: map['doctorNotes'] != null
          ? (map['doctorNotes'] as List<dynamic>)
              .map((item) => item as String)
              .toList()
          : null,
      patientNotes: map['patientNotes'] != null
          ? (map['patientNotes'] as List<dynamic>)
              .map((item) => item as String)
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'availabilityId': availabilityId,
      'clinicId': clinicId,
      'doctorFilesPath': doctorFilesPath,
      'patientFilesPath': patientFilesPath,
      'doctorNotes': doctorNotes,
      'patientNotes': patientNotes,
    };
  }

  @override
  String toString() {
    return 'AppointmentModel {appointmentId: $appointmentId, doctorId: $doctorId, patientId: $patientId, availabilityId: $availabilityId, clinicId: $clinicId, doctorFilesPath: $doctorFilesPath, patientFilesPath: $patientFilesPath, doctorNotes: $doctorNotes, patientNotes: $patientNotes}';
  }
}
