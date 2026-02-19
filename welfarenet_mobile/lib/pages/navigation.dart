import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:welfarenet_mobile/pages/dashboard.dart';
import 'package:welfarenet_mobile/pages/events/events.dart';
import 'package:welfarenet_mobile/pages/more.dart';
import 'package:welfarenet_mobile/pages/news_feed.dart';
import 'package:welfarenet_mobile/pages/payments/payment.dart';
import 'package:welfarenet_mobile/pages/no_internet.dart';
import 'package:welfarenet_mobile/services/connectivity_service.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final PageController _pageController = PageController();
  final ConnectivityService _connectivityService = ConnectivityService();
  int _selectedIndex = 0;
  final int? index = 0;
  bool _isConnected = true;

  final List<Widget> _pages = [
    Dashboard(),
    NewsFeed(),
    Events(),
    Payment(),
    More(),
  ];

  @override
  void initState() {
    super.initState();
    _connectivityService.startMonitoring();

    _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });

        // Show connectivity status
        if (isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.wifi, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Connected to internet')),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.stopMonitoring();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Responsive sizes
    final double navHeight = (screenHeight * 0.07).clamp(56.0, 80.0);
    // iconSize scales with navHeight but capped for consistency
    final double iconSize = math.min(28.0, navHeight * 0.6);
    // final double iconSize = 5.0;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),

          // No internet banner overlay
          if (!_isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: NoInternetBanner(
                onRetry: () async {
                  final isConnected =
                      await _connectivityService.checkConnectivity();
                  if (mounted) {
                    setState(() {
                      _isConnected = isConnected;
                    });
                  }
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, Icons.home, 0, 'Home'),
                _buildNavItem(Icons.article_outlined, Icons.article, 1, 'News'),
                _buildNavItem(Icons.event_outlined, Icons.event, 2, 'Events'),
                _buildNavItem(Icons.payment_outlined, Icons.payment, 3, 'Pay'),
                _buildNavItem(Icons.menu, Icons.menu, 4, 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    int index,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavigationTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                    )
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 22,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
