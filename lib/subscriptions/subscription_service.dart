// lib/subscriptions/subscription_service.dart

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing subscriptions with RevenueCat.
///
/// Dev mode behaviour (when a `test_` API key is detected):
///   - RevenueCat is NOT initialised → [_isConfigured] stays false.
///   - [hasActiveSubscription] returns false  → paywall is shown.
///   - [purchasePackage]       returns null   → caller navigates to /home silently.
///   - [restorePurchases]      returns null   → caller shows "No active subscriptions found".
///   - No exceptions are thrown in dev mode; the UI never shows a crash banner.
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isConfigured = false;
  CustomerInfo? _customerInfo;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialisation
  // ─────────────────────────────────────────────────────────────────────────

  /// Initialise RevenueCat. Safe to call multiple times; subsequent calls are
  /// no-ops once configured.
  Future<void> initialize({
    required String apiKey,
    String? appUserId,
  }) async {
    if (_isConfigured) return;

    // Detect test key — skip init entirely, stay unconfigured.
    if (apiKey.startsWith('test_')) {
      debugPrint('⚠️  Test API key detected — RevenueCat skipped (dev mode)');
      debugPrint('    Paywall will be shown; purchases/restores will be no-ops.');
      return;
    }

    try {
      final configuration = PurchasesConfiguration(apiKey);
      if (appUserId != null) {
        configuration.appUserID = appUserId;
      }

      await Purchases.configure(configuration);
      _isConfigured = true;

      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      await refreshCustomerInfo();
      debugPrint('✓ RevenueCat configured successfully');
    } catch (e) {
      debugPrint('⚠️  RevenueCat initialisation failed: $e');
      _isConfigured = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Customer info
  // ─────────────────────────────────────────────────────────────────────────

  /// Refresh and cache the latest [CustomerInfo] from RevenueCat.
  /// Returns null when unconfigured or on error.
  Future<CustomerInfo?> refreshCustomerInfo() async {
    if (!_isConfigured) return null;

    try {
      _customerInfo = await Purchases.getCustomerInfo();
      return _customerInfo;
    } catch (e) {
      debugPrint('⚠️  Error refreshing customer info: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Subscription status
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns true when the current user holds an active entitlement.
  ///
  /// Special cases (evaluated in order):
  ///   1. Apple review test account → always true (bypasses payment, not paywall).
  ///   2. Dev mode (unconfigured)   → always false (paywall is shown).
  ///   3. Production               → live RevenueCat entitlement check.
  Future<bool> hasActiveSubscription() async {
    try {
      final userEmail = Supabase.instance.client.auth.currentUser?.email;

      // 1. Apple review test account — sees paywall, skips actual payment.
      if (userEmail == 'testapple@clearpathrecovery.com') {
        debugPrint('✅ Apple test account — bypassing payment processing');
        return true;
      }

      // 2. Dev mode — show paywall so the flow is visible and testable.
      if (!_isConfigured) {
        debugPrint('⚠️  RevenueCat not configured — returning false (paywall will show)');
        return false;
      }

      // 3. Production — check live entitlement.
      final info = await refreshCustomerInfo();
      if (info == null) return false;

      final hasActive = info.entitlements.active.isNotEmpty;
      debugPrint('Subscription check: hasActive = $hasActive');
      return hasActive;
    } catch (e) {
      debugPrint('⚠️  Error checking subscription: $e');
      return false; // Fail closed — show paywall on error.
    }
  }

  /// Returns true when the user is within a free trial period.
  Future<bool> isInTrialPeriod() async {
    if (!_isConfigured) return false;

    try {
      final info = await refreshCustomerInfo();
      if (info == null) return false;

      for (final entitlement in info.entitlements.active.values) {
        if (entitlement.periodType == PeriodType.trial) return true;
      }
      return false;
    } catch (e) {
      debugPrint('⚠️  Error checking trial period: $e');
      return false;
    }
  }

  /// Returns true when any active entitlement is in a billing grace period.
  Future<bool> isInGracePeriod() async {
    if (!_isConfigured) return false;

    try {
      final info = await refreshCustomerInfo();
      if (info == null) return false;

      for (final entitlement in info.entitlements.active.values) {
        final isUnsubscribed = entitlement.unsubscribeDetectedAt != null;
        final expirationStr = entitlement.expirationDate;

        if (isUnsubscribed && expirationStr != null) {
          final expiration = DateTime.parse(expirationStr);
          if (expiration.isAfter(DateTime.now())) return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('⚠️  Error checking grace period: $e');
      return false;
    }
  }

  /// Returns the expiration date of the first active entitlement, or null.
  Future<DateTime?> getSubscriptionExpirationDate() async {
    if (!_isConfigured) return null;

    try {
      final info = await refreshCustomerInfo();
      if (info == null) return null;

      final entitlements = info.entitlements.active.values;
      if (entitlements.isEmpty) return null;

      final expirationStr = entitlements.first.expirationDate;
      if (expirationStr == null) return null;

      return DateTime.parse(expirationStr);
    } catch (e) {
      debugPrint('⚠️  Error getting expiration date: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Offerings
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetches available [Offerings] from RevenueCat.
  /// Returns null in dev mode (caller should handle gracefully).
  Future<Offerings?> getOfferings() async {
    if (!_isConfigured) {
      debugPrint('⚠️  RevenueCat not configured — cannot fetch offerings (dev mode)');
      return null;
    }

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('⚠️  Error fetching offerings: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Purchase
  // ─────────────────────────────────────────────────────────────────────────

  /// Purchases [package] via RevenueCat.
  ///
  /// Returns null in three situations — all treated as "success, go to /home":
  ///   • Apple review test account.
  ///   • Dev mode (test_ key) — silently succeeds so the UI flow is testable.
  ///   • Successful production purchase (returns cached [CustomerInfo]).
  ///
  /// Throws [PurchasesErrorCode.purchaseCancelledError] when the user cancels,
  /// so the caller can silently ignore the cancellation.
  /// Never throws in dev mode.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;

    // Apple review test account — simulate success.
    if (userEmail == 'testapple@clearpathrecovery.com') {
      debugPrint('✅ Apple test account — simulating successful purchase');
      return null;
    }

    // Dev mode — silently succeed so the full UI flow can be exercised.
    if (!_isConfigured) {
      debugPrint('⚠️  RevenueCat not configured — simulating purchase in dev mode');
      debugPrint('    No real charge will occur (RevenueCat is not initialised).');
      return null;
    }

    // Production purchase.
    try {
      final result = await Purchases.purchasePackage(package);
      _customerInfo = result.customerInfo;
      return _customerInfo;
    } on PurchasesErrorCode catch (errorCode) {
      debugPrint('Purchase error: ${errorCode.name}');
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        rethrow; // Let the UI handle cancellation silently.
      }
      return null;
    } catch (e) {
      debugPrint('⚠️  Error purchasing package: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Restore
  // ─────────────────────────────────────────────────────────────────────────

  /// Restores previous purchases via RevenueCat.
  ///
  /// Returns null in three situations:
  ///   • Apple review test account  → treated as "no purchases to restore".
  ///   • Dev mode (test_ key)       → treated as "no purchases to restore".
  ///   • Production error           → treated as "no purchases to restore".
  ///
  /// The caller in [PaywallPage._restorePurchases] already checks
  /// `info != null && info.entitlements.active.isNotEmpty` before navigating,
  /// so returning null here naturally surfaces the existing "No active
  /// subscriptions found" grey message — no crash banner, no exception.
  Future<CustomerInfo?> restorePurchases() async {
    final userEmail = Supabase.instance.client.auth.currentUser?.email;

    // Apple review test account.
    if (userEmail == 'testapple@clearpathrecovery.com') {
      debugPrint('✅ Apple test account — simulating restore (no purchases)');
      return null;
    }

    // Dev mode — return null so the caller shows "No active subscriptions found".
    if (!_isConfigured) {
      debugPrint('⚠️  RevenueCat not configured — restore is a no-op in dev mode');
      return null;
    }

    // Production restore.
    try {
      final info = await Purchases.restorePurchases();
      _customerInfo = info;
      return _customerInfo;
    } catch (e) {
      debugPrint('⚠️  Error restoring purchases: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether RevenueCat has been successfully configured with a production key.
  bool get isConfigured => _isConfigured;
}