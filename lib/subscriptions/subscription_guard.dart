//lib/subscriptions/subscription_guard.dart

import 'package:flutter/material.dart';
import 'subscription_service.dart';

/// Widget that checks subscription status and shows paywall if needed
class SubscriptionGuard extends StatefulWidget {
  final Widget child;
  final bool showGracePeriodWarning;

  const SubscriptionGuard({
    super.key,
    required this.child,
    this.showGracePeriodWarning = true,
  });

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = true;
  bool _hasActiveSubscription = false;
  bool _isInGracePeriod = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    try {
      final hasActive = await _subscriptionService.hasActiveSubscription();
      final inGrace = await _subscriptionService.isInGracePeriod();

      setState(() {
        _hasActiveSubscription = hasActive;
        _isInGracePeriod = inGrace;
        _isLoading = false;
      });

      // If no active subscription, redirect to paywall
      if (!hasActive && mounted) {
        Navigator.of(context).pushReplacementNamed('/paywall');
      }
    } catch (e) {
      print('Error checking subscription: $e');
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

    if (!_hasActiveSubscription) {
      // Will redirect in initState
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        // Grace period warning banner
        if (widget.showGracePeriodWarning && _isInGracePeriod)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFFEF2F2),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment issue detected. Update your payment method to continue access.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red[900],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}