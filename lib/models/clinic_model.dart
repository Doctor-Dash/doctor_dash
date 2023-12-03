import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicModel {
  final String clinicId;
  final String name;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final String phoneNumber;
  final String email;
  List<String> doctors; 

  ClinicModel({
    required this.clinicId,
    required this.name,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.phoneNumber,
    required this.email,
    this.doctors = const [], 
  });

  Map<String, dynamic> toMap() {
    return {
      'clinicId': clinicId,
      'name': name,
      'street': street,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'phoneNumber': phoneNumber,
      'email': email,
      'doctors': doctors,
    };
  }

  static ClinicModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return ClinicModel(
      clinicId: map['clinicId'] as String,
      name: map['name'] as String,
      street: map['street'] as String,
      city: map['city'] as String,
      province: map['province'] as String,
      postalCode: map['postalCode'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      doctors: map['doctors'] != null ? List<String>.from(map['doctors']) : [],
    );
  }

  @override
  String toString() {
    return 'ClinicModel {clinicId: $clinicId, name: $name, street: $street, city: $city, province: $province, postalCode: $postalCode, phoneNumber: $phoneNumber, email: $email, doctors: $doctors}';
  }
}
