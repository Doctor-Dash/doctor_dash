import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';

class PatientService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference patientCollection;

  PatientService()
      : patientCollection = FirebaseFirestore.instance.collection('patients');

  Future<void> addPatient(PatientModel patient) async {
    try {
      await patientCollection.doc(patient.patientId).set(patient.toMap());
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

  Future<List<String>> getPatientAppointments(String patientId) async {
    QuerySnapshot querySnapshot =
        await patientCollection.where('patientId', isEqualTo: patientId).get();
    PatientModel patient = PatientModel.fromMap(querySnapshot.docs[0]);
    return patient.appointments ?? [];
  }

  Future<void> addAppointmentIdToPatient(
      String patientId, String appointmentId) async {
    try {
      DocumentSnapshot patientDoc =
          await patientCollection.doc(patientId).get();

      if (patientDoc.exists) {
        PatientModel patient = PatientModel.fromMap(patientDoc);

        if (patient.appointments == null) {
          patient.appointments = [appointmentId];
        } else {
          patient.appointments!.add(appointmentId);
        }

        await patientCollection.doc(patientId).update(patient.toMap());
      } else {
        throw Exception('No document found with the patientId: $patientId');
      }
    } catch (e) {
      throw Exception('Failed to add appointment ID to patient: $e');
    }
  }

  Future<void> updatePatient(PatientModel patient) async {
    try {
      QuerySnapshot querySnapshot = await patientCollection
          .where('patientId', isEqualTo: patient.patientId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await patientCollection.doc(doc.id).update(patient.toMap());
        }
      } else {
        print('No document found with the patientId: ${patient.patientId}');
      }
    } catch (e) {
      print('Failed to update patient: $e');
      rethrow;
    }
  }

  Future<bool> isPatient() async {
    try {
      var query = await FirebaseFirestore.instance
          .collection('patients')
          .where('patientId', isEqualTo: user!.uid)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Failed to check if user is a patient: $e');
      rethrow;
    }
  }
}
