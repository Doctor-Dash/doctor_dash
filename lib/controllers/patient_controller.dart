import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
}
