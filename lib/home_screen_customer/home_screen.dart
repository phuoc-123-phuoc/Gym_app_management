import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:customer_app_multistore/witget/stats_grid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int membersCount = 0;
  int trainersCount = 0;
  int equipmentCount = 0;
  int classesCount = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Perform all queries concurrently
      List<QuerySnapshot> snapshots = await Future.wait([
        FirebaseFirestore.instance.collection('members').get(),
        FirebaseFirestore.instance.collection('trainers').get(),
        FirebaseFirestore.instance.collection('equipments').get(),
        FirebaseFirestore.instance.collection('classes').get(),
      ]);

      setState(() {
        membersCount = snapshots[0].size;
        trainersCount = snapshots[1].size;
        equipmentCount = snapshots[2].size;
        classesCount = snapshots[3].size;
      });
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Dashboard'),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatsGrid(
                      'Income',
                      'Rs. 4,500.00',
                      'assets/images/increase_presentation_Profit_growth-512.png',
                    ),
                    StatsGrid(
                      'Expense',
                      'Rs. 1,500.00',
                      'assets/images/decrease_presentation_down_loss-512.png',
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatsGrid(
                    'Members',
                    membersCount.toString(),
                    'assets/images/family_tree_members_people-512.png',
                  ),
                  StatsGrid(
                    'Trainers',
                    trainersCount.toString(),
                    'assets/images/gym_coach_trainer_fitness-512.png',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatsGrid(
                    'Equipments',
                    equipmentCount.toString(),
                    'assets/images/dumbbell_gym_fitness_exercise-512.png',
                  ),
                  StatsGrid(
                    'Classes',
                    classesCount.toString(),
                    'assets/images/gym_club_fitness_center-512.png',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
