import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityModel {
  final String availabilityId;
  final String doctorId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool status;
  final String? appointmentId;

  AvailabilityModel({
    required this.availabilityId,
    required this.doctorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.appointmentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'availabilityId': availabilityId,
      'doctorId': doctorId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'appointmentId': appointmentId,
    };
  }

  static AvailabilityModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AvailabilityModel(
        availabilityId: data['availabilityId'] as String,
        doctorId: data['doctorId'] as String,
        date: data['date'].toDate() as DateTime,
        startTime: data['startTime'].toDate() as DateTime,
        endTime: data['endTime'].toDate() as DateTime,
        status: data['status'] as bool,
        appointmentId: data['appointmentId'] as String?);
  }
}
