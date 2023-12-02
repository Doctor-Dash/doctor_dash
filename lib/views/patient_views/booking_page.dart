import 'package:doctor_dash/controllers/availability_controller.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctor_dash/utils/utils.dart';

class BookingPage extends StatefulWidget {
  final String doctorId;

  const BookingPage({super.key, required this.doctorId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  late List<DateTimeRange> _availableTimeSlots;

  final AvailabilityService _availabilityService = AvailabilityService();

  Future<void> _fetchAvailableTimeSlots() async {
    try {
      List<DateTimeRange> timeSlots = await _availabilityService
          .getAvailableTimeSlotsForDay('D1234', _focusedDay);
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
    // Config().init(context);
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
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                            _timeSelected = true;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color:
                                _currentIndex == index ? Colors.purple : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _currentIndex == index ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 1.5),
                ),
          SliverToBoxAdapter(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
                child: ElevatedButton(
                  onPressed: () async {
                    //use the info from this page to create a booking using availability_service.dart
                    //then go to booking_confirmation.dart
                    var timeSlots = await AvailabilityService()
                        .getAvailableTimeSlotsForDay('D1234', _focusedDay);
                    print(timeSlots);
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
    if (_availableTimeSlots.isEmpty) {
      return const Text('No available time slots.');
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          DateTime startTime = _availableTimeSlots[index].start;
          return InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              setState(() {
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
                '${startTime.hour}:${startTime.minute} ${startTime.hour > 11 ? "PM" : "AM"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _currentIndex == index ? Colors.white : null,
                ),
              ),
            ),
          );
        },
        childCount: _availableTimeSlots.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
      ),
    );
  }
}
