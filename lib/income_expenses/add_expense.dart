import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/make_input.dart';

class AddExpense extends StatefulWidget {
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController dateController = TextEditingController()
    ..text = 'Please select a Date.';

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        title: Text('Add Expenses'),
        backgroundColor: Palette.secondaryColor,
      ),
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
                      child: Center(
                        child: Text(
                          'Enter Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MakeInput(
                        label: 'Title',
                        obscureText: false,
                        controllerID: titleController,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          TextField(
                            controller: dateController,
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0.0,
                                horizontal: 10.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[400]!,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            child: Text('Pick a Date'),
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2001),
                                lastDate: DateTime(2100),
                              ).then((DateTime? _dateTime) {
                                if (_dateTime != null) {
                                  setState(() {
                                    dateController.text =
                                        _dateTime.toIso8601String();
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      MakeInput(
                        label: 'Amount',
                        obscureText: false,
                        controllerID: amountController,
                      ),
                      MakeInput(
                        label: 'Expense Details',
                        obscureText: false,
                        controllerID: detailsController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Palette.secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Get the input values
                  String title = titleController.text;
                  String amount = amountController.text;
                  String details = detailsController.text;
                  String date = dateController.text;

                  // Validate the inputs
                  if (title.isEmpty ||
                      amount.isEmpty ||
                      details.isEmpty ||
                      date == 'Please select a Date.') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill all the fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create a new document reference
                  DocumentReference docRef =
                      FirebaseFirestore.instance.collection('expense').doc();

                  // Save to Firestore
                  await docRef.set({
                    'id': docRef.id,
                    'title': title,
                    'amount': amount,
                    'details': details,
                    'date': date,
                  });

                  // Clear the fields
                  titleController.clear();
                  amountController.clear();
                  detailsController.clear();
                  dateController.text = 'Please select a Date.';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Expense added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Confirm Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
