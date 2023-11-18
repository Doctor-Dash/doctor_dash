import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/clinic_model.dart';

class ClinicService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference clinicCollection;

  ClinicService()
      : clinicCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('clinincs');

  Future<DocumentReference<Object?>> addClinic(ClinicModel clinic) async {
    try {
      return await clinicCollection.add(clinic.toMap());
    } catch (e) {
      print('Failed to add clinic: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> getClinic(String clinicId) async {
    try {
      return await clinicCollection
          .where('clinicId', isEqualTo: clinicId)
          .get();
    } catch (e) {
      print('Failed to get clinic: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> getClinicsInCity(String city) async {
    try{
      return await clinicCollection
          .where('city', isEqualTo: city)
          .get();
    } catch (e) {
      print('Failed to get clinics in city: $e');
      rethrow;
    }
  }
}
