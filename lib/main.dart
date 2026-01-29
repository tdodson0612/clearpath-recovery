import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'onboarding/disclaimer_page.dart';
import 'subscriptions/paywall_page.dart';
import 'subscriptions/subscription_service.dart';
import 'home_page.dart';
import 'checkin/daily_checkin_page.dart';
import 'lessons/lesson_list_page.dart';
import 'lessons/lesson_detail_page.dart';
import 'progress/progress_page.dart';
import 'tools/tools_page.dart';
import 'tools/panic_button_page.dart';
import 'tools/urge_timer_page.dart';
import 'tools/thought_challenge_page.dart';
import 'tools/prevention_plan_page.dart';
import 'tools/crisis_resources_page.dart';
import 'settings/settings_page.dart';
import 'testing_dashboard_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize RevenueCat
  // Add your RevenueCat API keys to .env file:
  // REVENUECAT_API_KEY_IOS=your_ios_key
  // REVENUECAT_API_KEY_ANDROID=your_android_key
  final revenueCatKey = dotenv.env['REVENUECAT_API_KEY'] ?? '';
  if (revenueCatKey.isNotEmpty) {
    try {
      await SubscriptionService().initialize(apiKey: revenueCatKey);
    } catch (e) {
      print('Failed to initialize RevenueCat: $e');
    }
  }

  runApp(const ClearPathApp());
}

// Global Supabase client accessor
final supabase = Supabase.instance.client;

class ClearPathApp extends StatelessWidget {
  const ClearPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearPath Recovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle lesson detail route with parameters
        if (settings.name != null && settings.name!.startsWith('/lesson/')) {
          final parts = settings.name!.split('/');
          if (parts.length == 4) {
            final week = int.tryParse(parts[2]);
            final day = int.tryParse(parts[3]);
            if (week != null && day != null) {
              return MaterialPageRoute(
                builder: (context) => LessonDetailPage(
                  week: week,
                  day: day,
                ),
              );
            }
          }
        }

        // Default routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const AuthWrapper());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => const SignupPage());
          case '/disclaimer':
            return MaterialPageRoute(builder: (context) => const DisclaimerPage());
          case '/paywall':
            return MaterialPageRoute(builder: (context) => const PaywallPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomePage());
          case '/checkin':
            return MaterialPageRoute(builder: (context) => const DailyCheckInPage());
          case '/lessons':
            return MaterialPageRoute(builder: (context) => const LessonListPage());
          case '/progress':
            return MaterialPageRoute(builder: (context) => const ProgressPage());
          case '/tools':
            return MaterialPageRoute(builder: (context) => const ToolsPage());
          case '/tools/panic-button':
            return MaterialPageRoute(builder: (context) => const PanicButtonPage());
          case '/tools/urge-timer':
            return MaterialPageRoute(builder: (context) => const UrgeTimerPage());
          case '/tools/thought-challenge':
            return MaterialPageRoute(builder: (context) => const ThoughtChallengePage());
          case '/tools/prevention-plan':
            return MaterialPageRoute(builder: (context) => const PreventionPlanPage());
          case '/crisis-resources':
            return MaterialPageRoute(builder: (context) => const CrisisResourcesPage());
          case '/settings':
            return MaterialPageRoute(builder: (context) => const SettingsPage());
          case '/testing-dashboard':
            return MaterialPageRoute(builder: (context) => const TestingDashboardPage());
          default:
            return null;
        }
      },
    );
  }
}

// Wrapper to check auth state on app start
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // User is logged in - check disclaimer and subscription
          return const OnboardingCheckWrapper();
        } else {
          // User is not logged in
          return const LoginPage();
        }
      },
    );
  }
}

// Check disclaimer and subscription status
class OnboardingCheckWrapper extends StatefulWidget {
  const OnboardingCheckWrapper({super.key});

  @override
  State<OnboardingCheckWrapper> createState() => _OnboardingCheckWrapperState();
}

class _OnboardingCheckWrapperState extends State<OnboardingCheckWrapper> {
  bool _isLoading = true;
  bool _hasAcceptedDisclaimer = false;
  bool _hasActiveSubscription = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Check if user has accepted disclaimer (has profile)
      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      final hasDisclaimer = response != null;

      // Check subscription status
      final subscriptionService = SubscriptionService();
      final hasSubscription = await subscriptionService.hasActiveSubscription();

      setState(() {
        _hasAcceptedDisclaimer = hasDisclaimer;
        _hasActiveSubscription = hasSubscription;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking onboarding status: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Flow: Disclaimer → Paywall → Home
    if (!_hasAcceptedDisclaimer) {
      return const DisclaimerPage();
    }

    if (!_hasActiveSubscription) {
      return const PaywallPage();
    }

    return const HomePage();
  }
}