import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app_multistore/auth/login.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/home_screen_customer/navigator.dart';
import 'package:customer_app_multistore/witget/make_input.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signup(BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        User? user = userCredential.user;

        // Lưu thông tin người dùng vào Firestore
        await FirebaseFirestore.instance
            .collection('members')
            .doc(user!.uid)
            .set({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'height': heightController.text,
          'email': emailController.text,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(), // Regular user screen
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign up. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Palette.secondaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20.0,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      'Create your GYM account',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                MakeInput(
                  label: 'Name',
                  obscureText: false,
                  controllerID: nameController,
                ),
                MakeInput(
                  label: 'Phone Number',
                  obscureText: false,
                  controllerID: phoneController,
                ),
                MakeInput(
                  label: 'Address',
                  obscureText: false,
                  controllerID: addressController,
                ),
                MakeInput(
                  label: 'Height',
                  obscureText: false,
                  controllerID: heightController,
                ),
                MakeInput(
                  label: 'Email',
                  obscureText: false,
                  controllerID: emailController,
                ),
                MakeInput(
                  label: 'Password',
                  obscureText: true,
                  controllerID: passwordController,
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(top: 3.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(color: Colors.black),
                  ),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60.0,
                    onPressed: () {
                      _signup(context);
                    },
                    color: Color(0xFFC9C7F1),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginPage(), // Trở về trang đăng nhập
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
