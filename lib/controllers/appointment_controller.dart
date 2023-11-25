import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final CollectionReference appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');

  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      await appointmentCollection.add(appointment.toMap());
    } catch (error) {
      throw Exception('Error adding appointment: $error');
    }
  }

  Future<QuerySnapshot> getAppointmentsForPatient(String patientId) async {
    try {
      return await appointmentCollection
          .where('patientId', isEqualTo: patientId)
          .get();
    } catch (error) {
      throw Exception('Error fetching appointments: $error');
    }
  }

  Future<QuerySnapshot> getAppointmentsForDoctor(String doctoerId) async {
    try {
      return await appointmentCollection
          .where('doctoerId', isEqualTo: doctoerId)
          .get();
    } catch (error) {
      throw Exception('Error fetching appointments: $error');
    }
  }

  Future<void> updateAppointment(AppointmentModel updatedAppointment) async {
    try {
      // Assuming updatedAppointment has a valid appointmentId
      final appointmentDoc =
          appointmentCollection.doc(updatedAppointment.appointmentId);
      await appointmentDoc.update(updatedAppointment.toMap());
    } catch (error) {
      throw Exception('Error updating appointment: $error');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final appointmentDoc = appointmentCollection.doc(appointmentId);
      await appointmentDoc.delete();
    } catch (error) {
      throw Exception('Error deleting appointment: $error');
    }
  }

  // You can add more methods as needed for updating, deleting, or retrieving appointments.
}
