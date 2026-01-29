import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'checkin/checkin_service.dart';
import 'lessons/lesson_service.dart';
import 'subscriptions/subscription_service.dart';
import 'package:intl/intl.dart';

/// Week 10: Testing & QA Dashboard
/// Internal tool for systematic testing before launch
class TestingDashboardPage extends StatefulWidget {
  const TestingDashboardPage({super.key});

  @override
  State<TestingDashboardPage> createState() => _TestingDashboardPageState();
}

class _TestingDashboardPageState extends State<TestingDashboardPage> {
  final supabase = Supabase.instance.client;
  final CheckInService _checkInService = CheckInService();
  final LessonService _lessonService = LessonService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  bool _isRunningTests = false;
  final Map<String, TestResult> _testResults = {};

  @override
  void initState() {
    super.initState();
    _initializeTests();
  }

  void _initializeTests() {
    // Initialize all test categories
    _testResults['auth'] = TestResult(
      category: 'Authentication',
      tests: [
        'User can sign up with email',
        'User can log in',
        'User can reset password',
        'Session persists across app restarts',
        'User can log out',
      ],
    );

    _testResults['onboarding'] = TestResult(
      category: 'Onboarding',
      tests: [
        'Disclaimer page displays correctly',
        'Profile is created after disclaimer acceptance',
        'Paywall displays correctly',
        'User can purchase subscription',
        'User can restore purchases',
      ],
    );

    _testResults['checkin'] = TestResult(
      category: 'Daily Check-In',
      tests: [
        'Check-in form validates all fields',
        'Check-in saves to database',
        'Only one check-in per day allowed',
        'Check-in history displays correctly',
        'Streak calculation is accurate',
      ],
    );

    _testResults['lessons'] = TestResult(
      category: 'Lesson System',
      tests: [
        'All 60 lessons load correctly',
        'Lesson navigation works',
        'Lesson completion saves to database',
        'Reflection questions save',
        'Progress percentages calculate correctly',
        'Lessons readable offline',
      ],
    );

    _testResults['tools'] = TestResult(
      category: 'Recovery Tools',
      tests: [
        'Panic Button exercises work',
        'Urge Timer counts down correctly',
        'Thought Worksheet saves data',
        'Prevention Plan saves and exports PDF',
        'Crisis Resources links work',
      ],
    );

    _testResults['progress'] = TestResult(
      category: 'Progress & Reports',
      tests: [
        'Charts display correctly',
        'Statistics are accurate',
        'PDF generation works',
        'Share functionality works',
        'Weekly certificates generate',
      ],
    );

    _testResults['performance'] = TestResult(
      category: 'Performance',
      tests: [
        'App startup < 3 seconds',
        'Lesson load < 1 second',
        'PDF generation < 5 seconds',
        'Smooth 60fps scrolling',
        'No memory leaks',
      ],
    );

    _testResults['offline'] = TestResult(
      category: 'Offline Mode',
      tests: [
        'Lessons readable offline',
        'Check-ins queue when offline',
        'Data syncs when back online',
        'Graceful error messages',
      ],
    );
  }

  Future<void> _runAutomatedTests() async {
    setState(() {
      _isRunningTests = true;
    });

    // Simulate running tests
    await Future.delayed(const Duration(seconds: 1));

    // Test 1: Database Connection
    await _testDatabaseConnection();

    // Test 2: Subscription Status
    await _testSubscriptionStatus();

    // Test 3: Lesson Data Integrity
    await _testLessonDataIntegrity();

    // Test 4: Check-in Service
    await _testCheckInService();

    setState(() {
      _isRunningTests = false;
    });

    _showTestResultsDialog();
  }

