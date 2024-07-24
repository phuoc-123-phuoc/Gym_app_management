import 'package:flutter/material.dart';
import 'package:customer_app_multistore/auth/login.dart';
import 'package:customer_app_multistore/auth/singup.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/home_screens_admin/navigator.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      'WELCOME',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 30.0,
                        // decoration: TextDecoration.underline,
                        // decorationStyle: TextDecorationStyle.wavy,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'My GYM Manager enables you to manage your GYM related activities at your finger tips!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/gym_club_fitness_center-512.png'),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 3.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                          ),
                          top: BorderSide(
                            color: Colors.black,
                          ),
                          left: BorderSide(
                            color: Colors.black,
                          ),
                          right: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 50.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (context) => BottomNavBar(),
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        color: Color(0xFFC9C7F1),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.black,
                            ),
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
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 3.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                          ),
                          top: BorderSide(
                            color: Colors.black,
                          ),
                          left: BorderSide(
                            color: Colors.black,
                          ),
                          right: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 50.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupPage(),
                            ),
                          );
                        },
                        color: Colors.purple[200],
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(50.0)),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0,
                          ),
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
