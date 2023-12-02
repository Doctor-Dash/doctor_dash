import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/clinic_model.dart';

class ClinicService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference clinicCollection;

  ClinicService() : clinicCollection = FirebaseFirestore.instance.collection('clinics');

  Future<DocumentReference> addClinic({
    required String name,
    required String street,
    required String city,
    required String province,
    required String postalCode,
    required String phoneNumber,
    required String email,
    required List<String> doctors,
  }) async {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to add a clinic.'
      );
    }

    String clinicId = Uuid().v4();
    ClinicModel clinic = ClinicModel(
      clinicId: clinicId,
      name: name,
      street: street,
      city: city,
      province: province,
      postalCode: postalCode,
      phoneNumber: phoneNumber,
      email: email,
      doctors: doctors,
    );

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

 Future<List<Map<String, String>>> streamClinicNamesAndIds() async {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to access clinics.'
      );
    }

    try {
      var querySnapshot = await clinicCollection.get();
      return querySnapshot.docs.map((doc) {
        var clinic = ClinicModel.fromMap(doc);
        return {
          'id': clinic.clinicId, 
          'name': clinic.name,
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching clinic names and IDs: $e');
    }
  }
}
