import 'package:cloud_firestore/cloud_firestore.dart';

class DocterModel {
  final String doctorID;
  final String name;
  final String phone;
  final String email;
  final String speciality;
  final List<String> clinicID;
  final List<String> availability;
  final List<String>? appointmentID;
  final List<String>? feedbackID;

  DocterModel({
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

  static DocterModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return DocterModel(
      doctorID: map['doctorID'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      speciality: map['speciality'] as String,
      clinicID: List<String>.from(map['clinicID']),
      availability: List<String>.from(map['availability']),
      appointmentID: List<String>.from(map['appointmentID']),
      feedbackID: List<String>.from(map['feedbackID']),
    );
  }
}