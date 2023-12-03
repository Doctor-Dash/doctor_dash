import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';

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
      final QuerySnapshot querySnapshot = await appointmentCollection
          .where('appointmentId', isEqualTo: updatedAppointment.appointmentId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming appointmentId is unique, we can safely take the first match.
        final DocumentSnapshot appointmentDoc = querySnapshot.docs.first;
        await appointmentDoc.reference.update(updatedAppointment.toMap());
      } else {
        throw Exception('Appointment not found');
      }
    } catch (e) {
      throw Exception('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    _ensureAuthenticated();

    try {
      // Query for appointments with the matching appointmentId
      final QuerySnapshot querySnapshot = await appointmentCollection
          .where('appointmentId', isEqualTo: appointmentId)
          .get();

      // Iterate through the documents and delete each one
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error deleting appointment: $e');
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
