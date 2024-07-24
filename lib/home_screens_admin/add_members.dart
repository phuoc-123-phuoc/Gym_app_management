import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/make_input.dart';

class AddMembers extends StatefulWidget {
  final String? memberId; // Thêm memberId để phân biệt thêm mới và chỉnh sửa

  AddMembers({this.memberId});

  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController regdateController = TextEditingController()
    ..text = 'Please select a Registration Date.';
  final TextEditingController wtController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController feeController = TextEditingController();

  late ProgressDialog progress;

  @override
  void initState() {
    super.initState();
    progress = ProgressDialog(context: context);

    // Nếu đang trong chế độ chỉnh sửa, fetch dữ liệu thành viên từ Firestore
    if (widget.memberId != null) {
      fetchMemberDetails();
    }
  }

  void fetchMemberDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.memberId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = data['name'];
          addressController.text = data['address'];
          phoneController.text = data['phone'];
          regdateController.text = data['registration_date'];
          wtController.text = data['workout_type'];
          heightController.text = data['height'];
          feeController.text = data['fee'];
        });
      } else {
        // Handle case where member data does not exist
      }
    } catch (e) {
      print('Error fetching member details: $e');
      // Handle error
    }
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
        wtController.text.isEmpty ||
        heightController.text.isEmpty ||
        feeController.text.isEmpty) {
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
        title: Text(widget.memberId == null ? 'Add Members' : 'Edit Member'),
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
                          widget.memberId == null
                              ? 'Enter Details'
                              : 'Edit Details',
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
                        label: 'Workout Type',
                        obscureText: false,
                        controllerID: wtController,
                      ),
                      MakeInput(
                        label: 'Height',
                        obscureText: false,
                        controllerID: heightController,
                      ),
                      MakeInput(
                        label: 'Fee',
                        obscureText: false,
                        controllerID: feeController,
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
                      if (widget.memberId == null) {
                        // Thêm thành viên mới vào Firestore
                        String id = FirebaseFirestore.instance
                            .collection('members')
                            .doc()
                            .id;
                        await FirebaseFirestore.instance
                            .collection('members')
                            .doc(id)
                            .set({
                          'id': id,
                          'name': nameController.text,
                          'address': addressController.text,
                          'phone': phoneController.text,
                          'registration_date': regdateController.text,
                          'workout_type': wtController.text,
                          'height': heightController.text,
                          'fee': feeController.text,
                        });
                      } else {
                        // Cập nhật thông tin thành viên đã tồn tại trong Firestore
                        await FirebaseFirestore.instance
                            .collection('members')
                            .doc(widget.memberId)
                            .update({
                          'name': nameController.text,
                          'address': addressController.text,
                          'phone': phoneController.text,
                          'registration_date': regdateController.text,
                          'workout_type': wtController.text,
                          'height': heightController.text,
                          'fee': feeController.text,
                        });
                      }

                      // Clear all the controllers after data is saved
                      nameController.clear();
                      addressController.clear();
                      phoneController.clear();
                      regdateController.text =
                          'Please select a Registration Date.';
                      wtController.clear();
                      heightController.clear();
                      feeController.clear();
                    } catch (e) {
                      print('Error saving member details: $e');
                      // Handle error
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
