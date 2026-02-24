// lib/subscriptions/paywall_page.dart

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'subscription_service.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();

  Offerings? _offerings;
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Data loading
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);

    try {
      final offerings = await _subscriptionService.getOfferings();

      if (offerings != null && offerings.current != null) {
        final currentOffering = offerings.current!;
        final monthly = currentOffering.monthly ??
            (currentOffering.availablePackages.isNotEmpty
                ? currentOffering.availablePackages.first
                : null);

        setState(() {
          _offerings = offerings;
          _selectedPackage = monthly;
          _isLoading = false;
        });
      } else {
        // Dev mode or no offerings configured — show static UI silently.
        // No error shown to the user; the paywall still renders normally
        // with the static price placeholder.
        setState(() {
          _offerings = null;
          _selectedPackage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️  Error loading offerings: $e');
      // Don't show a red banner here either — just render the static UI.
      setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _purchasePackage() async {
    setState(() => _isPurchasing = true);

    try {
      if (_selectedPackage != null) {
        await _subscriptionService.purchasePackage(_selectedPackage!);
      } else {
        // Dev mode — no real package; log and fall through to navigation.
        debugPrint('⚠️  No package selected — dev mode, navigating to /home');
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on PurchasesErrorCode catch (e) {
      if (e != PurchasesErrorCode.purchaseCancelledError) {
        _showError('Purchase could not be completed. Please try again.');
      }
    } catch (e) {
      _showError('Purchase could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isRestoring = true);

    try {
      final info = await _subscriptionService.restorePurchases();

      // info is null in dev mode AND when no prior purchases exist — both
      // correctly surface the neutral grey "No active subscriptions found".
      if (info != null && info.entitlements.active.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        _showInfo('No active subscriptions found.');
      }
    } catch (e) {
      // SubscriptionService never throws in dev mode, so this is only
      // reached on unexpected production errors.
      _showError('Could not restore purchases. Please try again.');
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Snackbar helpers
  // ─────────────────────────────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Neutral grey snackbar — used for non-alarming informational messages
  /// like "No active subscriptions found" on restore.
  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B7280),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Logo
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  'CP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Title
                          const Text(
                            'Start Your Recovery Journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subtitle
                          const Text(
                            'Access evidence-based recovery tools and daily support',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Feature list
                          _buildFeature(
                            icon: Icons.school_outlined,
                            title: '12-Week Recovery Program',
                            subtitle: '60 structured lessons based on CBT and MI',
                          ),
                          const SizedBox(height: 20),
                          _buildFeature(
                            icon: Icons.edit_note,
                            title: 'Daily Check-Ins',
                            subtitle: 'Track mood, cravings, and progress',
                          ),
                          const SizedBox(height: 20),
                          _buildFeature(
                            icon: Icons.emergency,
                            title: 'Crisis Support Tools',
                            subtitle: 'Panic button, urge timer, and more',
                          ),
                          const SizedBox(height: 20),
                          _buildFeature(
                            icon: Icons.assessment_outlined,
                            title: 'Court-Compliant Reports',
                            subtitle:
                                'Generate progress reports with timestamps',
                          ),

                          const SizedBox(height: 40),

                          // Subscription card — live price when available,
                          // static $9.99 placeholder in dev mode.
                          _buildSubscriptionCard(),
                        ],
                      ),
                    ),
                  ),

                  // Sticky bottom CTA
                  _buildBottomSection(),
                ],
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Widget builders
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSubscriptionCard() {
    final priceString =
        _selectedPackage?.storeProduct.priceString ?? '\$9.99';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Subscription',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceString,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'per month',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '7-Day Free Trial',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✓ Full access to all features',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  '✓ Cancel anytime, no commitment',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  '✓ First charge after 7 days',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start Trial button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPurchasing ? null : _purchasePackage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Start 7-Day Free Trial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Restore purchases
          TextButton(
            onPressed: _isRestoring ? null : _restorePurchases,
            child: _isRestoring
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Restore Purchases',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),

          const SizedBox(height: 8),

          // Terms
          Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}