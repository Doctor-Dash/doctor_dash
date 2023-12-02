import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clinic_model.dart';

class ClinicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ClinicService();

  Future<DocumentReference> addClinic(ClinicModel clinic) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to add a clinic.');
    }

    try {
      return await _firestore.collection('clinics').add(clinic.toMap());
    } catch (e) {
      throw Exception('Error adding clinic: $e');
    }
  }

  Future<QuerySnapshot> getClinic(String clinicId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to get clinic information.');
    }

    try {
      return await _firestore.collection('clinics').where('clinicId', isEqualTo: clinicId).get();
    } catch (e) {
      throw Exception('Error fetching clinic: $e');
    }
  }

  Future<List<String>> getClinicsInCity(String city) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User must be logged in to get clinics information.');
    }

    try {
      var querySnapshot = await _firestore.collection('clinics').where('city', isEqualTo: city).get();
      return querySnapshot.docs
          .map((doc) => ClinicModel.fromMap(doc).clinicId)
          .toList();
    } catch (e) {
      throw Exception('Error fetching clinics in city: $e');
    }
  }

Future<List<Map<String, String>>> streamClinicNamesAndIds() async {
  var querySnapshot = await _firestore.collection('clinics').get();

  return querySnapshot.docs.map((doc) {
    var clinic = ClinicModel.fromMap(doc);
    return {
      'id': clinic.clinicId, 
      'name': clinic.name,
    };
  }).toList();
}
}