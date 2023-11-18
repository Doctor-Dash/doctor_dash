import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clinic_model.dart';

class ClinicService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference clinicCollection;

  ClinicService()
      : clinicCollection = FirebaseFirestore.instance.collection('clinincs');

  Future<DocumentReference<Object?>> addClinic(ClinicModel clinic) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to add a clinic.');
    }
    try {
      return await clinicCollection.add(clinic.toMap());
    } on FirebaseAuthException catch (authError) {
      // Handle Firebase Authentication specific errors
      throw Exception('Authentication Error: ${authError.message}');
    } on FirebaseException catch (firestoreError) {
      // Handle Firestore specific errors
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

  Future<QuerySnapshot> getClinicsInCity(String city) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to get clinics information.');
    }
    try {
      return await clinicCollection.where('city', isEqualTo: city).get();
    } catch (e) {
      throw Exception('Error fetching clinics in city: $e');
    }
  }
}
