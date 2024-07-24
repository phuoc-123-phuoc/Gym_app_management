import 'package:flutter/material.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/make_input.dart';

class AddIncome extends StatefulWidget {
  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController dateController = TextEditingController()
    ..text = 'Please select a Date.';

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    void saveIncome() {
      // ref
      //     .child('Incomes') // Change this to your desired database path
      //     .child(auth.currentUser!.uid) // Store incomes per user
      //     .child(DateFormat('yyyy-MM-dd').format(today))
      //     .push()
      //     .set({
      //   'Title': titleController.text,
      //   'Amount': amountController.text,
      //   'Details': detailsController.text,
      //   'Date': dateController.text,
      // }).then((_) {
      //   // Clear input fields after successful save
      //   titleController.clear();
      //   amountController.clear();
      //   detailsController.clear();
      //   dateController.clear();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Income added successfully'),
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      // }).catchError((error) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to add income: $error'),
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      // });
    }

    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        title: Text('Add Incomes'),
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
                                  // setState(() {
                                  //   dateController.text =
                                  //       DateFormat('yyyy-MM-dd')
                                  //           .format(_dateTime);
                                  // });
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
                        label: 'Income Details',
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
                onPressed: () => saveIncome(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                      size: 40.0,
                    ),
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
