// Input: Current user data
// Output: Main screen with bottom navigation to switch between app sections

import 'package:flutter/material.dart';
import '../components/app_bottom_nav.dart';
import '../constants/theme_constants.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'stocks_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'developer_options_screen.dart';

class MainScreen extends StatefulWidget {
  final User? currentUser;

  const MainScreen({
    Key? key,
    this.currentUser,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int _logoTapCount = 0;
  DateTime? _lastTapTime;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const StocksScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _checkForDeveloperMode(BuildContext context) {
    // Check if we should reset the counter (more than 2 seconds since last tap)
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 2) {
      _logoTapCount = 0;
    }
    _lastTapTime = now;

    // Increment counter
    _logoTapCount++;

    // Open developer options after 5 rapid taps
    if (_logoTapCount >= 5) {
      _logoTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DeveloperOptionsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackgroundColor,
        title: GestureDetector(
          onTap: () => _checkForDeveloperMode(context),
          child: const Text(
            'SimpleHot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Open notifications
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
