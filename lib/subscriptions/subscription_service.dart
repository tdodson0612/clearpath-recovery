// lib/subscriptions/subscription_service.dart
// ADD THIS METHOD to bypass paywall for Apple test account

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing subscriptions with RevenueCat
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isConfigured = false;
  CustomerInfo? _customerInfo;

  /// Initialize RevenueCat
  Future<void> initialize({
    required String apiKey,
    String? appUserId,
  }) async {
    if (_isConfigured) return;

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
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
    }
  }

  /// Refresh customer info
  Future<CustomerInfo?> refreshCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      return _customerInfo;
    } catch (e) {
      debugPrint('Error refreshing customer info: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  /// MODIFIED: Added bypass for Apple test account
  Future<bool> hasActiveSubscription() async {
    try {
      // BYPASS FOR APPLE TEST ACCOUNT - CRITICAL FOR APP REVIEW
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      if (userEmail == 'testapple@clearpathrecovery.com') {
        debugPrint('✅ Test account detected - bypassing paywall');
        return true;
      }

      final info = await refreshCustomerInfo();
      if (info == null) return false;
      return info.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      return false;
    }
  }

  /// Check if user is in trial period
  Future<bool> isInTrialPeriod() async {
    try {
      final info = await refreshCustomerInfo();
      if (info == null) return false;

      for (var entitlement in info.entitlements.active.values) {
        if (entitlement.periodType == PeriodType.trial) return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking trial period: $e');
      return false;
    }
  }

  /// Check if any active subscription is in grace period
  Future<bool> isInGracePeriod() async {
    try {
      final info = await refreshCustomerInfo();
      if (info == null) return false;

      for (var entitlement in info.entitlements.active.values) {
        final isUnsubscribed = entitlement.unsubscribeDetectedAt != null;
        final expirationStr = entitlement.expirationDate;

        if (isUnsubscribed && expirationStr != null) {
          final expiration = DateTime.parse(expirationStr);
          if (expiration.isAfter(DateTime.now())) return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking grace period: $e');
      return false;
    }
  }

  /// Get subscription expiration date
  Future<DateTime?> getSubscriptionExpirationDate() async {
    try {
      final info = await refreshCustomerInfo();
      if (info == null) return null;

      final entitlements = info.entitlements.active.values;
      if (entitlements.isEmpty) return null;

      final expirationStr = entitlements.first.expirationDate;
      if (expirationStr == null) return null;

      return DateTime.parse(expirationStr);
    } catch (e) {
      debugPrint('Error getting expiration date: $e');
      return null;
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      _customerInfo = purchaseResult.customerInfo;
      return _customerInfo;
    } on PurchasesErrorCode catch (errorCode) {
      debugPrint('Purchase error: ${errorCode.name}');
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        rethrow;
      }
      return null;
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      return null;
    }
  }

  /// Restore previous purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _customerInfo = info;
      return _customerInfo;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return null;
    }
  }
}