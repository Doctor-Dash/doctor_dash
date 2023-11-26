import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/availability_model.dart';

class AvailabilityService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference availabilityCollection;

  AvailabilityService()
      : availabilityCollection =
            FirebaseFirestore.instance.collection('availability');

  Future<void> createAvailabilityForMonth(String doctorId, DateTime startDate) async {
    DateTime nextMonth = DateTime(startDate.year, startDate.month + 1);
    DateTime currentDay = startDate;
    DateTime endOfMonth = DateTime(nextMonth.year, nextMonth.month + 1, 0);

    DateTime startTime =
        DateTime(currentDay.year, currentDay.month, currentDay.day, 9);
    DateTime endTime =
        DateTime(currentDay.year, currentDay.month, currentDay.day, 17);

    while (currentDay.isBefore(endOfMonth)) {
      if (currentDay.weekday >= DateTime.monday &&
          currentDay.weekday <= DateTime.friday) {
        while (startTime.isBefore(endTime)) {
          DateTime sessionEndTime = startTime.add(Duration(minutes: 20));
          AvailabilityModel availability = AvailabilityModel(
            availabilityId: doctorId + startTime.toString(),
            date: currentDay,
            doctorId: doctorId,
            startTime: startTime,
            endTime: sessionEndTime,
            status: true,
          );
          await availabilityCollection.add(availability.toMap());
          startTime = startTime.add(Duration(minutes: 20));
        }
      }
      currentDay = currentDay.add(Duration(days: 1));
      startTime =
          DateTime(currentDay.year, currentDay.month, currentDay.day, 9);
      endTime = DateTime(currentDay.year, currentDay.month, currentDay.day, 17);
    }
  }

  Future<void> createAvailabilitySignup(String doctorId) async {
    DateTime now = DateTime.now();
    await createAvailability(doctorId, now);
  }

  Future<void> createAvailabilityFromLastDate(String doctorId) async {
    DateTime lastAvailabilityDate =
        await getLastAvailabilityDateFromDatabase(doctorId);
    lastAvailabilityDate = lastAvailabilityDate.add(Duration(days: 1));
    await createAvailability(doctorId, lastAvailabilityDate);
  }

  Future<DateTime> getLastAvailabilityDateFromDatabase(String doctorId) async {
    try {
      final QuerySnapshot result = await availabilityCollection
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        Timestamp timestamp = result.docs.first['date'];
        DateTime lastAvailabilityDate = timestamp.toDate();
        return lastAvailabilityDate;
      } else {
        throw FirebaseException(
          plugin: 'Firestore',
          message: 'No availability date found',
        );
      }
    } catch (e, stackTrace) {
      print('Error occurred while fetching last availability date: $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<void> setAvailabilityToAvailable(String availabilityId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('availability')
          .doc(availabilityId)
          .get();

      if (snapshot.exists) {
        await snapshot.reference.update({'status': true});
      } else {
        throw Exception('Availability not found');
      }
    } catch (e) {
      print('Error occurred while setting availability status to true: $e');
      rethrow;
    }
  }

  Future<void> setAvailabilityToUnavailable(String availabilityId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('availability')
          .doc(availabilityId)
          .get();

      if (snapshot.exists) {
        await snapshot.reference.update({'status': false});
      } else {
        throw Exception('Availability not found');
      }
    } catch (e) {
      print('Error occurred while setting availability status to false: $e');
      rethrow;
    }
  }

  Future<List<AvailabilityModel>> getDoctorAvailabilies(String doctorId) async {
    try {
      DateTime currentDate = DateTime.now();
      QuerySnapshot result = await availabilityCollection
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThan: currentDate)
          .orderBy('date')
          .get();

      List<AvailabilityModel> availabilityList = [];
      for (var doc in result.docs) {
        Timestamp timestamp = doc['date'];
        DateTime date = timestamp.toDate();
        AvailabilityModel availability = AvailabilityModel(
          availabilityId: doc.id,
          date: date,
          doctorId: doc['doctorId'],
          startTime: doc['startTime'].toDate(),
          endTime: doc['endTime'].toDate(),
          status: doc['status'],
        );
        availabilityList.add(availability);
      }

      return availabilityList;
    } catch (e, stackTrace) {
      print('Error occurred while fetching doctor availability: $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<void> addAppointmentIdToAvailability(
      String availabilityId, String appointmentId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('availability')
          .doc(availabilityId)
          .get();

      if (snapshot.exists) {
        await snapshot.reference.update({'appointmentId': appointmentId});
      } else {
        throw Exception('Availability not found');
      }
    } catch (e) {
      print('Error occurred while adding appointment ID to availability: $e');
      rethrow;
    }
  }

  Future<void> removeAppointmentIdFromAvailability(
      String availabilityId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('availability')
          .doc(availabilityId)
          .get();

      if (snapshot.exists) {
        await snapshot.reference.update({'appointmentId': null});
      } else {
        throw Exception('Availability not found');
      }
    } catch (e) {
      print(
          'Error occurred while removing appointment ID from availability: $e');
      rethrow;
    }
  }
}
