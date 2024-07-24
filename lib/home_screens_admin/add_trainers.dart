import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/make_input.dart';

class AddTrainers extends StatefulWidget {
  final DocumentSnapshot? trainer;

  const AddTrainers({Key? key, this.trainer}) : super(key: key);

  @override
  _AddTrainersState createState() => _AddTrainersState();
}

class _AddTrainersState extends State<AddTrainers> {
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController regdateController;
  late TextEditingController qualificationController;
  late TextEditingController salaryController;

  late ProgressDialog progress;

  @override
  void initState() {
    super.initState();
    progress = ProgressDialog(context: context);

    nameController = TextEditingController(
        text: widget.trainer != null ? widget.trainer!['name'] : '');
    addressController = TextEditingController(
        text: widget.trainer != null ? widget.trainer!['address'] : '');
    phoneController = TextEditingController(
        text: widget.trainer != null ? widget.trainer!['phone'] : '');
    regdateController = TextEditingController(
        text: widget.trainer != null
            ? widget.trainer!['registration_date']
            : 'Please select a Registration Date.');
    qualificationController = TextEditingController(
        text: widget.trainer != null ? widget.trainer!['qualifications'] : '');
    salaryController = TextEditingController(
        text: widget.trainer != null ? widget.trainer!['salary'] : '');
  }

  void showProgress() {
    progress.show(max: 100, msg: 'Please wait ..', progressBgColor: Colors.red);
  }

  void hideProgress() {
    progress.close();
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text(message),
        actions: [
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        phoneController.text.isEmpty ||
        regdateController.text == 'Please select a Registration Date.' ||
        qualificationController.text.isEmpty ||
        salaryController.text.isEmpty) {
      _showAlertDialog('Please fill in all fields');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        title: Text('Add Trainers'),
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
                              fontSize: 20.0),
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
                        label: 'Name',
                        obscureText: false,
                        controllerID: nameController,
                      ),
                      MakeInput(
                        label: 'Address',
                        obscureText: false,
                        controllerID: addressController,
                      ),
                      MakeInput(
                        label: 'Phone Number',
                        obscureText: false,
                        controllerID: phoneController,
                      ),
                      MakeInput(
                        label: 'Salary',
                        obscureText: false,
                        controllerID: salaryController,
                      ),
                      MakeInput(
                        label: 'Qualifications',
                        obscureText: false,
                        controllerID: qualificationController,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Date',
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
                            controller: regdateController,
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0.0,
                                horizontal: 10.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[400] ?? Colors.grey,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[400] ?? Colors.grey,
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
                              ).then((_dateTime) {
                                if (_dateTime != null) {
                                  setState(() {
                                    regdateController.text =
                                        '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
                                  });
                                }
                              });
                            },
                          ),
                        ],
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
                  if (_validateInputs()) {
                    showProgress();

                    try {
                      if (widget.trainer != null) {
                        // Perform update
                        await FirebaseFirestore.instance
                            .collection('trainers')
                            .doc(widget.trainer!.id)
                            .update({
                          'name': nameController.text,
                          'address': addressController.text,
                          'phone': phoneController.text,
                          'registration_date': regdateController.text,
                          'qualifications': qualificationController.text,
                          'salary': salaryController.text,
                        });
                      } else {
                        // Perform add new
                        await FirebaseFirestore.instance
                            .collection('trainers')
                            .add({
                          'name': nameController.text,
                          'address': addressController.text,
                          'phone': phoneController.text,
                          'registration_date': regdateController.text,
                          'qualifications': qualificationController.text,
                          'salary': salaryController.text,
                        });
                      }

                      // Clear all the controllers after data is saved
                      nameController.clear();
                      addressController.clear();
                      phoneController.clear();
                      regdateController.text =
                          'Please select a Registration Date.';
                      qualificationController.clear();
                      salaryController.clear();
                    } catch (e) {
                      // Handle error
                      print(e);
                    } finally {
                      hideProgress();
                    }
                  }
                },
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
