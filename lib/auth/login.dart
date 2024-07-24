import 'package:customer_app_multistore/auth/forgetpassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:customer_app_multistore/auth/singup.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/home_screen_customer/navigator.dart';
import 'package:customer_app_multistore/home_screens_admin/navigator.dart';
import 'package:customer_app_multistore/witget/make_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late ProgressDialog progress;

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        progress.close();
        if (emailController.text == 'admin@gmail.com' &&
            passwordController.text == '123456') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNav(), // Admin screen
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(), // Regular user screen
            ),
          );
        }
      }
    } catch (e) {
      progress.close();
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to login. Please check your credentials."),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      showProgress();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        progress.close();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User canceled login."),
          ),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user;
        // Check if the user's document exists
        DocumentSnapshot userSnapshot =
            await _firestore.collection('members').doc(user!.uid).get();
        if (!userSnapshot.exists) {
          // Create a new document with default values if it doesn't exist
          await _firestore.collection('members').doc(user.uid).set({
            'id': user.uid,
            'name': googleUser.displayName,
            'email': googleUser.email,
            'phone': '', // Set default values
            'address': '', // Set default values
            'height': '', // Set default values
          });
        }

        progress.close();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BottomNavBar(), // Replace with your Home Page widget
          ),
        );
      }
    } catch (e) {
      progress.close();
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign in with Google: $e"),
        ),
      );
    }
  }

  void showProgress() {
    progress.show(max: 100, msg: 'Please wait...', progressBgColor: Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    progress = ProgressDialog(context: context);

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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Login to your GYM',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPassword()));
                        },
                        child: const Text(
                          'Forget Password ?',
                          style: TextStyle(
                              fontSize: 18, fontStyle: FontStyle.italic),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Container(
                        padding: EdgeInsets.only(top: 3.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                            top: BorderSide(color: Colors.black),
                            left: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 60.0,
                          onPressed: () {
                            _login(context);
                          },
                          color: Color(0xFFC9C7F1),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(50.0)),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account? '),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _signInWithGoogle(context),
                      icon: Icon(Icons.login),
                      label: Text("Login with Google"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red, // text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/gym_coach_trainer_fitness-512.png'),
                          fit: BoxFit.fitHeight,
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
