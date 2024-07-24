import 'package:customer_app_multistore/home_screens_admin/add_discount.dart';
import 'package:customer_app_multistore/home_screens_admin/add_packege.dart';
import 'package:customer_app_multistore/home_screens_admin/history.dart';
import 'package:flutter/material.dart';
import 'package:customer_app_multistore/config/palette.dart';
import 'package:customer_app_multistore/income_expenses/add_expense.dart';
import 'package:customer_app_multistore/income_expenses/add_income.dart';
import 'package:customer_app_multistore/income_expenses/view_expense.dart';
import 'package:customer_app_multistore/income_expenses/view_income.dart';
import 'package:customer_app_multistore/witget/custom_app_bar.dart';
import 'package:customer_app_multistore/witget/custom_card_re.dart';

class IncExpScreen extends StatefulWidget {
  @override
  _IncExpScreenState createState() => _IncExpScreenState();
}

class _IncExpScreenState extends State<IncExpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar('Revenue & Expenses'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomCardRE(
                  imagePath:
                      'assets/images/increase_presentation_Profit_growth-512.png',
                  type: 'Incomes',
                  view: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewIncome(),
                      ),
                    );
                  },
                  add: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIncome(),
                      ),
                    );
                  },
                ),
                CustomCardRE(
                  imagePath:
                      'assets/images/decrease_presentation_down_loss-512.png',
                  type: 'Packages',
                  view: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllHistoryPackagesScreen(),
                      ),
                    );
                  },
                  add: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPackage(),
                      ),
                    );
                  },
                ),
                CustomCardRE(
                  imagePath:
                      'assets/images/decrease_presentation_down_loss-512.png',
                  type: 'Expenses',
                  view: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewExpense(),
                      ),
                    );
                  },
                  add: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpense(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20), // Thêm khoảng cách giữa các phần tử
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SalePage(), // Navigate to AddDiscount screen
                      ),
                    );
                  },
                  child: Text(
                    'Add Discount Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.secondaryColor, // Màu nền của nút
                    padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12), // Khoảng cách giữa nội dung và viền nút
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Đường viền bo tròn
                    ),
                    elevation: 5, // Độ cao bóng của nút
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
