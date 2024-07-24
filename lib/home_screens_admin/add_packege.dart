import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddPackage extends StatefulWidget {
  final DocumentSnapshot? packageData; // Tham số để nhận dữ liệu package

  AddPackage({this.packageData});

  @override
  _AddPackageState createState() => _AddPackageState();
}

class _AddPackageState extends State<AddPackage> {
  final _formKey = GlobalKey<FormState>();
  late String packageName;
  late double packageFee;
  late String packageDescription;
  late int selectedDuration;
  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.packageData != null) {
      // Initialize form fields with data if available
      packageName = widget.packageData?['name'] ?? '';
      packageFee = widget.packageData?['fee']?.toDouble() ?? 0.0;
      packageDescription = widget.packageData?['description'] ?? '';
      selectedDuration =
          widget.packageData?['duration'] ?? 3; // Default to 3 months
    } else {
      // Default values
      packageName = '';
      packageFee = 0.0;
      packageDescription = '';
      selectedDuration = 3; // Default to 3 months
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('package_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.png');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> _addOrUpdatePackage() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      try {
        if (widget.packageData == null) {
          // Thêm gói mới
          DocumentReference docRef =
              await FirebaseFirestore.instance.collection('packages').add({
            'name': packageName,
            'fee': packageFee,
            'duration': selectedDuration,
            'description': packageDescription,
            'image_url': imageUrl,
          });

          // Lấy ID của gói vừa thêm
          String packageId = docRef.id;

          // Cập nhật tài liệu với ID của gói
          await docRef.update({'id': packageId});
        } else {
          // Cập nhật gói hiện có
          await FirebaseFirestore.instance
              .collection('packages')
              .doc(widget.packageData!.id)
              .update({
            'name': packageName,
            'fee': packageFee,
            'duration': selectedDuration,
            'description': packageDescription,
            'image_url': imageUrl ?? widget.packageData?['image_url'],
          });
        }

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Package ${widget.packageData == null ? 'added' : 'updated'} successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        print(
            'Failed to ${widget.packageData == null ? 'add' : 'update'} package: $e');
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${widget.packageData == null ? 'add' : 'update'} package. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePackage(String packageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('packages')
          .doc(packageId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Package deleted successfully!'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Failed to delete package: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete package. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar(
          widget.packageData == null ? 'Add Package' : 'Edit Package'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : widget.packageData?['image_url'] != null
                            ? DecorationImage(
                                image: NetworkImage(
                                    widget.packageData!['image_url']),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child:
                      _image == null && widget.packageData?['image_url'] == null
                          ? Center(
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            )
                          : null,
                ),
              ),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: packageName,
                      decoration: InputDecoration(
                        labelText: 'Package Name',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          packageName = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter package name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: packageFee.toString(),
                      decoration: InputDecoration(
                        labelText: 'Package Fee',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          packageFee = double.tryParse(value) ?? 0.0;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter package fee';
                        }
                        final fee = double.tryParse(value) ?? 0.0;
                        if (fee <= 0) {
                          return 'Package fee must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedDuration,
                      decoration: InputDecoration(
                        labelText: 'Duration (Months)',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedDuration = newValue!;
                        });
                      },
                      items: [3, 6, 12].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value months'),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: packageDescription,
                      decoration: InputDecoration(
                        labelText: 'Package Description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          packageDescription = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter package description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _image == null ? null : _addOrUpdatePackage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _image == null ? Colors.grey : Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  widget.packageData == null ? 'Add Package' : 'Update Package',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(height: 24),
              if (widget.packageData != null)
                ElevatedButton(
                  onPressed: () => _deletePackage(widget.packageData!.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Delete Package',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              SizedBox(height: 24),
              _buildPackageList(), // Hiển thị danh sách gói dưới nút Add/Update
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('packages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child:
                  CircularProgressIndicator()); // Hiển thị loading khi đang tải dữ liệu
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Hiển thị lỗi nếu có
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
              'No packages available.'); // Hiển thị thông báo nếu không có dữ liệu
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No Name';
            final fee = data['fee']?.toDouble() ?? 0.0;
            final description = data['description'] ?? 'No Description';
            final duration = data['duration'] ?? 0;
            final imageUrl = data['image_url'] ?? '';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                leading: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[600],
                          size: 30,
                        ),
                      ),
                title: Text(
                  'Name: ' + name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Fee: ' + '$fee \$\n$duration months\n',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                contentPadding: EdgeInsets.all(12),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPackage(packageData: doc),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8), // Add some space between icons
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        _deletePackage(doc.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
