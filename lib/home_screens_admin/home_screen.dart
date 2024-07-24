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
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double totalPackage = 0.0;
  double hispackage = 0.0;

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
        FirebaseFirestore.instance.collection('buyclasses').get(),
        FirebaseFirestore.instance.collection('expense').get(),
        FirebaseFirestore.instance.collection('buyPackages').get(),
        FirebaseFirestore.instance.collection('historyPackages').get(),
      ]);

      double income = 0.0;
      for (var doc in snapshots[4].docs) {
        // Convert class_fee to double if it's a string
        String feeStr = doc['class_fee'];
        double fee = double.tryParse(feeStr) ?? 0.0;
        income += fee;
      }
      double expense = 0.0;
      for (var doc in snapshots[5].docs) {
        // Convert amount to double if it's a string
        String feeStr = doc['amount'];
        double fee = double.tryParse(feeStr) ?? 0.0;
        expense += fee;
      }
      double package = 0.0;
      for (var doc in snapshots[6].docs) {
        // Handle cases where fee might be an int or a string
        String feeStr = doc['fee'].toString();
        double fee = double.tryParse(feeStr) ?? 0.0;
        package += fee;
      }
      double hispack = 0.0;
      for (var doc in snapshots[7].docs) {
        // Handle cases where fee might be an int or a string
        String feeStr = doc['fee'].toString();
        double fee = double.tryParse(feeStr) ?? 0.0;
        hispack += fee;
      }

      setState(() {
        membersCount = snapshots[0].size;
        trainersCount = snapshots[1].size;
        equipmentCount = snapshots[2].size;
        classesCount = snapshots[3].size;
        totalIncome = income;
        totalExpense = expense;
        totalPackage = package;
        hispackage = hispack;
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
                      'Rs. ${(totalIncome + totalPackage + hispackage).toStringAsFixed(2)}',
                      'assets/images/increase_presentation_Profit_growth-512.png',
                    ),
                    StatsGrid(
                      'Expense',
                      'Rs. ${totalExpense.toStringAsFixed(2)}',
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
