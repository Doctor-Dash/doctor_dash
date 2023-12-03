import 'package:doctor_dash/views/auth_views/doctor_or_patient_choice_view.dart';
import 'package:doctor_dash/views/patient_views/doctor_details.dart';
import 'package:doctor_dash/views/patient_views/patient_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/clinic_controller.dart';
import '../../controllers/feedback_controller.dart';
import '../../models/feedback_model.dart';
import '../../models/doctor_model.dart';
import '../../utils/specialties.dart';

// TODO import doctor_detail_view
//import './doctor_profile.dart';

class DoctorSearchView extends StatefulWidget {
  @override
  _DoctorSearchViewState createState() => _DoctorSearchViewState();
}

class _DoctorSearchViewState extends State<DoctorSearchView> {
  String selectedCity = '';
  String selectedSpecialty = '';
  List<DoctorModel> doctors = [];
  List<String> specialties = MedicalSpecialistsUtil.getSpecialists();

  ClinicService clinicService = ClinicService();
  DoctorService doctorService = DoctorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Doctor'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              String patientId = FirebaseAuth.instance.currentUser!.uid;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PatientProfilePage(patientId: patientId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const DoctorOrPatientChoice(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Enter your city'),
            onChanged: (value) {
              setState(() => selectedCity = value);
              _searchDoctors();
            },
          ),
          DropdownButton<String>(
            value: selectedSpecialty.isEmpty ? null : selectedSpecialty,
            hint: const Text('Select Specialty'),
            onChanged: (String? newValue) {
              setState(() => selectedSpecialty = newValue!);
              _searchDoctors();
            },
            items: specialties.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                final avgRating = doctorRatings[doctor.doctorId] ?? 0.0;
                return ListTile(
                  title: Text(doctor.name),
                  subtitle: Text(doctor.speciality),
                  trailing: avgRating > 0
                      ? Text("Rating: ${avgRating.toStringAsFixed(1)}")
                      : Text("No Ratings"),
                  onTap: () {
                    // TODO: Implement navigation to patient profile view
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DoctorDetails(doctor)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<double> _calculateAverageRating(List<String>? feedbackIds) async {
    if (feedbackIds == null || feedbackIds.isEmpty) {
      return 0.0;
    }

    FeedbackService feedbackService = FeedbackService();

    try {
      List<FeedbackModel> feedbacks =
          await feedbackService.getFeedbacksByIds(feedbackIds);

      if (feedbacks.isEmpty) {
        return 0.0;
      }

      double totalRating = feedbacks.fold(0, (sum, item) => sum + item.rating);
      return totalRating / feedbacks.length;
    } catch (e) {
      throw Exception('Failed to calculate average: $e');
    }
  }

  Map<String, double> doctorRatings = {};

  void _searchDoctors() async {
    if (selectedCity.isEmpty || selectedSpecialty.isEmpty) return;

    try {
      List<String> clinicIds =
          await clinicService.getClinicsInCity(selectedCity);
      List<DoctorModel> filteredDoctors =
          await doctorService.getDoctors(selectedSpecialty, clinicIds);

      Map<String, double> tempRatings = {};
      for (var doctor in filteredDoctors) {
        double avgRating = await _calculateAverageRating(doctor.feedbackId);
        tempRatings[doctor.doctorId] = avgRating;
      }

      setState(() {
        doctors = filteredDoctors;
        doctorRatings = tempRatings;
      });
    } catch (e) {
      throw Exception('Failed to search for doctors: $e');
    }
  }
}
