import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart'; // Correct the path as necessary

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
      await doctorsCollection.doc(doctor.doctorID).update(doctor.toMap());
    } on FirebaseException catch (firestoreError) {
      // Handle Firestore specific errors
      throw Exception('Firestore Error: ${firestoreError.message}');
    }
  }

  // Get list of doctors by search parameters
  Stream<List<DoctorModel>> getDoctors(
      String speciality, String searchCity) async* {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to view doctors.',
      );
    }

    try {
      // Step 1: Fetch clinics in the specified city
      var clinicsSnapshot = await FirebaseFirestore.instance
          .collection('clinics')
          .where('city', isEqualTo: searchCity)
          .get();

      var clinicIds = clinicsSnapshot.docs.map((doc) => doc.id).toList();

      // Step 2: Fetch doctors with the specified specialty and clinic IDs
      var doctorsQuery = doctorsCollection
          .where('speciality', isEqualTo: speciality)
          .where('clinicID', arrayContainsAny: clinicIds);

      var doctorsSnapshot = await doctorsQuery.get();

      var doctors =
          doctorsSnapshot.docs.map((doc) => DoctorModel.fromMap(doc)).toList();

      yield doctors;
    } catch (e) {
      throw Exception('Error fetching doctors list: $e');
    }
  }

  Future<QuerySnapshot<Object?>> getDoctor(String doctorID) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to view doctors.');
    }
    try {
      return await doctorsCollection
          .where('doctorID', isEqualTo: doctorID)
          .get();
    } catch (e) {
      throw Exception('Error fetching doctor: $e');
    }
  }
}
