import 'package:customer_app_multistore/home_screen_customer/discount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:customer_app_multistore/auth/home_page.dart';
import 'package:customer_app_multistore/home_screen_customer/onboarding_screen.dart';
import 'package:customer_app_multistore/home_screen_customer/navigator.dart';
import 'package:customer_app_multistore/home_screens_admin/navigator.dart';
import 'package:customer_app_multistore/provider/stripe_id.dart';
import 'package:customer_app_multistore/witget/theme.dart';
// Import DiscountCodeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(ThemeData.light()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeProvider.getTheme(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.getTheme().brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: AuthGate(),
          debugShowCheckedModeBanner: false,
          routes: {
            DiscountCodeScreen.id: (context) => DiscountCodeScreen(
                currentUserId: FirebaseAuth.instance.currentUser!.uid),
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // Nếu người dùng đã đăng nhập, kiểm tra xem họ có phải là admin không
            User? user = snapshot.data;
            if (user != null && user.email == 'admin@gmail.com') {
              return BottomNav(); // Trang Admin
            } else {
              return BottomNavBar(); // Trang người dùng bình thường
            }
          } else {
            return Onboardingscreen(); // Trang Đăng Nhập
          }
        }
        return Center(
            child:
                CircularProgressIndicator()); // Hiển thị progress indicator khi kiểm tra trạng thái đăng nhập
      },
    );
  }
}
