import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:table_calendar/table_calendar.dart';

class ClassDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  ClassDetailsScreen({required this.classData});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _attendedDays = [];
  String? trainerName;
  late DateTime startDate;
  late DateTime endDate;
  late String userId;
  late String classId;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.parse(widget.classData['start_date']);
    endDate = DateTime.parse(widget.classData['end_date']);
    userId = FirebaseAuth.instance.currentUser!.uid;
    classId = widget.classData['class_id'];
    fetchAttendanceData();
    fetchTrainerName();
  }

  Future<void> fetchAttendanceData() async {
    try {
      DocumentReference attendanceDocRef = FirebaseFirestore.instance
          .collection('attendance')
          .doc('$userId$classId');

      DocumentSnapshot attendanceSnapshot = await attendanceDocRef.get();

      if (attendanceSnapshot.exists) {
        List<DateTime> attendedDates = (attendanceSnapshot['dates'] as List)
            .map((date) => (date as Timestamp).toDate())
            .toList();

        setState(() {
          _attendedDays = attendedDates;
        });
      } else {
        await attendanceDocRef.set({
          'user_id': userId,
          'class_id': classId,
          'dates': [],
        });

        setState(() {
          _attendedDays = [];
        });
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  Future<void> updateAttendance(DateTime date) async {
    DocumentReference attendanceDocRef = FirebaseFirestore.instance
        .collection('attendance')
        .doc('$userId$classId');

    if (_attendedDays.contains(date)) {
      _attendedDays.remove(date);
      await attendanceDocRef.update({
        'dates': FieldValue.arrayRemove([Timestamp.fromDate(date)])
      });
    } else {
      _attendedDays.add(date);
      await attendanceDocRef.update({
        'dates': FieldValue.arrayUnion([Timestamp.fromDate(date)])
      });
    }

    // Fetch attendance data again to ensure _attendedDays is up-to-date
    await fetchAttendanceData();
  }

  Future<void> fetchTrainerName() async {
    try {
      DocumentSnapshot trainerSnapshot = await FirebaseFirestore.instance
          .collection('trainers')
          .doc(widget.classData['trainer_id'])
          .get();

      if (trainerSnapshot.exists) {
        setState(() {
          trainerName = trainerSnapshot['name'];
        });
      } else {
        setState(() {
          trainerName = 'Unknown';
        });
      }
    } catch (e) {
      print('Error fetching trainer data: $e');
      setState(() {
        trainerName = 'Error loading trainer';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = endDate.difference(startDate).inDays + 1;
    int attendedDaysCount = _attendedDays.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classData['class_name']),
        backgroundColor: Palette.secondaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Class Details Card
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class: ${widget.classData['class_name']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Start Date: ${widget.classData['start_date']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'End Date: ${widget.classData['end_date']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Trainer: ${trainerName ?? 'Loading...'}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Fee: \$${widget.classData['class_fee']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Days Attended: $attendedDaysCount/$totalDays',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${((attendedDaysCount / totalDays) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: attendedDaysCount / totalDays,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          color: Colors.deepPurple,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Calendar Card
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TableCalendar(
                    firstDay: startDate,
                    lastDay: endDate,
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) async {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      await updateAttendance(selectedDay);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors
                            .orangeAccent, // Highlight the current day with orange
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.red, // Màu đỏ cho ngày đã đánh dấu
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: false,
                      outsideDecoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.deepPurple,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.deepPurple,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.red),
                      weekdayStyle: TextStyle(color: Colors.deepPurple),
                    ),
                    eventLoader: (day) {
                      List<String> events = [];
                      if (_attendedDays.contains(day)) {
                        events.add('Attended');
                      }
                      if (isSameDay(day, startDate)) {
                        events.add('Start');
                      }
                      if (isSameDay(day, endDate)) {
                        events.add('End');
                      }
                      return events;
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events.map((event) {
                              Color markerColor;
                              if (event == 'Attended') {
                                markerColor =
                                    Colors.red; // Màu đỏ cho ngày đã đánh dấu
                              } else if (event == 'Start' || event == 'End') {
                                markerColor = Colors.green;
                              } else {
                                markerColor = Colors.blueAccent;
                              }
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return null;
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        if (_attendedDays.contains(day)) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(
                                  0.3), // Màu nền đỏ nhạt cho các ngày đã đánh dấu
                              shape: BoxShape.circle,
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
