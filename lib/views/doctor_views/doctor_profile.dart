import 'package:doctor_dash/views/auth_views/doctor_or_patient_choice_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctor_dash/controllers/doctor_controller.dart';
import 'package:doctor_dash/models/doctor_model.dart';
import 'package:doctor_dash/controllers/clinic_controller.dart';
import 'package:doctor_dash/models/clinic_model.dart';
import 'package:doctor_dash/views/doctor_views/edit_doctor_info_profile.dart';
import 'package:doctor_dash/views/doctor_views/edit_clinic_info_profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:doctor_dash/views/common/appointments.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({Key? key}) : super(key: key);

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final DoctorService _doctorService = DoctorService();
  final ClinicService _clinicService = ClinicService();
  DoctorModel? doctorInfo;
  List<ClinicModel> clinics = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctorInfo();
  }

  void _fetchDoctorInfo() async {
    try {
      var doctorId = _doctorService.user?.uid;
      if (doctorId != null) {
        var querySnapshot = await _doctorService.getDoctor(doctorId);
        if (querySnapshot.docs.isNotEmpty) {
          var docSnapshot = querySnapshot.docs.first;
          var doctor = DoctorModel.fromMap(docSnapshot);
          setState(() {
            doctorInfo = doctor;
          });
          await _fetchClinicInfo(doctor.clinicId);
        } else {
          print('Doctor data not found');
        }
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

  Future<void> _fetchClinicInfo(List<String> clinicIds) async {
    try {
      for (var clinicId in clinicIds) {
        var clinicSnapshot = await _clinicService.getClinic(clinicId);
        if (clinicSnapshot.docs.isNotEmpty) {
          var clinicDoc = clinicSnapshot.docs.first;
          var clinic = ClinicModel.fromMap(clinicDoc);
          setState(() {
            clinics.add(clinic);
          });
        }
      }
    } catch (e) {
      print('Error fetching clinic data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: <Widget>[
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
      body: doctorInfo == null
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  _buildDoctorInfoCard(),
                  for (var clinic in clinics) _buildClinicInfoCard(clinic),
                  _buildAppointmentsButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildDoctorInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Doctor Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _buildInfoRow('Name:', doctorInfo?.name ?? 'Not available'),
            _buildInfoRow('Phone:', doctorInfo?.phone ?? 'Not available'),
            _buildInfoRow('Email:', doctorInfo?.email ?? 'Not available'),
            _buildInfoRow(
                'Specialty:', doctorInfo?.speciality ?? 'Not available'),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.edit),
                onPressed: () async {
                  final updatedDoctor = await Navigator.push<DoctorModel>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditDoctorProfile(doctor: doctorInfo!),
                    ),
                  );
                  if (updatedDoctor != null) {
                    setState(() {
                      doctorInfo = updatedDoctor;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicInfoCard(ClinicModel clinic) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Clinic Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _buildInfoRow('Name:', clinic.name),
            _buildInfoRow('Street:', clinic.street),
            _buildInfoRow('City:', clinic.city),
            _buildInfoRow('Province:', clinic.province),
            _buildInfoRow('Postal Code:', clinic.postalCode),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.edit),
                onPressed: () async {
                  final updatedClinic = await Navigator.push<ClinicModel>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditClinicInfoProfile(clinic: clinic),
                    ),
                  );
                  if (updatedClinic != null) {
                    setState(() {
                      int index = clinics.indexWhere(
                          (c) => c.clinicId == updatedClinic.clinicId);
                      if (index != -1) {
                        clinics[index] = updatedClinic;
                      }
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildAppointmentsButton() {
    return Column(
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              width: constraints.maxWidth,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    String doctorId = doctorInfo?.doctorId ?? '';
                    if (doctorId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AppointmentPage(userId: doctorId),
                        ),
                      );
                    } else {
                      print('Doctor ID is not available');
                    }
                  },
                  child: const Text('Appointments'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
