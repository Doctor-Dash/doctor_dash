import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String doctorID;
  final String name;
  final String phone;
  final String email;
  final String speciality;
  final List<String> clinicID;
  final List<String> availability;
  final List<String>? appointmentID;
  final List<String>? feedbackID;

  DoctorModel({
    required this.doctorID,
    required this.name,
    required this.phone,
    required this.email,
    required this.speciality,
    required this.clinicID,
    required this.availability,
    this.appointmentID,
    this.feedbackID,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorID': doctorID,
      'name': name,
      'phone': phone,
      'email': email,
      'speciality': speciality,
      'clinicID': clinicID,
      'availability': availability,
      'appointmentID': appointmentID,
      'feedbackID': feedbackID,
    };
  }

  static DoctorModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      doctorID: map['doctorID'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      speciality: map['speciality'] ?? '',
      clinicID: List<String>.from(map['clinicID'] ?? []),
      availability: List<String>.from(map['availability'] ?? []),
      appointmentID: map['appointmentID'] != null
          ? List<String>.from(map['appointmentID'])
          : null,
      feedbackID: map['feedbackID'] != null
          ? List<String>.from(map['feedbackID'])
          : null,
    );
  }
}
