import 'package:flutter/material.dart';

// Import all pages
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'onboarding/disclaimer_page.dart';
import 'home_page.dart';
import 'checkin/daily_checkin_page.dart';
import 'lessons/lesson_list_page.dart';
import 'lessons/lesson_detail_page.dart';
import 'progress/progress_page.dart';
import 'tools/tools_page.dart';
import 'tools/panic_button_page.dart';
import 'tools/urge_timer_page.dart';
import 'tools/crisis_resources_page.dart';
import 'settings/settings_page.dart';

void main() {
  runApp(const ClearPathRecoveryApp());
}

class ClearPathRecoveryApp extends StatelessWidget {
  const ClearPathRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearPath Recovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
        ),
        useMaterial3: true,
      ),
      // Start with disclaimer for now
      // TODO: Add auth check to route to login or home
      initialRoute: '/disclaimer',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/disclaimer': (context) => const DisclaimerPage(),
        '/home': (context) => const MainNavigationPage(),
        '/checkin': (context) => const DailyCheckInPage(),
        '/lessons': (context) => const LessonListPage(),
        '/progress': (context) => const ProgressPage(),
        '/tools': (context) => const ToolsPage(),
        '/tools/panic-button': (context) => const PanicButtonPage(),
        '/tools/urge-timer': (context) => const UrgeTimerPage(),
        '/crisis-resources': (context) => const CrisisResourcesPage(),
        '/settings': (context) => const SettingsPage(),
      },
      onGenerateRoute: (settings) {
        // Handle lesson detail with parameters
        if (settings.name?.startsWith('/lesson/') ?? false) {
          final parts = settings.name!.split('/');
          if (parts.length == 4) {
            final week = int.tryParse(parts[2]);
            final day = int.tryParse(parts[3]);
            if (week != null && day != null) {
              return MaterialPageRoute(
                builder: (context) => LessonDetailPage(week: week, day: day),
              );
            }
          }
        }
        return null;
      },
    );
  }
}

/// Main navigation wrapper with bottom nav bar
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const LessonListPage(),
    const ToolsPage(),
    const ProgressPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}