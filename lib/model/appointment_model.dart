
class AppointmentModel {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String availabilityId;
  final String clinicId;
  final String doctorFilesPath;  // Path to FireStorage
  final String patientFilesPath; // Path to FireStorage
  final String doctorNotes;
  final String patientNotes;
  
AppointmentModel({
  required this.appointmentId,
  required this.doctorId,
  required this.patientId,
  required this.availabilityId,
  required this.clinicId,
  required this.doctorFilesPath,
  required this.patientFilesPath,
  this.doctorNotes = '',
  this.patientNotes = '',
});

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      appointmentId: map['appointmentId'],
      doctorId: map['doctorId'],
      patientId: map['patientId'],
      availabilityId: map['availabilityId'],
      clinicId: map['clinicId'],
      doctorFilesPath: map['doctorFilesPath'],
      patientFilesPath: map['patientFilesPath'],
      doctorNotes: map['doctorNotes'],
      patientNotes: map['patientNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'availabilityId': availabilityId,
      'clinicId': clinicId,
      'doctorFilesPath': doctorFilesPath,
      'patientFilesPath': patientFilesPath,
      'doctorNotes': doctorNotes,
      'patientNotes': patientNotes,
    };
  }

  @override
  String toString() {
    return 'AppointmentModel(appointmentId: $appointmentId, doctorId: $doctorId, patientId: $patientId, availabilityId: $availabilityId,clinicId: $clinicId , doctorFilesPath: $doctorFilesPath, patientFilesPath: $patientFilesPath, doctorNotes: $doctorNotes, patientNotes: $patientNotes)';
  }
}
