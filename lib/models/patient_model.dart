import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String patientId;
  final String name;
  final String phone;
  final String email;
  final int age;
  final int weight;
  final int height;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final List<String>? appointments;

  PatientModel({
    required this.patientId,
    required this.name,
    required this.phone,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    this.appointments,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'name': name,
      'phone': phone,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'street': street,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'appointments': appointments,
    };
  }

  static PatientModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      patientId: data['patientId'],
      name: data['name'],
      phone: data['phone'],
      email: data['email'],
      age: data['age'],
      weight: data['weight'],
      height: data['height'],
      street: data['street'],
      city: data['city'],
      province: data['province'],
      postalCode: data['postalCode'],
      appointments: data['appointments'],
    );
  }
}
