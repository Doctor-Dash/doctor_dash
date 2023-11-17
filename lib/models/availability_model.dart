import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityModel {
  final String availabilityId;
  final String doctorId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final List<String>? appointments;

  AvailabilityModel({
    required this.availabilityId,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.appointments,
  });

  Map<String, dynamic> toMap() {
    return {
      'availabilityId': availabilityId,
      'doctorId': doctorId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'appointments': appointments,
    };
  }

  static AvailabilityModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AvailabilityModel(
      availabilityId: data['availabilityId'],
      doctorId: data['doctorId'],
      date: data['date'].toDate(),
      startTime: data['startTime'].toDate(),
      endTime: data['endTime'].toDate(),
      status: data['status'],
      appointments: data['appointments'] != null ? List<String>.from(data['appointments']) : null,
    );
  }
}
