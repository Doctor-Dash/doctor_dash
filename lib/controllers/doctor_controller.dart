import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';

class DoctorService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference doctorsCollection;

  DoctorService()
      : doctorsCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('Doctors');

  Future<DocumentReference<Object?>> addDoctor(DoctorModel doctor) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to add a doctor.');
    }
    try {
      return await doctorsCollection.add(doctor.toMap());
    } on FirebaseAuthException catch (authError) {
      // Handle Firebase Authentication specific errors
      throw Exception('Authentication Error: ${authError.message}');
    } on FirebaseException catch (firestoreError) {
      // Handle Firestore specific errors
      throw Exception('Firestore Error: ${firestoreError.message}');
    }
  }

  Future<void> removeDoctor(String doctorId) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to remove a doctor.');
    }
    try {
      await doctorsCollection.doc(doctorId).delete();
    } on FirebaseException catch (firestoreError) {
      // Handle Firestore specific errors
      throw Exception('Firestore Error: ${firestoreError.message}');
    }
  }

  Future<void> updateDoctor(DoctorModel doctor) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to update a doctor.');
    }
    try {
      await doctorsCollection.doc(doctor.doctorId).update(doctor.toMap());
    } on FirebaseException catch (firestoreError) {
      // Handle Firestore specific errors
      throw Exception('Firestore Error: ${firestoreError.message}');
    }
  }

  // Get list of doctors by search parameters (input doctor_speciality, List<String> clinic_id's in city of user)
  Future<List<DoctorModel>> getDoctors(
      String speciality, List<String> cityClinicId) async {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to view doctors.',
      );
    }

    try {
      // Fetch doctors with the specified specialty and clinic IDs
      var doctorsQuery = doctorsCollection
          .where('speciality', isEqualTo: speciality)
          .where('clinicId', arrayContainsAny: cityClinicId);

      var doctorsSnapshot = await doctorsQuery.get();
      return doctorsSnapshot.docs
          .map((doc) => DoctorModel.fromMap(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching doctors list: $e');
    }
  }

  Future<QuerySnapshot<Object?>> getDoctor(String doctorId) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to view doctors.');
    }
    try {
      return await doctorsCollection
          .where('doctorId', isEqualTo: doctorId)
          .get();
    } catch (e) {
      throw Exception('Error fetching doctor: $e');
    }
  }
}