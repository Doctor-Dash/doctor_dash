import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String patientId;
  final String name;
  final String phone;
  final String email;
  final List<String>? appointments;

  PatientModel({
    required this.patientId,
    required this.name,
    required this.phone,
    required this.email,
    this.appointments,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'name': name,
      'phone': phone,
      'email': email,
      'appointments': appointments,
    };
  }

  static PatientModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      patientId: data['patientId'],
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      appointments: data['appointments'],
    );
  }
}
