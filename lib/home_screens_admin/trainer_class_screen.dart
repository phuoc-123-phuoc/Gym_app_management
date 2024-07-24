import 'package:customer_app_multistore/config/palette.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TrainerClassesScreen extends StatelessWidget {
  final String trainerId;

  TrainerClassesScreen({required this.trainerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes by Trainer'),
        backgroundColor: Palette.secondaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buyclasses')
            .where('trainer_id', isEqualTo: trainerId)
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

          var classes = snapshot.data!.docs;

          if (classes.isEmpty) {
            return Center(
              child: Text('No classes found for this trainer.'),
            );
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              var classData = classes[index];

              return Card(
                elevation: 8,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade100, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20.0),
                    title: Text(
                      'Class: ${classData['class_name']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.purple.shade900,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Fee: \$${classData['class_fee']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Start Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(classData['start_date']))}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'End Date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(classData['end_date']))}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
