import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/home_screen_customer/classdetail.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:intl/intl.dart'; // Import the new screen

class BuyClassScreen extends StatefulWidget {
  @override
  _BuyClassScreenState createState() => _BuyClassScreenState();
}

class _BuyClassScreenState extends State<BuyClassScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Buy Classes'),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Palette.secondaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey[350],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          // Add search functionality here
                        },
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          contentPadding: const EdgeInsets.only(top: 15.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('buyclasses')
                      .where('user_id', isEqualTo: user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Something went wrong'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var buyClasses = snapshot.data!.docs;

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      itemCount: buyClasses.length,
                      itemBuilder: (context, index) {
                        var classData = buyClasses[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 20.0,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Class: ' + classData['class_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color:
                                        const Color.fromARGB(255, 14, 15, 15),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'User name: ' + classData['user_name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'User phone: ' + classData['user_phone'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Fee: \$${NumberFormat('##0.00').format(classData['final_price'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Start Date: ' + classData['start_date'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'End Date: ' + classData['end_date'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
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
                                          fontSize: 16,
                                          color: Colors.red[600],
                                        ),
                                      );
                                    }
                                    var trainerData = trainerSnapshot.data!;
                                    return Text(
                                      'Trainer: ' + trainerData['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red[600],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClassDetailsScreen(
                                    classData: classData.data()
                                        as Map<String, dynamic>,
                                  ),
                                ),
                              );
                            },
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
