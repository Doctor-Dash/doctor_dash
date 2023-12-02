import 'package:doctor_dash/controllers/appointment_controller.dart';
import 'package:doctor_dash/controllers/availability_controller.dart';
import 'package:doctor_dash/models/appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctor_dash/utils/utils.dart';

class BookingPage extends StatefulWidget {
  final String doctorId;
  final String clinicId;

  const BookingPage(
      {super.key, required this.doctorId, required this.clinicId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  DateTime _startTime = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  late List<DateTimeRange> _availableTimeSlots = [];

  final AvailabilityService _availabilityService = AvailabilityService();
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _fetchAvailableTimeSlots();
  }

  Future<void> _fetchAvailableTimeSlots() async {
    try {
      List<DateTimeRange> timeSlots = await _availabilityService
          .getAvailableTimeSlotsForDay(widget.doctorId, _focusedDay);
      setState(() {
        _availableTimeSlots = timeSlots;
      });
    } catch (e) {
      // Handle error
      showErrorSnackBar(context, 'Error fetching available time slots: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
              child: Column(children: <Widget>[
            _tableCalendar(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
              child: Center(
                child: Text(
                  'Select a time slot',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            )
          ])),
          _isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 30),
                    alignment: Alignment.center,
                    child: const Text(
                      'Weekend is not available, please select another date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : _buildTimeSlots(),
          SliverToBoxAdapter(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
                child: ElevatedButton(
                  onPressed: () async {
                    var currPatient = FirebaseAuth.instance.currentUser?.uid;

                    AppointmentModel appointment = AppointmentModel(
                      appointmentId:
                          '${widget.doctorId}$_startTime$currPatient',
                      doctorId: widget.doctorId,
                      patientId: '$currPatient',
                      availabilityId: '${widget.doctorId}$_startTime',
                      clinicId: widget.clinicId,
                    );

                    try {
                      await _appointmentService.addAppointment(appointment);
                      showSnackBar(context, 'Appointment booked!');
                    } catch (e) {
                      showErrorSnackBar(
                          context, 'Error booking appointment: $e');
                    }
                  },
                  child: const Text('Book Appointment'),
                )),
          ),
        ],
      ),
    );
  }

  //table calendar
  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2023, 12, 31),
      calendarFormat: _calendarFormat,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration:
            BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusedDay = focusedDay;
          _dateSelected = true;
          _fetchAvailableTimeSlots();

          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }

  Widget _buildTimeSlots() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (_availableTimeSlots.isEmpty) {
            return Container(
              margin: const EdgeInsets.all(5),
              alignment: Alignment.center,
              child: const Text('No available time slots.'),
            );
          }

          DateTime startTime = _availableTimeSlots[index].start;
          String formattedStartTime = DateFormat('hh:mm a').format(startTime);

          return InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
                _startTime = startTime;
                _currentIndex = index;
                _timeSelected = true;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentIndex == index ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(15),
                color: _currentIndex == index ? Colors.purple : null,
              ),
              alignment: Alignment.center,
              child: Text(
                formattedStartTime,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _currentIndex == index ? Colors.white : null,
                ),
              ),
            ),
          );
        },
        childCount:
            _availableTimeSlots.isEmpty ? 1 : _availableTimeSlots.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
      ),
    );
  }
}
