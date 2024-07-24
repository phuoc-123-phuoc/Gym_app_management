import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:customer_app_multistore/auth/home_page.dart';

enum Offer {
  sale,
}

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({Key? key}) : super(key: key);

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen>
    with SingleTickerProviderStateMixin {
  Timer? countDowntimer;
  int seconds = 3;
  List<int> discountList = [];
  int? maxDiscount;
  late int selectedIndex;
  late String offerName;
  late String assetName;
  late Offer offer;
  late AnimationController _animationController;
  late Animation<Color?> _colorTweenAnimation;

  @override
  void initState() {
    super.initState();
    selectRandomOffer();
    startTimer();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _colorTweenAnimation = ColorTween(begin: Colors.black, end: Colors.red)
        .animate(_animationController)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    countDowntimer?.cancel();
    super.dispose();
  }

  void selectRandomOffer() {
    // [1= watches , 2= shoes , 3=sale]
    var random = Random();
    selectedIndex = random.nextInt(Offer.values.length);
    offerName = Offer.values[selectedIndex].toString();
    assetName = offerName.replaceAll("Offer.", "");
    offer = Offer.values[selectedIndex];
    print(selectedIndex);
    print(offerName);
    print(assetName);
  }

  void startTimer() {
    countDowntimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          seconds--;
        });
      }
      if (seconds < 0) {
        stopTimer();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(), // Regular user screen
          ),
        );
      }
    });
  }

  void stopTimer() {
    countDowntimer?.cancel();
  }

  Widget buildAsset() {
    return Image.asset('assets/images/onboard/$assetName.JPEG');
  }

  void navigateToOffer() {
    switch (offer) {
      case Offer.sale:
        // Add navigation logic here
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
              onTap: () {
                stopTimer();
                navigateToOffer();
              },
              child: buildAsset()),
          Positioned(
            top: 60,
            right: 30,
            child: Container(
              height: 35,
              width: 100,
              decoration: BoxDecoration(
                  color: Colors.grey.shade600.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25)),
              child: MaterialButton(
                onPressed: () {
                  stopTimer();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WelcomePage(), // Regular user screen
                    ),
                  );
                },
                child:
                    seconds < 1 ? const Text('Skip') : Text('Skip | $seconds'),
              ),
            ),
          ),
          offer == Offer.sale
              ? Positioned(
                  top: 180,
                  right: 74,
                  child: AnimatedOpacity(
                    duration: const Duration(microseconds: 100),
                    opacity: _animationController.value,
                    // child: Text(
                    //   maxDiscount.toString() + ('%'),
                    //   style: const TextStyle(
                    //       fontSize: 100,
                    //       color: Colors.amber,
                    //       fontFamily: 'AkayaTelivigala'),
                    // ),
                  ))
              : const SizedBox(),
          Positioned(
              bottom: 70,
              child: AnimatedBuilder(
                  animation: _animationController.view,
                  builder: (context, child) {
                    return Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      color: _colorTweenAnimation.value,
                      child: child,
                    );
                  },
                  child: const Center(
                    child: Text(
                      'SHOP NOW',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  )))
        ],
      ),
    );
  }
}
