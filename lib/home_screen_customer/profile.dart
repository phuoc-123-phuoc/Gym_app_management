import 'package:customer_app_multistore/auth/updatepassword.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/home_screen_customer/onboarding_screen.dart';
import 'package:customer_app_multistore/home_screen_customer/package_screen.dart';
import 'package:customer_app_multistore/config/palette.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  String _subscriptionInfo =
      'Loading...'; // Default message for subscription info

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('members').doc(user.uid).get();
      if (userSnapshot.exists) {
        setState(() {
          nameController.text = userSnapshot.get('name') ?? '';
          phoneController.text = userSnapshot.get('phone') ?? '';
          addressController.text = userSnapshot.get('address') ?? '';
          heightController.text = userSnapshot.get('height') ?? '';
          emailController.text = userSnapshot.get('email') ?? '';
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Onboardingscreen(),
        ),
      );
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out. Please try again.'),
        ),
      );
    }
  }

  Future<void> _saveUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('members').doc(user.uid).update({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'height': heightController.text,
          'email': emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
          ),
        );

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        print("Error updating profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        backgroundColor: Palette.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _showMenuDialog();
          },
        ),
        title: Text('User Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      'assets/images/baby_child_children_boy-512.png'),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(height: 20),
                _buildProfileField('Name', nameController),
                _buildProfileField('Phone Number', phoneController),
                _buildProfileField('Address', addressController),
                _buildProfileField('Height', heightController),
                _buildProfileField('Email', emailController),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60.0,
                    onPressed: () {
                      if (_isEditing) {
                        _saveUserData();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    color: Palette.secondaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Text(
                      _isEditing ? 'Save' : 'Edit',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60.0,
                    onPressed: () {
                      User? user = _auth.currentUser;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PackageScreenMembers(
                              memberId: user.uid,
                            ),
                          ),
                        );
                      }
                    },
                    color: Palette.primaryColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Text(
                      'Subscribe to a Package',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        enabled: _isEditing,
      ),
    );
  }

  void _showMenuDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Center(
          child: Text(
            'Menu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  _isEditing = true;
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () {
                Navigator.of(context).pop();
                _signOut();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdatePassword(),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
