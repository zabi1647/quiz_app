import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/pages/web/dashboard/widgets/dashboard_overview.dart';
import 'package:quiz_app/pages/web/dashboard/widgets/mcq_management.dart';
import 'package:quiz_app/pages/web/dashboard/widgets/user_performance.dart';
import 'package:quiz_app/pages/web/dashboard/widgets/statistics_view.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  final List<String> _titles = [
    'Dashboard Overview',
    'MCQ Management',
    'User Performance',
    'Statistics',
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
    final isMediumScreen =
        MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isSmallScreen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.purple.shade600),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Admin',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: isSmallScreen ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!isSmallScreen) _buildSidebar(isMediumScreen),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isMediumScreen) {
    return Container(
      width: isMediumScreen ? 80 : 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.purple.shade600],
        ),
      ),
      child: ListView(
        children: [
          SizedBox(height: isMediumScreen ? 20 : 30),
          if (!isMediumScreen)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          _buildNavItem(
            icon: Icons.dashboard,
            title: 'Overview',
            index: 0,
            isCompact: isMediumScreen,
          ),
          _buildNavItem(
            icon: Icons.quiz,
            title: 'MCQs',
            index: 1,
            isCompact: isMediumScreen,
          ),
          _buildNavItem(
            icon: Icons.people,
            title: 'Users',
            index: 2,
            isCompact: isMediumScreen,
          ),
          _buildNavItem(
            icon: Icons.bar_chart,
            title: 'Statistics',
            index: 3,
            isCompact: isMediumScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.purple.shade600],
          ),
        ),
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.purple.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.displayName ?? 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildNavItem(icon: Icons.dashboard, title: 'Overview', index: 0),
            _buildNavItem(icon: Icons.quiz, title: 'MCQs', index: 1),
            _buildNavItem(icon: Icons.people, title: 'Users', index: 2),
            _buildNavItem(icon: Icons.bar_chart, title: 'Statistics', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
    bool isCompact = false,
  }) {
    final isSelected = _selectedIndex == index;

    if (isCompact) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Tooltip(
          message: title,
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: () {
              setState(() => _selectedIndex = index);
              if (MediaQuery.of(context).size.width < 800) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onTap: () {
          setState(() => _selectedIndex = index);
          if (MediaQuery.of(context).size.width < 800) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardOverview();
      case 1:
        return const MCQManagement();
      case 2:
        return const UserPerformance();
      case 3:
        return const StatisticsView();
      default:
        return const DashboardOverview();
    }
  }
}
