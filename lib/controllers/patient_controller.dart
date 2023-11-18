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

  Future<DocumentReference<Object?>> addPatient(PatientModel patient) async {
    return patientCollection.add(patient.toMap());
  }

  Future<QuerySnapshot> getPatient(String patientId) async {
    return patientCollection.where('patientId', isEqualTo: patientId).get();
  }

  Future<QuerySnapshot> getPatientAppointments(String patientId) async {
    var appointmentIds =
        patientCollection.doc(patientId).collection('appointments').get();
    return appointmentIds;
  }
}
