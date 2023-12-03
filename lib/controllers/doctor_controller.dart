import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_model.dart';

class DoctorService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference doctorsCollection;

  DoctorService()
      : doctorsCollection = FirebaseFirestore.instance.collection('doctors');

  Future<void> addDoctor(DoctorModel doctor) async {
    if (user == null) {
      throw FirebaseAuthException(
          code: 'unauthenticated',
          message: 'User must be logged in to add a doctor.');
    }
    try {
      await doctorsCollection.doc(doctor.doctorId).set(doctor.toMap());
    } on FirebaseAuthException catch (authError) {
      throw Exception('Authentication Error: ${authError.message}');
    } on FirebaseException catch (firestoreError) {
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
      throw Exception('Firestore Error: ${firestoreError.message}');
    }
  }

  Future<List<DoctorModel>> getDoctors(
      String speciality, List<String> cityClinicId) async {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to view doctors.',
      );
    }

    try {
      var doctorsQuery = doctorsCollection
          .where('speciality', isEqualTo: speciality)
          .where('clinicId', arrayContainsAny: cityClinicId);

      var doctorsSnapshot = await doctorsQuery.get();
      return doctorsSnapshot.docs
          .map((doc) => DoctorModel.fromMap(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Error fetching doctors list: ${e.message}');
    } catch (e) {
      return [];
    }
  }

  Future<QuerySnapshot> getDoctor(String doctorId) async {
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

  Future<void> addAppointmentIdToDoctor(
      String doctorId, String appointmentId) async {
    try {
      QuerySnapshot doctorsQuery =
          await doctorsCollection.where('doctorId', isEqualTo: doctorId).get();

      if (doctorsQuery.docs.isNotEmpty) {
        DocumentSnapshot doctorDoc = doctorsQuery.docs.first;
        DoctorModel doctor = DoctorModel.fromMap(doctorDoc);

        if (doctor.appointmentId == null) {
          doctor.appointmentId = [appointmentId];
        } else {
          doctor.appointmentId!.add(appointmentId);
        }

        await doctorsCollection.doc(doctorId).update(doctor.toMap());
      } else {
        throw Exception('No document found with the doctorId: $doctorId');
      }
    } catch (e) {
      throw Exception('Failed to add appointment ID to doctor: $e');
    }
  }
}
