// lib/subscriptions/subscription_service.dart

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
      // Check if using test key - if so, skip initialization to avoid crash
      if (apiKey.startsWith('test_')) {
        debugPrint('⚠️ Test API key detected - skipping RevenueCat initialization');
        debugPrint('💡 App will run in development mode with bypassed subscription checks');
        _isConfigured = false; // Mark as NOT configured so checks are bypassed
        return;
      }

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
      debugPrint('✓ RevenueCat configured successfully with production key');
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
      _isConfigured = false;
    }
  }

  /// Refresh customer info
  Future<CustomerInfo?> refreshCustomerInfo() async {
    if (!_isConfigured) return null;
    
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      return _customerInfo;
    } catch (e) {
      debugPrint('Error refreshing customer info: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  /// DEVELOPMENT MODE: Returns true when RevenueCat is not configured (test keys)
  Future<bool> hasActiveSubscription() async {
    try {
      // BYPASS #1: For Apple test account (App Review)
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      if (userEmail == 'testapple@clearpathrecovery.com') {
        debugPrint('✅ Test account detected - bypassing paywall');
        return true;
      }

      // BYPASS #2: If RevenueCat is not configured (test key), allow access for development
      if (!_isConfigured) {
        debugPrint('✅ Development mode - bypassing subscription check (RevenueCat not configured)');
        return true;
      }

      // PRODUCTION: Check actual subscription status
      final info = await refreshCustomerInfo();
      if (info == null) return false;
      return info.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      // In development, allow access on error
      if (!_isConfigured) {
        debugPrint('✅ Error in development mode - allowing access');
        return true;
      }
      return false;
    }
  }

  /// Check if user is in trial period
  Future<bool> isInTrialPeriod() async {
    if (!_isConfigured) return false;
    
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
    if (!_isConfigured) return false;
    
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
      debugPrint('Error getting expiration date: $e');
      return null;
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    if (!_isConfigured) {
      debugPrint('⚠️ RevenueCat not configured - cannot fetch offerings');
      return null;
    }
    
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isConfigured) {
      debugPrint('⚠️ RevenueCat not configured - cannot purchase');
      return null;
    }
    
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
    if (!_isConfigured) {
      debugPrint('⚠️ RevenueCat not configured - cannot restore purchases');
      return null;
    }
    
    try {
      final info = await Purchases.restorePurchases();
      _customerInfo = info;
      return _customerInfo;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return null;
    }
  }

  /// Check if RevenueCat is properly configured (useful for debugging)
  bool get isConfigured => _isConfigured;
}