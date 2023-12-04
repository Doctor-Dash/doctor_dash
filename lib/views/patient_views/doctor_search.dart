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

  TextEditingController searchController = TextEditingController();
  TextEditingController specialtyController = TextEditingController();

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: searchController,
              leading: const Icon(Icons.search),
              hintText: 'Search by city',
              onSubmitted: (value) {
                _searchDoctors();
              },
              onChanged: (value) => setState(() => selectedCity = value),
            ),
          ),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            initialSelection:
                selectedSpecialty.isEmpty ? null : selectedSpecialty,
            controller: specialtyController,
            requestFocusOnTap: true,
            label: const Text('Select Specialty'),
            onSelected: (String? specialty) {
              setState(() {
                selectedSpecialty = specialty!;
              });
              _searchDoctors();
            },
            dropdownMenuEntries:
                specialties.map<DropdownMenuEntry<String>>((String specialty) {
              return DropdownMenuEntry<String>(
                value: specialty,
                label: specialty,
                enabled: true,
                style: MenuItemButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                final avgRating = doctorRatings[doctor.doctorId] ?? 0.0;
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      //TODO: Add image of Doctor when available
                      child: Icon(Icons.person),
                      backgroundColor: Colors.white,
                    ),
                    title: Text(
                      doctor.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(doctor.speciality),
                    trailing: avgRating > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  color: Colors.yellow[600], size: 20),
                              SizedBox(width: 4),
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : Text(
                            "No Ratings",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetails(doctor),
                        ),
                      );
                    },
                  ),
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

      filteredDoctors.sort((a, b) =>
          tempRatings[b.doctorId]!.compareTo(tempRatings[a.doctorId] as num));

      setState(() {
        doctors = filteredDoctors;
        doctorRatings = tempRatings;
      });
    } catch (e) {
      throw Exception('Failed to search for doctors: $e');
    }
  }
}
