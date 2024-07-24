import 'package:flutter/material.dart';

class MakeInput extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controllerID;
  MakeInput(
      {required this.label,
      required this.obscureText,
      required this.controllerID});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        TextField(
          controller: controllerID,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 10.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    Colors.grey[400] ?? Colors.grey, // Provide a fallback color
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    Colors.grey[400] ?? Colors.grey, // Provide a fallback color
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
      ],
    );
  }
}
