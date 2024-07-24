import 'package:flutter/material.dart';
import 'package:customer_app_multistore/config/palette.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Palette.secondaryColor,
      automaticallyImplyLeading: false, // Disable the back button
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
