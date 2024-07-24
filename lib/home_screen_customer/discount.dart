import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiscountCodeScreen extends StatelessWidget {
  static const String id = "discountCodeScreen";
  final String currentUserId;

  DiscountCodeScreen({required this.currentUserId});

  Future<List<Map<String, dynamic>>> _fetchDiscountCodes() async {
    // Fetch all discount codes
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('sale').get();

    List<Map<String, dynamic>> discountCodes = [];

    // Filter discount codes locally in Dart
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      // Add discount codes with null userId or current userId
      if (data['userId'] == null || data['userId'] == currentUserId) {
        discountCodes.add(data);
      }
    }

    return discountCodes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Discount'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDiscountCodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No discount codes available.'),
            );
          }
          List<Map<String, dynamic>> discountCodes = snapshot.data!;
          return ListView.builder(
            itemCount: discountCodes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, discountCodes[index]);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      discountCodes[index]['codeName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent.shade700,
                      ),
                    ),
                    subtitle: Text(
                      '${discountCodes[index]['percentage']}% off\nExpires: ${DateFormat.yMMMd().format(discountCodes[index]['expiryDate'].toDate())}',
                    ),
                    trailing: Icon(
                      Icons.local_offer,
                      color: Colors.pinkAccent.shade700,
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
