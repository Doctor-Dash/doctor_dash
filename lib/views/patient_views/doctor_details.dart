import 'package:doctor_dash/controllers/clinic_controller.dart';
import 'package:doctor_dash/controllers/feedback_controller.dart';
import 'package:doctor_dash/models/clinic_model.dart';
import 'package:doctor_dash/models/feedback_model.dart';
import 'package:doctor_dash/views/patient_views/booking_page.dart';
import '../../controllers/doctor_controller.dart';
import '../../models/doctor_model.dart';
import 'package:flutter/material.dart';
import '../../controllers/availability_controller.dart';

class DoctorDetails extends StatelessWidget {
  final DoctorModel doctor;
  final ClinicService clinicService = ClinicService();
  final FeedbackService feedbackService = FeedbackService();

  DoctorDetails(this.doctor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Doctor Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            doctorInfo(doctor),
            const SizedBox(height: 16),
            const Text(
              'Clinic Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<ClinicModel?>(
              future: clinicService.getClinicModel(doctor.clinicId[0]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading clinic info: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data != null) {
                  return clinicInfo(snapshot.data!);
                } else {
                  return const Text('No clinic info available');
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Feedback',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<List<FeedbackModel>>(
                  future: doctor.feedbackId!.isNotEmpty
                      ? feedbackService.getFeedbacksByIds(doctor.feedbackId)
                      : Future.value([]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error loading feedback info: ${snapshot.error}');
                    } else if (snapshot.hasData &&
                        snapshot.data!.isNotEmpty &&
                        snapshot.data != null) {
                      return feedbackInfo(snapshot.data!);
                    } else {
                      return const Text(
                          'No feedbacks for this doctor available');
                    }
                  },
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingPage(
                              doctorId: doctor.doctorId,
                              clinicId: doctor.clinicId[0])));
                },
                child: const Text('Book Appointment with this Doctor!'),
              ),
            ),
            const SizedBox(height: 16)
          ],
        ),
      ),
    );
  }

  Widget doctorInfo(DoctorModel doctor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Name: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: doctor.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Speciality: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: doctor.speciality,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                const SizedBox(width: 8),
                Text(
                  doctor.phone,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                Text(
                  doctor.email,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget clinicInfo(ClinicModel clinic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Name: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: clinic.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Address: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        '${clinic.street}, ${clinic.city}, ${clinic.province}, ${clinic.postalCode}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                const SizedBox(width: 8),
                Text(
                  clinic.phoneNumber,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                Text(
                  clinic.email,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget feedbackInfo(List<FeedbackModel> feedbacks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var feedback in feedbacks)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(
                        feedback.rating,
                        (index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            )),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Note:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    feedback.feedbackNote,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
