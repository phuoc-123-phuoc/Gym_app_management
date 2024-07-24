import 'package:flutter/material.dart';
import 'package:customer_app_multistore/home_screen_customer/buyclass.dart';
import 'package:customer_app_multistore/home_screens_admin/class_screen.dart';
import 'package:customer_app_multistore/home_screens_admin/equipments_screen.dart';
import 'package:customer_app_multistore/home_screens_admin/home_screen.dart';
import 'package:customer_app_multistore/home_screens_admin/inc_exp_screen.dart';
import 'package:customer_app_multistore/home_screens_admin/members_screen.dart';
import 'package:customer_app_multistore/home_screens_admin/trainers_screen.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final List<Widget> _screens = [
    TrainersScreen(),
    MembersScreen(),
    HomeScreen(),
    EquipmentsScreen(),
    // Class(),
    ClassScreen(),
    IncExpScreen(),
  ];

  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue[50],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        elevation: 0.0,
        items: [
          BottomNavigationBarItem(
            label: '',
            icon: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color:
                    _currentIndex == 0 ? Colors.blue[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(Icons.person),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color:
                    _currentIndex == 1 ? Colors.blue[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(Icons.group),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color:
                    _currentIndex == 2 ? Colors.blue[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(Icons.home),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color:
                    _currentIndex == 3 ? Colors.blue[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(Icons.fitness_center),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color:
                    _currentIndex == 4 ? Colors.blue[600] : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(Icons.class_sharp),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: _currentIndex == 5
                    ? Colors.blue[600]
                    : Colors
                        .transparent, // Chỉnh sửa chỉ số cuối cùng từ 4 thành 5
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(Icons.bar_chart),
            ),
          ),
        ],
      ),
    );
  }
}
