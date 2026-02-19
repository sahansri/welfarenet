import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/login.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class GetStart extends StatefulWidget {
  const GetStart({super.key});

  @override
  State<GetStart> createState() => _GetStartState();
}

class _GetStartState extends State<GetStart> {
  @override
  Widget build(BuildContext context) {
    // Responsive measurements
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double imgWidth = math.min(200, screenWidth * 0.5);
    final double titleFont = math.max(20, screenWidth * 0.06);
    final double subtitleFont = math.max(14, screenWidth * 0.04);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5), Color(0xFF5D45BC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: math.max(24, screenHeight * 0.04)),
                  Image.asset(
                    'lib/assets/IMG_2315.PNG',
                    width: imgWidth,
                    height: imgWidth,
                  ),
                  SizedBox(height: math.max(8, screenHeight * 0.01)),
                  Image.asset(
                    'lib/assets/hand-drawn-diversity-concept-background.png',
                    width: math.min(screenWidth * 0.9, 360),
                  ),
                  SizedBox(height: math.max(10, screenHeight * 0.015)),
                  Text(
                    'WelfareNet',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: math.max(6, screenHeight * 0.01)),
                  Text(
                    'Community Management System',
                    style: TextStyle(
                      fontSize: subtitleFont,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Pathum Uyana Walfare Society',
                    style: TextStyle(
                      fontSize: subtitleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Kundasale.',
                    style: TextStyle(
                      fontSize: subtitleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: math.max(20, screenHeight * 0.03)),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const LoginSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 15.0,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Get Started'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
