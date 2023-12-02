import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';

class PatientService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference patientCollection;

  PatientService()
      : patientCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('patients');

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

  Future<List<String>> getPatientAppointments(String patientId) async {
    QuerySnapshot querySnapshot =
        await patientCollection.where('patientId', isEqualTo: patientId).get();
    PatientModel patient = PatientModel.fromMap(querySnapshot.docs[0]);
    return patient.appointments ?? [];
  }

  Future<void> updatePatient(PatientModel patient) async {
    print(patient.patientId);
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
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('patients')
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Failed to check if user is a patient: $e');
      rethrow;
    }
  }
}
