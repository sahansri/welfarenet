import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/navigation.dart';
import 'package:welfarenet_mobile/services/auth_service.dart';
import 'package:welfarenet_mobile/pages/get_start.dart';
import 'package:welfarenet_mobile/utils/responsive_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, go to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Navigation()),
      );
    } else {
      // User is not logged in, go to get started page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GetStart()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textStyles = context.textStyles;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A5AF8), Color(0xFF9B5DE5), Color(0xFF5D45BC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // You can add your logo here
              Image.asset(
                'lib/assets/IMG_2315.PNG',
                width: responsive.iconSize(150),
                height: responsive.iconSize(150),
              ),
              SizedBox(height: responsive.spacing(20)),
              Text(
                'WelfareNet',
                style: textStyles.headline1.copyWith(color: Colors.white),
              ),
              SizedBox(height: responsive.spacing(30)),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