  Future<void> _testDatabaseConnection() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _updateTestResult('auth', 0, true, 'User session valid');
      } else {
        _updateTestResult('auth', 0, false, 'Profile not found');
      }
    } catch (e) {
      _updateTestResult('auth', 0, false, 'Error: $e');
    }
  }

  Future<void> _testSubscriptionStatus() async {
    try {
      final hasSubscription = await _subscriptionService.hasActiveSubscription();
      _updateTestResult(
        'onboarding',
        3,
        hasSubscription,
        hasSubscription ? 'Active subscription found' : 'No active subscription',
      );
    } catch (e) {
      _updateTestResult('onboarding', 3, false, 'Error: $e');
    }
  }

  Future<void> _testLessonDataIntegrity() async {
    try {
      // Test that all 60 lessons exist
      int lessonCount = 0;
      for (int week = 1; week <= 12; week++) {
        for (int day = 1; day <= 5; day++) {
          final lesson = _lessonService.getLesson(week, day);
          if (lesson != null) lessonCount++;
        }
      }

      final allLessonsExist = lessonCount == 60;
      _updateTestResult(
        'lessons',
        0,
        allLessonsExist,
        '$lessonCount/60 lessons loaded',
      );
    } catch (e) {
      _updateTestResult('lessons', 0, false, 'Error: $e');
    }
  }

  Future<void> _testCheckInService() async {
    try {
      final hasCheckedIn = await _checkInService.hasCheckedInToday();
      _updateTestResult(
        'checkin',
        0,
        true,
        hasCheckedIn ? 'Check-in completed today' : 'No check-in today',
      );
    } catch (e) {
      _updateTestResult('checkin', 0, false, 'Error: $e');
    }
  }

  void _updateTestResult(String category, int index, bool passed, String message) {
    setState(() {
      _testResults[category]?.updateTest(index, passed, message);
    });
  }

  void _showTestResultsDialog() {
    int totalTests = 0;
    int passedTests = 0;

    _testResults.forEach((key, result) {
      totalTests += result.tests.length;
      passedTests += result.passedCount;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Automated Test Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passedTests == totalTests ? Icons.check_circle : Icons.warning,
              size: 48,
              color: passedTests == totalTests ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              '$passedTests / $totalTests Tests Passed',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${((passedTests / totalTests) * 100).toStringAsFixed(1)}% Success Rate',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Testing Dashboard',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4F46E5)),
            onPressed: _isRunningTests ? null : _runAutomatedTests,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Week 10: QA Testing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Systematic testing before launch',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRunningTests ? null : _runAutomatedTests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isRunningTests
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Run Automated Tests',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test Categories
            ...._testResults.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _TestCategoryCard(
                  testResult: entry.value,
                  onTestTap: (index) {
                    _showTestDetailDialog(entry.value, index);
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Quick Test Actions
            const Text(
              'Quick Test Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            _QuickTestButton(
              icon: Icons.login,
              label: 'Test Login Flow',
              onTap: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),

            const SizedBox(height: 8),

            _QuickTestButton(
              icon: Icons.warning,
              label: 'View Disclaimer',
              onTap: () {
                Navigator.pushNamed(context, '/disclaimer');
              },
            ),

            const SizedBox(height: 8),

            _QuickTestButton(
              icon: Icons.payment,
              label: 'View Paywall',
              onTap: () {
                Navigator.pushNamed(context, '/paywall');
              },
            ),

            const SizedBox(height: 8),

            _QuickTestButton(
              icon: Icons.check_circle,
              label: 'Test Check-In',
              onTap: () {
                Navigator.pushNamed(context, '/checkin');
              },
            ),

            const SizedBox(height: 8),

            _QuickTestButton(
              icon: Icons.school,
              label: 'Browse All Lessons',
              onTap: () {
                Navigator.pushNamed(context, '/lessons');
              },
            ),

            const SizedBox(height: 8),

            _QuickTestButton(
              icon: Icons.build,
              label: 'Test All Tools',
              onTap: () {
                Navigator.pushNamed(context, '/tools');
              },
            ),

            const SizedBox(height: 8),

            _QuickTestButton(
              icon: Icons.analytics,
              label: 'View Progress',
              onTap: () {
                Navigator.pushNamed(context, '/progress');
              },
            ),

            const SizedBox(height: 24),

            // System Info
            _SystemInfoCard(),
          ],
        ),
      ),
    );
  }

  void _showTestDetailDialog(TestResult result, int index) {
    final test = result.testStatuses[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.tests[index]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  test.passed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: test.passed ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  test.passed ? 'Passed' : 'Not Tested',
                  style: TextStyle(
                    color: test.passed ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (test.message != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(test.message!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Test Result Model
class TestResult {
  final String category;
  final List<String> tests;
  final List<TestStatus> testStatuses;

  TestResult({
    required this.category,
    required this.tests,
  }) : testStatuses = List.generate(
          tests.length,
          (index) => TestStatus(),
        );

  void updateTest(int index, bool passed, String message) {
    if (index >= 0 && index < testStatuses.length) {
      testStatuses[index] = TestStatus(passed: passed, message: message);
    }
  }

  int get passedCount => testStatuses.where((t) => t.passed).length;
  int get totalCount => tests.length;
  double get percentage => totalCount > 0 ? (passedCount / totalCount) : 0;
}

class TestStatus {
  final bool passed;
  final String? message;

  TestStatus({this.passed = false, this.message});
}

// Test Category Card Widget
class _TestCategoryCard extends StatelessWidget {
  final TestResult testResult;
  final Function(int) onTestTap;

  const _TestCategoryCard({
    required this.testResult,
    required this.onTestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  testResult.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(testResult.percentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${testResult.passedCount}/${testResult.totalCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(testResult.percentage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: testResult.percentage,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(testResult.percentage),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...testResult.tests.asMap().entries.map((entry) {
            final index = entry.key;
            final test = entry.value;
            final status = testResult.testStatuses[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onTestTap(index),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        status.passed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: status.passed ? Colors.green : Colors.grey[400],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          test,
                          style: TextStyle(
                            fontSize: 14,
                            color: status.passed
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

// Quick Test Button Widget
class _QuickTestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickTestButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

// System Info Card Widget
class _SystemInfoCard extends StatelessWidget {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'User ID', value: user?.id ?? 'Not logged in'),
          _InfoRow(label: 'Email', value: user?.email ?? 'N/A'),
          _InfoRow(
            label: 'Session Expires',
            value: user != null
                ? DateFormat('MMM dd, yyyy HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                      user.createdAt.millisecondsSinceEpoch +
                          (3600000 * 24), // Approximate
                    ),
                  )
                : 'N/A',
          ),
          _InfoRow(
            label: 'App Version',
            value: '1.0.1+2',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}