import 'package:flutter/material.dart';
import 'package:customer_app_multistore/config/palette.dart';

class CustomCardRE extends StatelessWidget {
  final String imagePath;
  final String type;
  final VoidCallback add;
  final VoidCallback view;

  CustomCardRE({
    required this.imagePath,
    required this.type,
    required this.add,
    required this.view,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      color: Colors.grey[350],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 84.0,
          ),
          Text(
            type,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Palette.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            onPressed: view,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.list_alt,
                  color: Colors.white,
                  size: 40.0,
                ),
                Text(
                  'View $type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Conditionally render the 'Add New' button based on type
          if (type != 'Incomes')
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Palette.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onPressed: add,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 40.0,
                  ),
                  Text(
                    'Add New $type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
