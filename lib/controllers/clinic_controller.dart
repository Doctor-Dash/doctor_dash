import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clinic_model.dart';

class ClinicService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference clinicCollection;

  ClinicService()
      : clinicCollection = FirebaseFirestore.instance.collection('clinics');

  Future<DocumentReference> addClinic(ClinicModel clinic) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to add a clinic.');
    }
    try {
      return await clinicCollection.add(clinic.toMap());
    } on FirebaseAuthException catch (authError) {
      throw Exception('Authentication Error: ${authError.message}');
    } on FirebaseException catch (firestoreError) {
      throw Exception('Firestore Error: ${firestoreError.message}');
    }
  }

  Future<QuerySnapshot> getClinic(String clinicId) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to get clinic information.');
    }
    try {
      return await clinicCollection
          .where('clinicId', isEqualTo: clinicId)
          .get();
    } catch (e) {
      throw Exception('Error fetching clinic: $e');
    }
  }

  Future<ClinicModel?> getClinicOfDoctor(String doctorId) async {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to get clinic information.',
      );
    }
    try {
      var querySnapshot = await clinicCollection
          .where('doctors', arrayContains: doctorId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return ClinicModel.fromMap(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching clinic of doctor: $e');
    }
  }

  Future<List<String>> getClinicsInCity(String city) async {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to get clinics information.',
      );
    }
    try {
      var querySnapshot =
          await clinicCollection.where('city', isEqualTo: city).get();
      return querySnapshot.docs
          .map((doc) => ClinicModel.fromMap(doc).clinicId)
          .toList();
    } catch (e) {
      throw Exception('Error fetching clinics in city: $e');
    }
  }
}
