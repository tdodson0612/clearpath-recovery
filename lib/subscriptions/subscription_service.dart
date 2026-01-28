// lib/subscriptions/subscription_service.dart

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
      if (appUserId != null) configuration.appUserID = appUserId;

      await Purchases.configure(configuration);
      _isConfigured = true;

      if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);

      await refreshCustomerInfo();
    } catch (e) {
      print('Error initializing RevenueCat: $e');
      rethrow;
    }
  }

  /// Refresh customer info
  Future<CustomerInfo?> refreshCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      return _customerInfo;
    } catch (e) {
      print('Error refreshing customer info: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    final info = await refreshCustomerInfo();
    if (info == null) return false;
    return info.entitlements.active.isNotEmpty;
  }

  /// Check if user is in trial period
  Future<bool> isInTrialPeriod() async {
    final info = await refreshCustomerInfo();
    if (info == null) return false;

    for (var entitlement in info.entitlements.active.values) {
      if (entitlement.periodType == PeriodType.trial) return true;
    }
    return false;
  }

  /// Check if any active subscription is in grace period
  Future<bool> isInGracePeriod() async {
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
  }

  /// Get subscription expiration date
  Future<DateTime?> getSubscriptionExpirationDate() async {
    final info = await refreshCustomerInfo();
    if (info == null) return null;

    final entitlements = info.entitlements.active.values;
    if (entitlements.isEmpty) return null;

    final expirationStr = entitlements.first.expirationDate;
    if (expirationStr == null) return null;

    return DateTime.parse(expirationStr);
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      print('Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package using the new API
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      // Use the named constructor for Package
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );

      _customerInfo = purchaseResult.customerInfo;
      return _customerInfo;
    } on PurchasesErrorCode catch (_) {
      rethrow;
    } catch (e) {
      print('Error purchasing package: $e');
      return null;
    }
  }

  /// Restore previous purchases (still returns CustomerInfo directly)
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _customerInfo = info;
      return _customerInfo;
    } catch (e) {
      print('Error restoring purchases: $e');
      return null;
    }
  }
}
