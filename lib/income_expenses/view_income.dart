import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/income_expenses/drawer.dart';

class ViewIncome extends StatefulWidget {
  @override
  _ViewIncomeState createState() => _ViewIncomeState();
}

class _ViewIncomeState extends State<ViewIncome> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null &&
        pickedDate != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        title: Text('View Income'),
        backgroundColor: Palette.secondaryColor,
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Date Picker Section
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Palette.secondaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search TextField
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300],
                      hintText: 'Search by class name...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),

                  // Date Picker Section
                  Text(
                    'Filter by Date Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectDate(context, true),
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                const Color.fromARGB(255, 31, 33, 34),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Text(
                            startDate == null
                                ? 'Start Date'
                                : DateFormat('dd-MM-yyyy').format(startDate!),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectDate(context, false),
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                const Color.fromARGB(255, 31, 33, 34),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Text(
                            endDate == null
                                ? 'End Date'
                                : DateFormat('dd-MM-yyyy').format(endDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            // Income List View
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('buyclasses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Something went wrong',
                            style: TextStyle(color: Colors.red)),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // If we reach here, we have data
                    var buyClasses = snapshot.data!.docs.where((classData) {
                      DateTime start = DateTime.parse(classData['start_date']);
                      DateTime end = DateTime.parse(classData['end_date']);
                      bool matchesQuery = classData['class_name']
                          .toString()
                          .toLowerCase()
                          .contains(searchQuery);
                      bool matchesDateRange = true;

                      if (startDate != null) {
                        matchesDateRange =
                            matchesDateRange && start.isAfter(startDate!);
                      }
                      if (endDate != null) {
                        matchesDateRange = matchesDateRange &&
                            end.isBefore(endDate!.add(Duration(days: 1)));
                      }

                      return matchesQuery && matchesDateRange;
                    }).toList();

                    return ListView.builder(
                      itemCount: buyClasses.length,
                      itemBuilder: (context, index) {
                        var classData = buyClasses[index];
                        return Card(
                          elevation: 5,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Class: ' + classData['class_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: const Color.fromARGB(255, 8, 8, 9),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'User Name: ' + classData['user_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'User Phone: ' + classData['user_phone'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Fee: \$${classData['class_fee']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Start Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(classData['start_date']))}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'End Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(classData['end_date']))}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('trainers')
                                      .doc(classData['trainer_id'])
                                      .get(),
                                  builder: (context, trainerSnapshot) {
                                    if (trainerSnapshot.hasError ||
                                        !trainerSnapshot.hasData) {
                                      return Text(
                                        'Trainer: Loading...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red[600],
                                        ),
                                      );
                                    }
                                    var trainerData = trainerSnapshot.data!;
                                    return Text(
                                      'Trainer: ' + trainerData['name'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red[600],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
