import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class AppointmentService {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference appointmentCollection;

  AppointmentService()
      : appointmentCollection =
            FirebaseFirestore.instance.collection('appointments');

  Future<DocumentReference> addAppointment(AppointmentModel appointment) async {
    _ensureAuthenticated();

    try {
      return await appointmentCollection.add(appointment.toMap());
    } on FirebaseAuthException catch (authError) {
      throw Exception('Authentication Error: ${authError.message}');
    } on FirebaseException catch (firestoreError) {
      throw Exception('Firestore Error: ${firestoreError.message}');
    }
  }

  Future<QuerySnapshot> getAppointmentsForPatient(String patientId) async {
    _ensureAuthenticated();

    try {
      return await appointmentCollection
          .where('patientId', isEqualTo: patientId)
          .get();
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  Future<QuerySnapshot> getAppointmentsForDoctor(String doctorId) async {
    _ensureAuthenticated();

    try {
      return await appointmentCollection
          .where('doctorId', isEqualTo: doctorId)
          .get();
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  Future<void> updateAppointment(AppointmentModel updatedAppointment) async {
    _ensureAuthenticated();

    try {
      final appointmentDoc = appointmentCollection
          .where('appointmentId', isEqualTo: updatedAppointment.appointmentId)
          .get();
      await appointmentDoc.then((appointmentDoc) {
        appointmentDoc.docs.first.reference.update(updatedAppointment.toMap());
      });
    } catch (e) {
      throw Exception('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    _ensureAuthenticated();

    try {
      final appointmentDoc = appointmentCollection.doc(appointmentId);
      await appointmentDoc.delete();
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
    }
  }

  Future<QuerySnapshot> getAppointment(String appointmentId) async {
    _ensureAuthenticated();

    try {
      return await appointmentCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .get();
    } catch (e) {
      throw Exception('Error fetching appointment: $e');
    }
  }

  Future<String?> uploadImage(image, String appointmentId) async {
    String? downloadURL;
    if (image == null) return null;

    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('images/$appointmentId/${image!.name}');
    try {
      final uploadTask = await firebaseStorageRef.putFile(File(image!.path));

      if (uploadTask.state == TaskState.success) {
        downloadURL = await firebaseStorageRef.getDownloadURL();
      }
      return downloadURL;
    } catch (e) {
      throw ("Server Error: $e");
    }
  }

  void _ensureAuthenticated() {
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unauthenticated',
        message: 'User must be logged in to perform this operation.',
      );
    }
  }
}
