import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_app_multistore/auth/home_page.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/home_screen_customer/onboarding_screen.dart';
import 'package:customer_app_multistore/witget/theme.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gymnameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: 250.0,
      child: Drawer(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.0),
          color: Palette.secondaryColor,
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 25.0),
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://cdn1.iconfinder.com/data/icons/engineer-construction/512/engineer_worker_avatar_mechanics-256.png'),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Text('Update Your Details in Settings!'),
                SizedBox(height: 10.0),
                Divider(color: Colors.black),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0),
                  ),
                  onTap: () {
                    // Toggle theme mode
                    themeProvider.toggleTheme();
                    Navigator.of(context)
                        .pop(); // Đóng Drawer sau khi chọn cài đặt
                  },
                ),
                Divider(color: Colors.black),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Log Out',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Onboardingscreen(), // Chuyển hướng về trang đăng nhập
                      ),
                    );
                  },
                ),
                Divider(color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
