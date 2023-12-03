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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            doctorInfo(doctor),
            const SizedBox(height: 16),
            FutureBuilder<ClinicModel?>(
              future: clinicService.getClinic(doctor.clinicId[0]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
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
            Expanded(
              child: SingleChildScrollView(
                child: FutureBuilder<List<FeedbackModel>>(
                  future: feedbackService.getFeedbacksByIds(doctor
                      .feedbackId), // assuming doctor has feedbackIds property
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error loading feedback info: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return feedbackInfo(snapshot.data!);
                    } else {
                      return const Text('No feedback info available');
                    }
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookingPage(
                            doctorId: doctor.doctorId,
                            clinicId: doctor.clinicId[0])));
              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget doctorInfo(DoctorModel doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Doctor Info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Name: ${doctor.name}',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'Speciality: ${doctor.speciality}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'Phone: ${doctor.phone}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'Email: ${doctor.email}',
          style: TextStyle(fontSize: 18),
        ),
        //TODO: Add additional doctor details here
      ],
    );
  }

  Widget clinicInfo(ClinicModel clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Clinic Info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Name: ${clinic.name}',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'Address: ${clinic.street}, ${clinic.city}, ${clinic.province}, ${clinic.postalCode}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'Phone: ${clinic.phoneNumber}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'Email: ${clinic.email}',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget feedbackInfo(List<FeedbackModel> feedbacks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Feedback Info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
