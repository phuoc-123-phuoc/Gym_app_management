import 'dart:convert';

import 'package:customer_app_multistore/provider/stripe_id.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

class PackageScreen extends StatelessWidget {
  final String memberId;

  PackageScreen({required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Available Packages'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('buyPackages')
                  .where('userId', isEqualTo: memberId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var subscribedPackageIds = snapshot.data!.docs
                    .map((doc) => doc['packageId'] as String)
                    .toList();

                // Kiểm tra nếu danh sách gói đã đăng ký rỗng
                if (subscribedPackageIds.isEmpty) {
                  return Center(
                    child: Text(
                      'No packages subscribed yet.',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('packages')
                      .where(FieldPath.documentId,
                          whereIn: subscribedPackageIds)
                      .snapshots(),
                  builder: (context, packageSnapshot) {
                    if (!packageSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (packageSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${packageSnapshot.error}'));
                    }

                    return Column(
                      children: packageSnapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        int fee = (data['fee'] as num).toInt();
                        int duration = (data['duration'] as num).toInt();
                        return PackageCard(
                          imageUrl: data['image_url'] ?? '',
                          name: data['name'] ?? 'No Name',
                          fee: fee,
                          duration: duration,
                          description: data['description'] ?? 'No Description',
                          docId: doc.id,
                          memberId: memberId,
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _checkSubscriptionStatus(String memberId) async {
  QuerySnapshot subscriptionSnapshot = await FirebaseFirestore.instance
      .collection('buyPackages')
      .where('userId', isEqualTo: memberId)
      .limit(1)
      .get();
  return subscriptionSnapshot.docs.isNotEmpty;
}

class PackageCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final int fee;
  final int duration;
  final String description;
  final String docId;
  final String memberId;

  PackageCard({
    required this.imageUrl,
    required this.name,
    required this.fee,
    required this.duration,
    required this.description,
    required this.docId,
    required this.memberId,
  });

  @override
  _PackageCardState createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _status;
  String? _trainerName; // Thêm biến để lưu tên huấn luyện viên

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionDetails();
    _fetchTrainerName(); // Thực hiện việc lấy tên huấn luyện viên khi khởi tạo
  }

  Future<void> _fetchSubscriptionDetails() async {
    String userId = widget.memberId;

    QuerySnapshot subscriptionSnapshot = await FirebaseFirestore.instance
        .collection('buyPackages')
        .where('userId', isEqualTo: userId)
        .where('packageId', isEqualTo: widget.docId)
        .limit(1)
        .get();

    if (subscriptionSnapshot.docs.isNotEmpty) {
      var doc = subscriptionSnapshot.docs.first.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _startDate = (doc['startDate'] as Timestamp).toDate();
          _endDate = (doc['endDate'] as Timestamp).toDate();
          _status = doc['status'];
          _trainerName =
              doc['trainerName']; // Lấy tên huấn luyện viên từ buyPackages
        });
      }
    }
  }

  Future<void> _fetchTrainerName() async {
    try {
      DocumentSnapshot packageSnapshot = await FirebaseFirestore.instance
          .collection('packages')
          .doc(widget.docId)
          .get();
      if (packageSnapshot.exists) {
        String trainerId = packageSnapshot
            .get('trainerId'); // Lấy ID huấn luyện viên từ gói dịch vụ
        DocumentSnapshot trainerSnapshot = await FirebaseFirestore.instance
            .collection('trainers')
            .doc(trainerId)
            .get();
        if (trainerSnapshot.exists) {
          setState(() {
            _trainerName = trainerSnapshot.get(
                'name'); // Lấy tên huấn luyện viên từ tài liệu của huấn luyện viên
          });
        } else {
          _trainerName = 'Unknown Trainer';
        }
      } else {
        _trainerName = 'Unknown Trainer';
      }
    } catch (e) {
      _trainerName = 'Unknown Trainer';
    }
  }

  Future<void> _handleSubscribe(BuildContext context) async {
    String userId = widget.memberId;

    QuerySnapshot existingSubscriptionSnapshot = await FirebaseFirestore
        .instance
        .collection('buyPackages')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingSubscriptionSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only subscribe to one package at a time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a start date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? userName;

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        userName = userSnapshot.get('name');
      } else {
        userName = 'Unknown User';
      }
    } catch (e) {
      userName = 'Unknown User';
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Subscription'),
        content: Text(
            'Are you sure you want to subscribe to "${widget.name}" for ${widget.duration} months starting from ${_startDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'} at \$${widget.fee}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('buyPackages').add({
          'userId': userId,
          'userName': userName,
          'packageId': widget.docId,
          'name': widget.name,
          'fee': widget.fee,
          'duration': widget.duration,
          'description': widget.description,
          'startDate': _startDate,
          'endDate': _endDate,
          'status': 'wait for confirmation',
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully subscribed to "${widget.name}"!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Gọi hàm makePayment với phí của gói dịch vụ
        makePayment(widget.fee);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to subscribe: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate =
        DateTime.now().add(Duration(days: 365)); // One year from now

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != _startDate) {
      if (mounted) {
        setState(() {
          _startDate = pickedDate;
          _endDate = DateTime(pickedDate.year,
              pickedDate.month + widget.duration, pickedDate.day);
        });
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    String userId = widget.memberId;

    try {
      // Cập nhật trạng thái gói dịch vụ
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buyPackages')
          .where('userId', isEqualTo: userId)
          .where('packageId', isEqualTo: widget.docId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;

        if (newStatus == 'cancelled') {
          // Xóa gói dịch vụ khỏi collection buyPackages
          await docRef.delete();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Package cancelled and removed from your subscriptions.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Cập nhật trạng thái gói dịch vụ
          await docRef.update({
            'status': newStatus,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Package status updated to "$newStatus".'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (mounted) {
          setState(() {
            _status = newStatus;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('buyPackages')
          .where('userId', isEqualTo: widget.memberId)
          .where('packageId', isEqualTo: widget.docId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isSubscribed = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        bool isExpired = isSubscribed &&
            _endDate != null &&
            _endDate!.isBefore(DateTime.now());

        return Card(
          margin: EdgeInsets.all(12.0),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fee: \$${widget.fee}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Duration: ${widget.duration} months',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Description: ' + widget.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Trainer: ' +
                          (_trainerName ??
                              'Loading...'), // Hiển thị tên huấn luyện viên
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (_status != null) ...[
                      Text(
                        'Status: ${_status}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _status == 'wait for confirmation'
                              ? Colors.orange
                              : (_status == 'cancelled'
                                  ? Colors.red
                                  : Colors.black54),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          if (_status == 'wait for confirmation') ...[
                            // TextButton(
                            //   onPressed: () => _updateStatus('approved'),
                            //   child: Text('Approve'),
                            //   style: TextButton.styleFrom(
                            //     foregroundColor: Colors.green,
                            //   ),
                            // ),
                            // TextButton(
                            //   onPressed: () => _updateStatus('cancelled'),
                            //   child: Text('Cancel'),
                            //   style: TextButton.styleFrom(
                            //     foregroundColor: Colors.red,
                            //   ),
                            // ),
                          ],
                        ],
                      ),
                    ],
                    if (isSubscribed) ...[
                      Text(
                        'Start Date: ${_startDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.grey[400]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _startDate == null
                                  ? 'Select Start Date'
                                  : 'Start Date: ${_startDate!.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_startDate != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'Unknown Date'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                    if (isExpired)
                      Text(
                        'This package has expired.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey[300],
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: isSubscribed || isExpired
                        ? null
                        : () => _handleSubscribe(context),
                    child: Text(isSubscribed
                        ? 'Subscribed'
                        : isExpired
                            ? 'Expired'
                            : 'Subscribe'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: isSubscribed || isExpired
                          ? Colors.grey
                          : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              ),
              if (isSubscribed && !isExpired)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                ),
              if (_status == 'approved') // Check if the status is approved
                ElevatedButton(
                  onPressed: () async {
                    makePayment(widget.fee);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Text color
                    backgroundColor: Colors.green, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // Padding
                    elevation: 5, // Shadow elevation
                  ),
                  child: Text(
                    'Make Payment',
                    style: TextStyle(
                      fontSize: 18, // Text size
                      fontWeight: FontWeight.bold, // Text weight
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic>? paymentIntentData;
  Future<void> makePayment(int fee) async {
    try {
      paymentIntentData = await createPaymentIntent(fee);
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          merchantDisplayName: 'ANNIE',
          applePay: stripe.PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
          googlePay: stripe.PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );
      await displayPaymentSheet();
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(int fee) async {
    try {
      Map<String, dynamic> body = {
        'amount': (fee * 100).toString(), // Stripe expects amount in cents
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

  Future<void> displayPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      // When the payment is completed, perform signUp
    } catch (e) {
      if (e is stripe.StripeException) {
        print('StripeException: ${e.error.localizedMessage}');
      } else {
        print('Exception: $e');
      }
    }
  }
}
