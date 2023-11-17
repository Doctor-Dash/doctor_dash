import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicModel {
  final String clinicID;
  final String name;
  final String street;
  final String city;
  final String province;
  final String postalCode;
  final String phoneNumber;
  final String email;
  final List<String> doctors;

  ClinicModel({
    required this.clinicID,
    required this.name,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.phoneNumber,
    required this.email,
    required this.doctors,
  });

  Map<String, dynamic> toMap() {
    return {
      'clinicID': clinicID,
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
      clinicID: map['clinicID'] as String,
      name: map['name'] as String,
      street: map['street'] as String,
      city: map['city'] as String,
      province: map['province'] as String,
      postalCode: map['postalCode'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      doctors: List<String>.from(map['doctors']),
    );
  }
}
