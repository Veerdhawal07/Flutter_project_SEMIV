import 'package:flutter/material.dart';

import '../common/notice_board_screen.dart';
import '../common/profile_screen.dart';
import 'officer_dashboard.dart';

class OfficerMainScreen extends StatefulWidget {
  const OfficerMainScreen({super.key});

  @override
  State<OfficerMainScreen> createState() => _OfficerMainScreenState();
}

class _OfficerMainScreenState extends State<OfficerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OfficerDashboard(),
    const NoticeBoardScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Notices',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
