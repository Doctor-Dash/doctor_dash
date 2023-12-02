import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';

class PatientService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference patientCollection;

  PatientService()
      : patientCollection = FirebaseFirestore.instance.collection('patients');

  Future<DocumentReference> addPatient(PatientModel patient) async {
    try {
      return await patientCollection.add(patient.toMap());
    } catch (e) {
      print('Failed to add patient: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> getPatient(String patientId) async {
    try {
      return await patientCollection
          .where('patientId', isEqualTo: patientId)
          .get();
    } catch (e) {
      print('Failed to get patient: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> getPatientAppointments(String patientId) async {
    try {
      var appointmentIds = await patientCollection
          .doc(patientId)
          .collection('appointments')
          .get();
      return appointmentIds;
    } catch (e) {
      print('Failed to get patient appointments: $e');
      rethrow;
    }
  }

  Future<void> updatePatient(PatientModel patient) async {
    try {
      await patientCollection.doc(patient.patientId).update(patient.toMap());
    } catch (e) {
      print('Failed to update patient: $e');
      rethrow;
    }
  }
}
