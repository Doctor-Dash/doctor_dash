import 'package:flutter/material.dart';
import '../../controllers/doctor_controller.dart';
import '../../models/doctor_model.dart';
import '../../models/feedback_model.dart';
import '../../controllers/feedback_controller.dart';

class DoctorFeedback extends StatefulWidget {
  final DoctorModel doctor;
  DoctorFeedback(this.doctor);

  @override
  _DoctorFeedbackState createState() => _DoctorFeedbackState();
}

class _DoctorFeedbackState extends State<DoctorFeedback> {
  final _feedbackController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    String feedbackId = await FeedbackService().generateUniqueFeedbackId();

    FeedbackModel feedback = FeedbackModel(
      feedbackId: feedbackId,
      rating: _rating,
      feedbackNote: _feedbackController.text,
    );

    await FeedbackService().createFeedback(feedback);

    List<String> updatedFeedbackIds =
        List<String>.from(widget.doctor.feedbackId ?? []);
    updatedFeedbackIds.add(feedbackId);

    DoctorModel updatedDoctor = DoctorModel(
      doctorId: widget.doctor.doctorId,
      name: widget.doctor.name,
      phone: widget.doctor.phone,
      email: widget.doctor.email,
      speciality: widget.doctor.speciality,
      clinicId: widget.doctor.clinicId,
      availability: widget.doctor.availability,
      appointmentId: widget.doctor.appointmentId,
      feedbackId: updatedFeedbackIds,
    );

    await DoctorService().updateDoctor(updatedDoctor);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')));
    Navigator.pop(context);
  }

  void _rateDoctor(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => _rateDoctor(index + 1),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctor.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Name: ${widget.doctor.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rate the Doctor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildRatingStars(),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
