// lib/subscriptions/paywall_page.dart
//
// Apple Guideline compliance:
//   3.1.2(c) — Clickable Privacy Policy and Terms of Use links are shown
//              in the bottom section, and subscription title/duration/price
//              are all visible before purchase.
//   2.3.2    — Subscription requirement is stated clearly in the subtitle
//              and in the auto-renew disclosure beneath the CTA button.
//   2.1(b)   — Resolved in App Store Connect by submitting IAP products
//              alongside the binary (no code change required).

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'subscription_service.dart';

// ── Replace these with your real URLs ────────────────────────────────────────
const String _kPrivacyPolicyUrl =
    'https://www.clearpathrecovery.com/privacy-policy';
const String _kTermsOfServiceUrl =
    'https://www.clearpathrecovery.com/terms-of-service';
// ─────────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // Data loading
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

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
        // Dev mode or no offerings — render static UI silently.
        setState(() {
          _offerings = null;
          _selectedPackage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️  Error loading offerings: $e');
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
      _showError('Could not restore purchases. Please try again.');
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError('Could not open link. Please visit $url');
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

                          const SizedBox(height: 12),

                          // ── Guideline 2.3.2 ──────────────────────────────
                          // Clearly state that a paid subscription is required
                          // before users can access the app content.
                          const Text(
                            'A subscription is required to access ClearPath Recovery. '
                            'All features listed below are included in the subscription.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          // ─────────────────────────────────────────────────

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

                          // Subscription card
                          _buildSubscriptionCard(),

                          const SizedBox(height: 24),

                          // ── Guideline 3.1.2(c) — Auto-renew disclosure ──
                          // Must appear BEFORE the purchase button (i.e. in
                          // the scrollable body, not just the footer).
                          _buildAutoRenewDisclosure(),
                          // ─────────────────────────────────────────────────
                        ],
                      ),
                    ),
                  ),

                  // Sticky bottom CTA + legal links
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
                  // ── Guideline 3.1.2(c) ───────────────────────────────────
                  // Title of the auto-renewing subscription must be visible.
                  const Text(
                    'ClearPath Monthly',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Length of subscription must be visible.
                  const Text(
                    '1-month subscription',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  // ─────────────────────────────────────────────────────────
                  const SizedBox(height: 8),
                  // Price must be visible.
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
                  '✓ First charge after 7-day free trial',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Auto-renew disclosure required by Guideline 3.1.2(c).
  /// Must include: subscription name, billing period, price, and cancellation
  /// info. Displayed in the scrollable body so it is seen before purchase.
  Widget _buildAutoRenewDisclosure() {
    final priceString =
        _selectedPackage?.storeProduct.priceString ?? '\$9.99';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        'ClearPath Monthly auto-renews at $priceString/month after the '
        '7-day free trial. Your subscription will automatically renew '
        'unless cancelled at least 24 hours before the end of the current '
        'period. You can manage or cancel your subscription in your '
        'App Store account settings at any time.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
        mainAxisSize: MainAxisSize.min,
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

          const SizedBox(height: 12),

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

          // ── Guideline 3.1.2(c) — Functional links to Privacy Policy and
          // Terms of Use (EULA). These must be tappable, not plain text.
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              children: [
                const TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchUrl(_kTermsOfServiceUrl),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launchUrl(_kPrivacyPolicyUrl),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          // ─────────────────────────────────────────────────────────────────
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