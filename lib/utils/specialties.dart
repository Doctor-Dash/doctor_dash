// medical_specialists.dart

class MedicalSpecialistsUtil {
  static final List<String> _specialists = [
    'Cardiologist',
    'Dermatologist',
    'Gastroenterologist',
    'Oncologist',
    'Orthodontist',
    'Otolaryngologist (ENT Specialist)',
    'Plastic Surgeon',
    'Psychiatrist',
    'Rheumatologist',
    'Urologist',
    'Optometrist',
    'Podiatrist',
    'Chiropractor'
  ];

  static List<String> getSpecialists() {
    return _specialists;
  }
}
