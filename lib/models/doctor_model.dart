import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String doctorId;
  final String name;
  final String phone;
  final String email;
  final String speciality;
  final List<String> clinicId;
  final List<String> clinicNames; 
  final List<String> availability;
  final List<String>? appointmentId;
  final List<String>? feedbackId;

  DoctorModel({
    required this.doctorId,
    required this.name,
    required this.phone,
    required this.email,
    required this.speciality,
    required this.clinicId,
    required this.clinicNames, 
    required this.availability,
    this.appointmentId,
    this.feedbackId,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'name': name,
      'phone': phone,
      'email': email,
      'speciality': speciality,
      'clinicId': clinicId,
      'clinicNames': clinicNames, 
      'availability': availability,
      'appointmentId': appointmentId,
      'feedbackId': feedbackId,
    };
  }

  static DoctorModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      doctorId: map['doctorId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      speciality: map['speciality'] ?? '',
      clinicId: List<String>.from(map['clinicId'] ?? []),
      clinicNames: List<String>.from(map['clinicNames'] ?? []), 
      availability: List<String>.from(map['availability'] ?? []),
      appointmentId: map['appointmentId'] != null
          ? List<String>.from(map['appointmentId'])
          : null,
      feedbackId: map['feedbackId'] != null
          ? List<String>.from(map['feedbackId'])
          : null,
    );
  }
}
