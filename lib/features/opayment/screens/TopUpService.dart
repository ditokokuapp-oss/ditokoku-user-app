// ==============================================
// FILE 1: TopUpService.dart - Complete Fixed Version
// ==============================================

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/api/api_client.dart';

class TopUpService {
  static const String baseUrl = 'https://api.ditokoku.id'; // Ganti dengan URL API Anda

  static Future<TopUpResponse> createTopUpTransaction({
    required String method,
    required int amount,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tripay/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'method': method,
          'amount': amount,
          'name': name,
          'email': email,
          'phone': phone,
        }),
      );

      final data = json.decode(response.body);
      print('API Response: $data');

      if (response.statusCode == 200) {
        final bool success = data['success'] ?? false;
        String? checkoutUrl;
        String? transactionId;
        
        if (success && data['data'] != null) {
          checkoutUrl = data['data']['checkout_url'];
          transactionId = data['data']['reference'];
        }
        
        return TopUpResponse(
          success: success,
          checkoutUrl: checkoutUrl,
          transactionId: transactionId,
          message: data['message'],
        );
      } else {
        return TopUpResponse(
          success: false,
          message: data['message'] ?? 'Gagal membuat transaksi',
        );
      }
    } catch (e) {
      print('Error in TopUpService: $e');
      return TopUpResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  static Future<AddFundResponse> addFundsToWallet({
    required double amount,
    String? reference,
  }) async {
    try {
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userInfoModel?.id;
      
      if (userId == null) {
        return AddFundResponse(
          success: false,
          message: 'User not found. Please login again.',
        );
      }

      print('=== AddFundsToWallet API Call ===');
      print('User ID: $userId');
      print('Amount: $amount');
      print('Reference: $reference');
      print('Endpoint: ${AppConstants.baseUrl}${AppConstants.addFundUri}');

      if (AuthHelper.isLoggedIn()) {
        final apiClient = Get.find<ApiClient>();
        
        final response = await apiClient.postData(
          AppConstants.addFundUri,
          {
            'customer_id': userId,
            'amount': amount,
            'referance': reference ?? 'TOPUP_${DateTime.now().millisecondsSinceEpoch}',
            'payment_method': 'QRIS'
          }
        );

        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return AddFundResponse(
            success: true,
            message: 'Funds added successfully',
            newBalance: null,
          );
        } else {
          return AddFundResponse(
            success: false,
            message: response.body['message'] ?? 'Failed to add funds',
          );
        }
      } else {
        return AddFundResponse(
          success: false,
          message: 'User not authenticated',
        );
      }
    } catch (e) {
      print('Error in addFundsToWallet: $e');
      return AddFundResponse(
        success: false,
        message: 'Error: $e',
      );
    }
  }
}

class TopUpResponse {
  final bool success;
  final String? checkoutUrl;
  final String? transactionId;
  final String? message;

  TopUpResponse({
    required this.success,
    this.checkoutUrl,
    this.transactionId,
    this.message,
  });
}

class AddFundResponse {
  final bool success;
  final String message;
  final double? newBalance;

  AddFundResponse({
    required this.success,
    required this.message,
    this.newBalance,
  });
}
