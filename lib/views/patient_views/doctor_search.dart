import 'package:flutter/material.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/clinic_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Doctor'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Implement navigation to patient profile view
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
                return ListTile(
                  title: Text(doctor.name),
                  subtitle: Text(doctor.speciality),
                  // Add other doctor details here
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _searchDoctors() async {
    if (selectedCity.isEmpty || selectedSpecialty.isEmpty) return;

    try {
      List<String> clinicIds =
          await clinicService.getClinicsInCity(selectedCity);
      List<DoctorModel> filteredDoctors =
          await doctorService.getDoctors(selectedSpecialty, clinicIds);
      setState(() => doctors = filteredDoctors);
    } catch (e) {
      print('Error: $e');
    }
  }
}
