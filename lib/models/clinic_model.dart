import 'package:cloud_firestore/cloud_firestore.dart';

class Clinic_model {
  final String Clinic_ID;
  final String Name;
  final String Street;
  final String City;
  final String Province;
  final String Postal_Code;
  final String Phone_Number;
  final String Email;
  final List<String> Doctors;

  Clinic_model({
    required this.Clinic_ID,
    required this.Name,
    required this.Street,
    required this.City,
    required this.Province,
    required this.Postal_Code,
    required this.Phone_Number,
    required this.Email,
    required this.Doctors,
  });

  Map<String, dynamic> toMap() {
    return {
      'Clinic_ID': Clinic_ID,
      'Name': Name,
      'Street': Street,
      'City': City,
      'Province': Province,
      'Postal_Code': Postal_Code,
      'Phone_Number': Phone_Number,
      'Email': Email,
      'Doctors': Doctors,
    };
  }

  static Clinic_model fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Clinic_model(
      Clinic_ID: map['Clinic_ID'] as String,
      Name: map['Name'] as String,
      Street: map['Street'] as String,
      City: map['City'] as String,
      Province: map['Province'] as String,
      Postal_Code: map['Postal_Code'] as String,
      Phone_Number: map['Phone_Number'] as String,
      Email: map['Email'] as String,
      Doctors: map['Doctors'] as List<String>,
    );
  }
}
