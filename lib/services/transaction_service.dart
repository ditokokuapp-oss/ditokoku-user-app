// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class TransactionService {
  static const String baseUrl = 'https://api.ditokoku.id';
  
  // Get current user ID
  static String? getCurrentUserId() {
    if (!AuthHelper.isLoggedIn()) return null;
    
    try {
      final profileController = Get.find<ProfileController>();
      if (profileController.userInfoModel != null) {
        final userModel = profileController.userInfoModel!;
        return userModel.id?.toString();
      }
    } catch (e) {
      print('Error getting user ID: $e');
    }
    
    return null;
  }
  
  // Get transaction history from PPOB API
  static Future<PPOBTransactionResponse> getTransactionHistory({
    String? userId, 
    int? limit, 
    int? offset,
  }) async {
    try {
      userId ??= getCurrentUserId();
      if (userId == null) {
        return PPOBTransactionResponse(
          success: false, 
          transactions: [], 
          message: 'User tidak ditemukan. Silakan login ulang.'
        );
      }
      
      Map<String, String> queryParams = {};
      
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }
      
      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }
      
      final uri = Uri.parse('$baseUrl/api/ppob/user/$userId').replace(queryParameters: queryParams);
      
      print('Fetching transactions from: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Transaction Response Status: ${response.statusCode}');
      print('Transaction Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final transactions = (data['data'] as List)
              .map((json) => PPOBTransactionModel.fromJson(json))
              .toList();
          
          return PPOBTransactionResponse(
            success: true, 
            transactions: transactions,
            total: data['total'] ?? transactions.length,
            hasMore: transactions.length >= (limit ?? 50)
          );
        }
      }
      
      return PPOBTransactionResponse(
        success: false, 
        transactions: [], 
        message: 'Belum ada transaksi'
      );
    } catch (e) {
      print('Error fetching transactions: $e');
      return PPOBTransactionResponse(
        success: false, 
        transactions: [], 
        message: 'Error: $e'
      );
    }
  }

  // Get recent transactions (last 3)
  static Future<PPOBTransactionResponse> getRecentTransactions({String? userId}) async {
    return await getTransactionHistory(userId: userId, limit: 3, offset: 0);
  }
}

// Response wrapper class for PPOB API
class PPOBTransactionResponse {
  final bool success;
  final List<PPOBTransactionModel> transactions;
  final String? message;
  final int total;
  final bool hasMore;

  PPOBTransactionResponse({
    required this.success,
    required this.transactions,
    this.message,
    this.total = 0,
    this.hasMore = false,
  });
}

// Model untuk PPOB transaction response
class PPOBTransactionModel {
  final int id;
  final int userId;
  final String refId;
  final String customerNo;
  final String buyerSkuCode;
  final String message;
  final String status;
  final String rc;
  final double buyerLastSaldo;
  final String sn;
  final double price;
  final String tele;
  final String wa;
  final DateTime createdAt;
  final DateTime updatedAt;

  PPOBTransactionModel({
    required this.id,
    required this.userId,
    required this.refId,
    required this.customerNo,
    required this.buyerSkuCode,
    required this.message,
    required this.status,
    required this.rc,
    required this.buyerLastSaldo,
    required this.sn,
    required this.price,
    required this.tele,
    required this.wa,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PPOBTransactionModel.fromJson(Map<String, dynamic> json) {
    return PPOBTransactionModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      refId: json['ref_id'] ?? '',
      customerNo: json['customer_no'] ?? '',
      buyerSkuCode: json['buyer_sku_code'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      rc: json['rc'] ?? '',
      buyerLastSaldo: double.tryParse(json['buyer_last_saldo']?.toString() ?? '0') ?? 0,
      sn: json['sn'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      tele: json['tele'] ?? '',
      wa: json['wa'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
  
  // Helper getters
  String get productName {
    // Extract product name from buyer_sku_code or use a mapping
    return _getProductNameFromSku(buyerSkuCode);
  }
  
  String get categoryName {
    return _getCategoryFromSku(buyerSkuCode);
  }
  
  String get brandName {
    return _getBrandFromSku(buyerSkuCode);
  }
  
  // Helper methods to extract info from SKU code
  String _getProductNameFromSku(String sku) {
    // Map common SKU codes to product names
    const skuMap = {
      'TSEL2': 'Telkomsel 2rb',
      'TSEL5': 'Telkomsel 5rb',
      'TSEL10': 'Telkomsel 10rb',
      'TSEL20': 'Telkomsel 20rb',
      'TSEL25': 'Telkomsel 25rb',
      'TSEL50': 'Telkomsel 50rb',
      'TSEL100': 'Telkomsel 100rb',
      'XL5': 'XL 5rb',
      'XL10': 'XL 10rb',
      'XL25': 'XL 25rb',
      'XL50': 'XL 50rb',
      'XL100': 'XL 100rb',
      'ISAT5': 'Indosat 5rb',
      'ISAT10': 'Indosat 10rb',
      'ISAT25': 'Indosat 25rb',
      'ISAT50': 'Indosat 50rb',
      'ISAT100': 'Indosat 100rb',
    };
    
    return skuMap[sku] ?? sku;
  }
  
  String _getCategoryFromSku(String sku) {
    if (sku.startsWith('TSEL') || sku.startsWith('XL') || sku.startsWith('ISAT') || sku.startsWith('AXIS') || sku.startsWith('THREE')) {
      return 'Pulsa';
    } else if (sku.contains('DATA') || sku.contains('INTERNET')) {
      return 'Data';
    } else if (sku.contains('PLN') || sku.contains('LISTRIK')) {
      return 'PLN';
    } else if (sku.contains('GAME')) {
      return 'Game';
    }
    return 'Lainnya';
  }
  
  String _getBrandFromSku(String sku) {
    if (sku.startsWith('TSEL')) {
      return 'Telkomsel';
    } else if (sku.startsWith('XL')) {
      return 'XL';
    } else if (sku.startsWith('ISAT')) {
      return 'Indosat';
    } else if (sku.startsWith('AXIS')) {
      return 'Axis';
    } else if (sku.startsWith('THREE')) {
      return 'Three';
    }
    return 'Unknown';
  }
}