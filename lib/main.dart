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
import 'dart:io' show Platform;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint('=== ClearPath Recovery Initialization Started ===');
    
    // Step 1: Load environment variables
    debugPrint('Step 1: Loading .env file...');
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('✓ .env file loaded successfully');
    } catch (e) {
      debugPrint('✗ Failed to load .env file: $e');
      debugPrint('Will attempt to use hardcoded fallback values');
    }
    
    // Step 2: Get Supabase credentials (with fallback)
    debugPrint('Step 2: Getting Supabase credentials...');
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://viuhhlcudemiadwkfedi.supabase.co';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZpdWhobGN1ZGVtaWFkd2tmZWRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxMTk4MzAsImV4cCI6MjA4NDY5NTgzMH0.2uGA0hdmo04gX6ZUhLwMf-xzwGUX2E05DQ09K1QzZzg';
    
    debugPrint('Supabase URL: $supabaseUrl');
    debugPrint('Supabase Key length: ${supabaseAnonKey.length} characters');
    
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is empty');
    }
    
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is empty');
    }
    
    // Step 3: Initialize Supabase
    debugPrint('Step 3: Initializing Supabase...');
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      debugPrint('✓ Supabase initialized successfully');
    } catch (e) {
      debugPrint('✗ Supabase initialization failed: $e');
      throw Exception('Supabase initialization failed: $e');
    }

    // Step 4: Initialize RevenueCat (PLATFORM-SPECIFIC, NON-BLOCKING)
    debugPrint('Step 4: RevenueCat initialization (platform-specific, async)');
    
    // Determine which API key to use based on platform
    String? revenueCatKey;
    
    if (kIsWeb) {
      // Web platform - skip RevenueCat entirely (not supported on web)
      debugPrint('Web platform detected - RevenueCat not supported, skipping');
    } else if (Platform.isAndroid) {
      // Android - use Google Play key
      revenueCatKey = dotenv.env['REVENUECAT_GOOGLE_API_KEY'];
      debugPrint('Android platform detected - using Google Play API key');
    } else if (Platform.isIOS) {
      // iOS - use App Store key
      revenueCatKey = dotenv.env['REVENUECAT_APPLE_API_KEY'] ?? 
                      dotenv.env['REVENUECAT_API_KEY']; // fallback to old key
      debugPrint('iOS platform detected - using App Store API key');
    }
    
    if (revenueCatKey != null && revenueCatKey.isNotEmpty) {
      debugPrint('RevenueCat key found (${revenueCatKey.length} chars), initializing in background...');
      // Initialize in background without blocking app startup
      SubscriptionService().initialize(apiKey: revenueCatKey).then((_) {
        debugPrint('✓ RevenueCat initialized successfully');
      }).catchError((e) {
        debugPrint('✗ RevenueCat initialization failed: $e');
        debugPrint('App will continue without in-app purchases');
      });
    } else {
      debugPrint('No RevenueCat API key found for this platform, skipping');
    }

    debugPrint('=== Initialization Complete - Starting App ===');
    runApp(const ClearPathApp());
    
  } catch (e, stackTrace) {
    // Detailed error logging
    debugPrint('=== FATAL INITIALIZATION ERROR ===');
    debugPrint('Error: $e');
    debugPrint('Stack trace: $stackTrace');
    debugPrint('===================================');
    
    // Show error screen to user
    runApp(MaterialApp(
      home: ErrorScreen(
        error: e.toString(),
        stackTrace: stackTrace.toString(),
      ),
    ));
  }
}

// Detailed error screen for debugging
class ErrorScreen extends StatelessWidget {
  final String error;
  final String stackTrace;
  
  const ErrorScreen({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 20),
              const Text(
                'App Initialization Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error Details:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  error,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Common Solutions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildSolution('1. Check your internet connection'),
              _buildSolution('2. Verify Supabase credentials are correct'),
              _buildSolution('3. Clear app cache and try again'),
              _buildSolution('4. Reinstall the app'),
              const SizedBox(height: 20),
              if (kDebugMode) ...[
                ExpansionTile(
                  title: const Text(
                    'Stack Trace (Debug Only)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        stackTrace,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Close App',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSolution(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
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
  String? _errorMessage;

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
      debugPrint('Checking user profile for disclaimer...');
      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      final hasDisclaimer = response != null;
      debugPrint('Has disclaimer: $hasDisclaimer');

      // Check subscription status with timeout and error handling
      debugPrint('Checking subscription status...');
      bool hasSubscription = false;
      
      try {
        // Add timeout to prevent hanging
        hasSubscription = await SubscriptionService()
            .hasActiveSubscription()
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint('⚠️ Subscription check timed out, assuming no subscription');
                return false;
              },
            );
        debugPrint('Has active subscription: $hasSubscription');
      } catch (e) {
        debugPrint('⚠️ Error checking subscription: $e');
        // Continue with hasSubscription = false
        hasSubscription = false;
      }

      setState(() {
        _hasAcceptedDisclaimer = hasDisclaimer;
        _hasActiveSubscription = hasSubscription;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking onboarding status: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading your profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error if something went wrong
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error Loading Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _checkOnboardingStatus();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
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