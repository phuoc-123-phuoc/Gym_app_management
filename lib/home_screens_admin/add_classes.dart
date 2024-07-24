import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/make_input.dart';

class AddClasses extends StatefulWidget {
  final DocumentSnapshot? classData;

  const AddClasses({Key? key, this.classData}) : super(key: key);

  @override
  _AddClassesState createState() => _AddClassesState();
}

class _AddClassesState extends State<AddClasses> {
  late TextEditingController nameController;
  late TextEditingController feeController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController maxMembersController;

  late ProgressDialog progress;

  String? selectedTrainer;
  List<DropdownMenuItem<String>> trainerItems = [];

  @override
  void initState() {
    super.initState();
    progress = ProgressDialog(context: context);

    nameController = TextEditingController(
        text: widget.classData != null ? widget.classData!['name'] : '');
    feeController = TextEditingController(
        text: widget.classData != null ? widget.classData!['fee'] : '');
    startDateController = TextEditingController(
        text: widget.classData != null ? widget.classData!['start_date'] : '');
    endDateController = TextEditingController(
        text: widget.classData != null ? widget.classData!['end_date'] : '');
    startTimeController = TextEditingController(
        text: widget.classData != null ? widget.classData!['start_time'] : '');
    endTimeController = TextEditingController(
        text: widget.classData != null ? widget.classData!['end_time'] : '');
    maxMembersController = TextEditingController(
        text: widget.classData != null ? widget.classData!['max_members'] : '');

    fetchTrainers();
  }

  void fetchTrainers() async {
    var trainers =
        await FirebaseFirestore.instance.collection('trainers').get();
    List<DropdownMenuItem<String>> items = trainers.docs
        .map((doc) => DropdownMenuItem<String>(
              value: doc.id,
              child: Text(doc['name']),
            ))
        .toList();
    setState(() {
      trainerItems = items;
    });
  }

  void showProgress() {
    progress.show(max: 100, msg: 'Please wait ..', progressBgColor: Colors.red);
  }

  void hideProgress() {
    progress.close();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  bool _validateFields() {
    if (nameController.text.isEmpty ||
        feeController.text.isEmpty ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty ||
        maxMembersController.text.isEmpty ||
        selectedTrainer == null) {
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        title: Text(widget.classData != null ? 'Edit Class' : 'Add Class'),
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
                          'Enter Class Details',
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
                        label: 'Class Name',
                        obscureText: false,
                        controllerID: nameController,
                      ),
                      MakeInput(
                        label: 'Registration Fee',
                        obscureText: false,
                        controllerID: feeController,
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context, startDateController),
                        child: AbsorbPointer(
                          child: MakeInput(
                            label: 'Start Date',
                            obscureText: false,
                            controllerID: startDateController,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context, endDateController),
                        child: AbsorbPointer(
                          child: MakeInput(
                            label: 'End Date',
                            obscureText: false,
                            controllerID: endDateController,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectTime(context, startTimeController),
                        child: AbsorbPointer(
                          child: MakeInput(
                            label: 'Start Time',
                            obscureText: false,
                            controllerID: startTimeController,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectTime(context, endTimeController),
                        child: AbsorbPointer(
                          child: MakeInput(
                            label: 'End Time',
                            obscureText: false,
                            controllerID: endTimeController,
                          ),
                        ),
                      ),
                      MakeInput(
                        label: 'Max Members',
                        obscureText: false,
                        controllerID: maxMembersController,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedTrainer,
                        items: trainerItems,
                        onChanged: (value) {
                          setState(() {
                            selectedTrainer = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Trainer',
                          border: OutlineInputBorder(),
                        ),
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
                  if (_validateFields()) {
                    showProgress();

                    try {
                      if (widget.classData != null) {
                        // Perform update
                        await FirebaseFirestore.instance
                            .collection('classes')
                            .doc(widget.classData!.id)
                            .update({
                          'name': nameController.text,
                          'fee': feeController.text,
                          'start_date': startDateController.text,
                          'end_date': endDateController.text,
                          'start_time': startTimeController.text,
                          'end_time': endTimeController.text,
                          'max_members': maxMembersController.text,
                          'trainer_id': selectedTrainer,
                        });
                      } else {
                        // Perform add new
                        await FirebaseFirestore.instance
                            .collection('classes')
                            .add({
                          'name': nameController.text,
                          'fee': feeController.text,
                          'start_date': startDateController.text,
                          'end_date': endDateController.text,
                          'start_time': startTimeController.text,
                          'end_time': endTimeController.text,
                          'max_members': maxMembersController.text,
                          'trainer_id': selectedTrainer,
                        });
                      }

                      // Clear all the controllers after data is saved
                      nameController.clear();
                      feeController.clear();
                      startDateController.clear();
                      endDateController.clear();
                      startTimeController.clear();
                      endTimeController.clear();
                      maxMembersController.clear();
                      setState(() {
                        selectedTrainer = null;
                      });
                    } catch (e) {
                      // Handle error
                      print(e);
                    } finally {
                      hideProgress();
                    }
                  } else {
                    _showErrorDialog('Please fill in all fields');
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
