import 'dart:convert';

import 'package:customer_app_multistore/home_screen_customer/discount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/provider/stripe_id.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:customer_app_multistore/witget/custom_app_bar.dart';

class Class extends StatefulWidget {
  @override
  _ClassState createState() => _ClassState();
}

class _ClassState extends State<Class> {
  String searchQuery = '';
  Map<String, dynamic>?
      selectedDiscountCode; // Thêm biến để lưu mã giảm giá đã chọn

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Classes'),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildClassList(),
            ),
          ],
        ),
      ),
    );
  }

  // Xây dựng thanh tìm kiếm
  Widget _buildSearchBar() {
    return Container(
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
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
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
          ),
        ],
      ),
    );
  }

  // Xây dựng danh sách lớp học
  Widget _buildClassList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('classes').snapshots(),
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

        var classes = snapshot.data!.docs.where((classData) {
          return classData['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery);
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            var classData = classes[index];
            String classId = classData.id;

            DateTime endDate = DateTime.parse(classData['end_date']);
            DateTime now = DateTime.now();
            bool isClassFinished = now.isAfter(endDate);

            User? user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              return SizedBox.shrink();
            }

            return FutureBuilder<bool>(
              future: _hasUserPurchasedClass(user.uid, classId),
              builder: (context, hasPurchasedSnapshot) {
                bool hasPurchased = hasPurchasedSnapshot.data ?? false;

                return FutureBuilder<bool>(
                  future: _hasUserPurchasedAnyClass(user.uid),
                  builder: (context, hasPurchasedAnyClassSnapshot) {
                    bool hasPurchasedAnyClass =
                        hasPurchasedAnyClassSnapshot.data ?? false;

                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData['name'] ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: const Color.fromARGB(255, 9, 9, 10),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Fee: \$${classData['fee'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Palette.secondaryColor,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Start Date: ${classData['start_date'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'End Date: ${classData['end_date'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Number of Members: ${classData['max_members'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
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
                                  'Trainer: ${trainerData['name'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red[600],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            if (isClassFinished)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  'Class Completed',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else if (hasPurchased)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  'You have already purchased this class',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (isClassFinished) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Class is completed.'),
                                        ),
                                      );
                                      return;
                                    }

                                    // if (hasPurchasedAnyClass) {
                                    //   ScaffoldMessenger.of(context)
                                    //       .showSnackBar(
                                    //     SnackBar(
                                    //       content: Text(
                                    //           'You can only purchase one class.'),
                                    //     ),
                                    //   );
                                    //   return;
                                    // }

                                    Map<String, dynamic> classDataMap =
                                        classData.data()
                                            as Map<String, dynamic>;
                                    String classId = classData.id;

                                    // Open the discount code selection screen
                                    selectedDiscountCode = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DiscountCodeScreen(
                                          currentUserId: FirebaseAuth
                                              .instance.currentUser!.uid,
                                        ),
                                      ),
                                    ) as Map<String, dynamic>?;

                                    await makePayment(classDataMap, classId);
                                  },
                                  child: Text('Buy Now'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Palette.primaryColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    elevation: 5.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(
      Map<String, dynamic> classData, String classId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      DocumentSnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .get();

      if (!classSnapshot.exists) {
        throw Exception("Class not found.");
      }

      int maxMembers = int.parse(classSnapshot.get('max_members'));

      if (maxMembers <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Class is already fully booked.'),
          ),
        );
        return;
      }

      double fee = double.tryParse(classData['fee'].toString()) ?? 0.0;
      double discount = selectedDiscountCode != null
          ? (selectedDiscountCode!['percentage'].toDouble() / 100.0)
          : 0.0;
      double finalPrice = fee - (fee * discount);

      paymentIntentData = await createPaymentIntent(finalPrice);

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .get();

      if (!userSnapshot.exists) {
        throw Exception("User data not found.");
      }

      String userName = userSnapshot.get('name');
      String userPhone = userSnapshot.get('phone');

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          merchantDisplayName: 'ANN Shop',
          applePay: stripe.PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
          googlePay: stripe.PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );

      await displayPaymentSheet(
          classData, userName, userPhone, classId, finalPrice);
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> displayPaymentSheet(
      Map<String, dynamic> classData,
      String userName,
      String userPhone,
      String classId,
      double finalPrice) async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      if (paymentIntentData != null && paymentIntentData!['id'] != null) {
        await saveTransaction({
          ...classData,
          'user_name': userName,
          'user_phone': userPhone,
          'discount_code': selectedDiscountCode?['codeName'],
          'discount_percentage':
              selectedDiscountCode?['percentage']?.toDouble(),
          'final_price': finalPrice,
        }, paymentIntentData!['id'], classId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful and class purchased.'),
          ),
        );
      } else {
        throw Exception("Payment intent creation failed.");
      }
    } catch (e) {
      if (e is stripe.StripeException) {
        print('StripeException: ${e.error.localizedMessage}');
      } else {
        print('Exception: $e');
      }
    }
  }

  Future<void> saveTransaction(Map<String, dynamic> classData,
      String paymentIntentId, String classId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      String userName = classData['user_name'];
      String userPhone = classData['user_phone'];
      String? discountCode = classData['discount_code'];
      double? discountPercentage = classData['discount_percentage'];
      double finalPrice = classData['final_price'];

      DocumentReference transactionRef =
          FirebaseFirestore.instance.collection('buyclasses').doc();

      await transactionRef.set({
        'user_id': user.uid,
        'user_name': userName,
        'user_phone': userPhone,
        'class_id': classId,
        'class_name': classData['name'],
        'class_fee': classData['fee'],
        'trainer_id': classData['trainer_id'],
        'start_date': classData['start_date'],
        'end_date': classData['end_date'],
        'payment_intent_id': paymentIntentId,
        'discount_code': discountCode,
        'discount_percentage': discountPercentage,
        'final_price': finalPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference classRef =
            FirebaseFirestore.instance.collection('classes').doc(classId);
        DocumentSnapshot classSnapshot = await transaction.get(classRef);

        if (!classSnapshot.exists) {
          throw Exception("Class not found.");
        }

        int maxMembers = int.parse(classSnapshot.get('max_members'));

        if (maxMembers > 0) {
          transaction
              .update(classRef, {'max_members': (maxMembers - 1).toString()});
        } else {
          throw Exception("Class is already fully booked.");
        }
      });

      print('Transaction saved successfully.');
    } catch (e) {
      print('Error saving transaction: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    try {
      int amountInCents = (amount * 100).toInt();

      Map<String, dynamic> body = {
        'amount': amountInCents.toString(),
        'currency': 'USD',
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }

  Future<bool> _hasUserPurchasedClass(String userId, String classId) async {
    var purchaseSnapshot = await FirebaseFirestore.instance
        .collection('buyclasses')
        .where('user_id', isEqualTo: userId)
        .where('class_id', isEqualTo: classId)
        .get();
    return purchaseSnapshot.docs.isNotEmpty;
  }

  Future<bool> _hasUserPurchasedAnyClass(String userId) async {
    var purchaseSnapshot = await FirebaseFirestore.instance
        .collection('buyclasses')
        .where('user_id', isEqualTo: userId)
        .get();
    return purchaseSnapshot.docs.isNotEmpty;
  }
}
