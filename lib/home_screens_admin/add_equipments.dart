import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/make_input.dart';

class AddEquipments extends StatefulWidget {
  final QueryDocumentSnapshot? equipmentToEdit;

  AddEquipments({this.equipmentToEdit});

  @override
  _AddEquipmentsState createState() => _AddEquipmentsState();
}

class _AddEquipmentsState extends State<AddEquipments> {
  late TextEditingController _eqnameController;
  String? _selectedCategory;
  String? _selectedStatus;
  late TextEditingController _dojController;
  late TextEditingController _dopController;
  late TextEditingController _quantityController;
  late TextEditingController _deviceCodeController;
  File? _image;

  List<String> categories = ['Treadmill', 'Weights', 'Elliptical', 'Others'];
  List<String> statuses = ['New', 'Used', 'Under Maintenance'];

  @override
  void initState() {
    super.initState();
    _eqnameController = TextEditingController();
    _dojController = TextEditingController();
    _dopController = TextEditingController();
    _quantityController = TextEditingController();
    _deviceCodeController = TextEditingController();

    if (widget.equipmentToEdit != null) {
      _eqnameController.text = widget.equipmentToEdit!['name'];
      _selectedCategory = widget.equipmentToEdit!['category'];
      _selectedStatus = widget.equipmentToEdit!['status'];
      _dojController.text = widget.equipmentToEdit!['date_of_joining'];
      _dopController.text = widget.equipmentToEdit!['date_of_purchase'];
      _quantityController.text = widget.equipmentToEdit!['quantity'];
      _deviceCodeController.text = widget.equipmentToEdit!['device_code'];
    } else {
      _dojController.text = 'Please select Date of Joining.';
      _dopController.text = 'Please select Date of Purchase.';
    }
  }

  @override
  void dispose() {
    _eqnameController.dispose();
    _dojController.dispose();
    _dopController.dispose();
    _quantityController.dispose();
    _deviceCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveEquipment() async {
    if (_eqnameController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedStatus == null ||
        _dojController.text == 'Please select Date of Joining.' ||
        _dopController.text == 'Please select Date of Purchase.' ||
        _quantityController.text.isEmpty ||
        _deviceCodeController.text.isEmpty ||
        _image == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Incomplete Details'),
            content: Text('Please fill all the fields.'),
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
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    String imageUrl = '';
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(
          'equipment_images/${_eqnameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload image. Please try again later.'),
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
      return;
    }

    try {
      if (widget.equipmentToEdit == null) {
        String id =
            FirebaseFirestore.instance.collection('equipments').doc().id;
        await FirebaseFirestore.instance.collection('equipments').doc(id).set({
          'id': id,
          'name': _eqnameController.text,
          'category': _selectedCategory,
          'status': _selectedStatus,
          'date_of_joining': _dojController.text,
          'date_of_purchase': _dopController.text,
          'quantity': _quantityController.text,
          'device_code': _deviceCodeController.text,
          'imageUrl': imageUrl,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('equipments')
            .doc(widget.equipmentToEdit!.id)
            .update({
          'name': _eqnameController.text,
          'category': _selectedCategory,
          'status': _selectedStatus,
          'date_of_joining': _dojController.text,
          'date_of_purchase': _dopController.text,
          'quantity': _quantityController.text,
          'device_code': _deviceCodeController.text,
          'imageUrl': imageUrl,
        });
      }

      _eqnameController.clear();
      _selectedCategory = null;
      _selectedStatus = null;
      _dojController.text = 'Please select Date of Joining.';
      _dopController.text = 'Please select Date of Purchase.';
      _quantityController.clear();
      _deviceCodeController.clear();
      setState(() {
        _image = null;
      });

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Equipment saved successfully!'),
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
    } catch (error) {
      print('Failed to save equipment: $error');
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save equipment. Please try again later.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        title: Text(widget.equipmentToEdit == null
            ? 'Add Equipments'
            : 'Edit Equipments'),
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
                          widget.equipmentToEdit == null
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
                        label: 'Equipment Name',
                        obscureText: false,
                        controllerID: _eqnameController,
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[200],
                            ),
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              isExpanded: true,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.transparent,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              },
                              items: categories.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[200],
                            ),
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              isExpanded: true,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.transparent,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStatus = newValue;
                                });
                              },
                              items: statuses.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      MakeInput(
                        label: 'Quantity',
                        obscureText: false,
                        controllerID: _quantityController,
                      ),
                      SizedBox(height: 20.0),
                      MakeInput(
                        label: 'Device Code',
                        obscureText: false,
                        controllerID: _deviceCodeController,
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Joining',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          TextField(
                            controller: _dojController,
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
                                    _dojController.text =
                                        '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Purchase',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          TextField(
                            controller: _dopController,
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
                                    _dopController.text =
                                        '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
                                  });
                                }
                              });
                            },
                          ),
                          SizedBox(height: 20.0),
                          Text(
                            'Select Equipment Image',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          _image != null
                              ? Image.file(_image!, height: 150.0, width: 150.0)
                              : Text('No image selected.'),
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: Text('Pick an Image'),
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
                onPressed: _saveEquipment,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    Text(
                      widget.equipmentToEdit == null
                          ? 'Confirm Details'
                          : 'Save Changes',
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
