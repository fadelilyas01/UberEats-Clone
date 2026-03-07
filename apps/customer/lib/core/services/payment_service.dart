import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> initPaymentSheet({
    required double amount,
    required String currency,
    required String restaurantId,
  }) async {
    try {
      // 1. Create payment intent on the server

      // Use Local Emulator for testing
      _functions.useFunctionsEmulator('192.168.2.12', 5001); // Local PC IP
      // For iOS Simulator use: 'localhost'
      // For Real Device use your computer's local IP

      final result =
          await _functions.httpsCallable('createPaymentIntent').call({
        'amount': amount,
        'currency': currency,
        'restaurantId': restaurantId,
      });

      final data = result.data as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String;

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'FoodFlow Pro',
          // style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      debugPrint('Error initiating payment: $e');
      rethrow;
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      debugPrint('Error presenting payment sheet: $e');
      rethrow;
    }
  }
}
