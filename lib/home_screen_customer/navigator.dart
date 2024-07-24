import 'package:customer_app_multistore/home_screen_customer/discount.dart';
import 'package:customer_app_multistore/home_screen_customer/package_screen_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:customer_app_multistore/home_screen_customer/buyclass.dart';
import 'package:customer_app_multistore/home_screen_customer/class.dart';
import 'package:customer_app_multistore/home_screen_customer/equipments_screen.dart';
import 'package:customer_app_multistore/home_screen_customer/profile.dart';
import 'package:customer_app_multistore/home_screen_customer/trainers_screen.dart';
import 'package:customer_app_multistore/home_screen_customer/package_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final String memberId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<Widget> _screens = [
    EquipmentsScreen(),
    TrainersScreen(),
    Class(),
    BuyClassScreen(),
    PackageScreen(memberId: FirebaseAuth.instance.currentUser?.uid ?? ''),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.device_hub_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.personal_injury_outlined),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue[50],
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey,
        elevation: 0.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
