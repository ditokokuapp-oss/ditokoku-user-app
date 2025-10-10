import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class TransactionReceiptPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String phoneNumber;
  final String provider;
  final Map<String, dynamic>? transactionData;
  final String? providerLogo;

  const TransactionReceiptPage({
    super.key,
    required this.product,
    required this.phoneNumber,
    required this.provider,
    this.transactionData,
    this.providerLogo, 
  });

  @override
  State<TransactionReceiptPage> createState() => _TransactionReceiptPageState();
}

class _TransactionReceiptPageState extends State<TransactionReceiptPage> {
  Map<String, dynamic>? currentTransactionData;
  bool isRefreshing = false;
  Timer? _refreshTimer;
  int _autoRefreshCount = 0;
  static const int maxAutoRefreshAttempts = 20;
  
  final Set<String> _loyaltyPointsAdded = <String>{};
  final Set<String> _walletDeducted = <String>{};
  final Set<String> _fundRefunded = <String>{};
  
  bool isAgen = false;
  bool isLoadingAgen = true;
  
  @override
  void initState() {
    super.initState();
    currentTransactionData = widget.transactionData;
    _checkAgenStatus();
    _deductWalletOnPending(); // Kurangi saldo saat pending
    _startAutoRefreshIfNeeded();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  // FUNGSI BARU: Kurangi saldo saat status PENDING
  Future<void> _deductWalletOnPending() async {
    final status = _getTransactionStatus();
    if (status == 'PENDING') {
      final correctPrice = _getCorrectPrice();
      final refId = _getTransactionId();
      
      if (!_walletDeducted.contains(refId)) {
        print('💳 Transaction is PENDING - Deducting $correctPrice from wallet...');
        final deductSuccess = await _deductWalletBalance(
          amount: correctPrice,
          refId: refId,
        );
        
        if (deductSuccess) {
          print('✅ Wallet deducted successfully for PENDING transaction');
        } else {
          print('⚠️ Failed to deduct wallet for PENDING transaction');
        }
      }
    }
  }

  Future<void> _checkAgenStatus() async {
    if (!AuthHelper.isLoggedIn()) {
      setState(() {
        isLoadingAgen = false;
        isAgen = false;
      });
      return;
    }

    try {
      setState(() {
        isLoadingAgen = true;
      });

      final profileController = Get.find<ProfileController>();
      
      if (profileController.userInfoModel == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (profileController.userInfoModel == null) {
          setState(() {
            isLoadingAgen = false;
          });
          return;
        }
      }

      final userId = profileController.userInfoModel!.id;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.token) ?? '';
      
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/users/agen/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            isAgen = true;
            isLoadingAgen = false;
          });
        } else {
          setState(() {
            isAgen = false;
            isLoadingAgen = false;
          });
        }
      } else {
        setState(() {
          isAgen = false;
          isLoadingAgen = false;
        });
      }
    } catch (e) {
      print('Error checking agen status: $e');
      setState(() {
        isAgen = false;
        isLoadingAgen = false;
      });
    }
  }

  double _getCorrectPrice() {
    String typeName = widget.product['type_name']?.toString().toLowerCase() ?? '';
    
    if (typeName == 'pascabayar') {
      return double.tryParse(widget.product['price']?.toString() ?? '0') ?? 0;
    }
    
    if (isAgen) {
      return double.tryParse(widget.product['price']?.toString() ?? '0') ?? 0;
    } else {
      return double.tryParse(
        widget.product['priceTierTwo']?.toString() ?? 
        widget.product['price']?.toString() ?? '0'
      ) ?? 0;
    }
  }

  void _startAutoRefreshIfNeeded() {
    if (_isTransactionPending() && _autoRefreshCount < maxAutoRefreshAttempts) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _refreshTransactionStatus(isAutoRefresh: true);
      });
    }
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  String _formatPrice(String price) {
    double priceDouble = double.tryParse(price) ?? 0;
    return priceDouble.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
  }

  String _getTransactionId() {
    if (currentTransactionData != null) {
      return currentTransactionData!['ref_id'] ?? 'N/A';
    }
    return 'OPAY${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  String _formatDateTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} • ${now.day} ${_getMonthName(now.month)} ${now.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                   'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  String _getTransactionStatus() {
    if (currentTransactionData == null) return 'SUCCESS';
    
    if (currentTransactionData!['digiflazz_response'] != null &&
        currentTransactionData!['digiflazz_response']['data'] != null &&
        currentTransactionData!['digiflazz_response']['data']['status'] != null) {
      return currentTransactionData!['digiflazz_response']['data']['status'].toString().toUpperCase();
    }
    
    final status = currentTransactionData!['transaction_status']?.toString().toUpperCase();
    return status ?? 'PENDING';
  }

  bool _isTransactionSuccessful() {
    final status = _getTransactionStatus();
    return status == 'SUCCESS' || status == 'SUKSES';
  }

  bool _isTransactionPending() {
    return _getTransactionStatus() == 'PENDING';
  }

  bool _isTransactionFailed() {
    final status = _getTransactionStatus();
    return status == 'FAILED' || status == 'GAGAL';
  }

  String _getProductName() {
    if (currentTransactionData != null && currentTransactionData!['product'] != null) {
      return currentTransactionData!['product']['name'] ?? widget.product['product_name'] ?? '';
    }
    return widget.product['product_name'] ?? '';
  }

  String _getPrice() {
    if (currentTransactionData != null && currentTransactionData!['product'] != null) {
      final apiPrice = currentTransactionData!['product']['price'];
      if (apiPrice != null) {
        return _formatPrice(apiPrice.toString());
      }
    }
    return _formatPrice(_getCorrectPrice().toString());
  }

  String _getSerialNumber() {
    if (currentTransactionData != null && 
        currentTransactionData!['digiflazz_response'] != null &&
        currentTransactionData!['digiflazz_response']['data'] != null) {
      return currentTransactionData!['digiflazz_response']['data']['sn'] ?? '';
    }
    return '';
  }

  String _extractPLNToken() {
    final sn = _getSerialNumber();
    if (sn.isEmpty) return '';
    
    final parts = sn.split('/');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return '';
  }

  bool _isPLNProduct() {
    final productName = _getProductName().toUpperCase();
    final buyerSkuCode = widget.product['buyer_sku_code']?.toString().toUpperCase() ?? '';
    
    return productName.contains('PLN') || 
           productName.contains('TOKEN') ||
           productName.contains('LISTRIK') ||
           buyerSkuCode.contains('PLN');
  }

  Future<int> _getNominalPointFromProducts(String buyerSkuCode) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        
        final product = products.firstWhere(
          (p) => p['buyer_sku_code'] == buyerSkuCode,
          orElse: () => null,
        );

        if (product != null && product['nominal_point'] != null) {
          return int.tryParse(product['nominal_point'].toString()) ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching nominal point from products API: $e');
    }
    
    return 10;
  }

  Future<bool> _addLoyaltyPoints({
    required String refId,
    required int nominalPoint,
  }) async {
    try {
      if (_loyaltyPointsAdded.contains(refId)) {
        print('Loyalty points already added for transaction: $refId');
        return true;
      }

      int? userId;
      try {
        final profileController = Get.find<ProfileController>();
        userId = profileController.userInfoModel?.id;
      } catch (e) {
        print('Error getting user ID: $e');
        return false;
      }

      if (userId == null) {
        print('User ID is null, cannot add loyalty points');
        return false;
      }

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        AppConstants.addLoyaltyPointUri,
        {
          "point": nominalPoint,
          "user_id": userId,
          "ref_id": refId,
          "source": "ppob_transaction",
          "type": "add"
        },
      );

      if (response.statusCode == 200) {
        print('Loyalty points added successfully: $nominalPoint points for $refId');
        _loyaltyPointsAdded.add(refId);
        
        try {
          Get.find<ProfileController>().getUserInfo();
        } catch (e) {
          print('Error refreshing profile: $e');
        }
        
        return true;
      } else {
        print('Failed to add loyalty points: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding loyalty points: $e');
      return false;
    }
  }

  Future<bool> _updateTransactionStatusInDatabase({
    required String refId,
    required String status,
    String? message,
    String? sn,
  }) async {
    try {
      if (currentTransactionData == null || currentTransactionData!['id'] == null) {
        print('No transaction ID available for update');
        return false;
      }

      int? userId;
      try {
        final profileController = Get.find<ProfileController>();
        userId = profileController.userInfoModel?.id;
      } catch (e) {
        print('Error getting user ID: $e');
        userId = 1;
      }

      final response = await http.put(
        Uri.parse('https://api.ditokoku.id/api/ppob/${currentTransactionData!['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_no': widget.phoneNumber,
          'buyer_sku_code': widget.product['buyer_sku_code'] ?? currentTransactionData?['buyer_sku_code'],
          'message': message ?? currentTransactionData?['message'] ?? '',
          'status': status,
          'rc': status == 'SUCCESS' ? '00' : '01',
          'buyer_last_saldo': 0,
          'sn': sn ?? currentTransactionData?['sn'] ?? '',
          'price': _getCorrectPrice(),
          'tele': '',
          'wa': '',
          'user_id': userId ?? 1,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating transaction status in database: $e');
      return false;
    }
  }

  Future<bool> _deductWalletBalance({
    required double amount,
    required String refId,
  }) async {
    try {
      if (_walletDeducted.contains(refId)) {
        print('Wallet already deducted for transaction: $refId');
        return true;
      }

      print('=== Deducting Wallet Balance ===');
      print('Amount: $amount');
      print('Ref ID: $refId');

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        AppConstants.deductFundUri,
        {
          "amount": amount,
          "transaction_type": "ppob_payment",
          "reference": refId,
        },
      );

      print('Deduct response status: ${response.statusCode}');
      print('Deduct response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Wallet deducted successfully');
        _walletDeducted.add(refId);
        
        try {
          Get.find<ProfileController>().getUserInfo();
        } catch (e) {
          print('Error refreshing profile: $e');
        }
        
        return true;
      } else {
        print('❌ Failed to deduct wallet: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deducting wallet balance: $e');
      return false;
    }
  }

  // FUNGSI BARU: AddFund untuk refund saat transaksi gagal
  Future<bool> _addFundToWallet({
    required double amount,
    required String refId,
  }) async {
    try {
      if (_fundRefunded.contains(refId)) {
        print('Fund already refunded for transaction: $refId');
        return true;
      }

      print('=== Adding Fund to Wallet (Refund) ===');
      print('Amount: $amount');
      print('Ref ID: $refId');

      int? userId;
      try {
        final profileController = Get.find<ProfileController>();
        userId = profileController.userInfoModel?.id;
      } catch (e) {
        print('Error getting user ID: $e');
        return false;
      }

      if (userId == null) {
        print('User ID is null, cannot add fund');
        return false;
      }

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.postData(
        AppConstants.addFundUri,
        {
          'customer_id': userId,
          'amount': amount,
          'referance': refId,
          'payment_method': 'QRIS'
        },
      );

      print('Add fund response status: ${response.statusCode}');
      print('Add fund response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Fund added successfully (Refunded)');
        _fundRefunded.add(refId);
        
        try {
          Get.find<ProfileController>().getUserInfo();
        } catch (e) {
          print('Error refreshing profile: $e');
        }
        
        return true;
      } else {
        print('❌ Failed to add fund: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error adding fund to wallet: $e');
      return false;
    }
  }

  Future<void> _refreshTransactionStatus({bool isAutoRefresh = false}) async {
    if ((!_isTransactionPending() && !isAutoRefresh) || isRefreshing) return;

    if (isAutoRefresh && _autoRefreshCount >= maxAutoRefreshAttempts) {
      _stopAutoRefresh();
      return;
    }

    setState(() {
      isRefreshing = true;
    });

    try {
      final requestBody = {
        'customer_no': widget.phoneNumber,
        'buyer_sku_code': widget.product['buyer_sku_code'] ?? currentTransactionData?['buyer_sku_code'],
        'ref_id': _getTransactionId(),
        'testing': false,
      };

      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/check-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        String newStatus = 'PENDING';
        String? newMessage;
        String? newSn;
        
        if (responseData['digiflazz_response'] != null &&
            responseData['digiflazz_response']['data'] != null) {
          final data = responseData['digiflazz_response']['data'];
          newStatus = data['status']?.toString().toUpperCase() ?? 'PENDING';
          newMessage = data['message']?.toString();
          newSn = data['sn']?.toString();
        } else if (responseData['transaction_status'] != null) {
          newStatus = responseData['transaction_status'].toString().toUpperCase();
        }

        final currentStatus = _getTransactionStatus();
        
        if (newStatus != currentStatus) {
          print('🔄 Status changed from $currentStatus to $newStatus');
          
          final updateSuccess = await _updateTransactionStatusInDatabase(
            refId: _getTransactionId(),
            status: newStatus,
            message: newMessage,
            sn: newSn,
          );

          if (updateSuccess) {
            print('✅ Database updated successfully');
          }

          final correctPrice = _getCorrectPrice();
          
          // FLOW BARU
          if (newStatus == 'SUCCESS' || newStatus == 'SUKSES') {
            print('✅ Transaction SUCCESS - No action needed (already deducted)');
            
            // Tambahkan loyalty points
            if (!_loyaltyPointsAdded.contains(_getTransactionId())) {
              try {
                final buyerSkuCode = widget.product['buyer_sku_code'] ?? 
                                    currentTransactionData?['buyer_sku_code'] ?? '';
                final nominalPoint = await _getNominalPointFromProducts(buyerSkuCode);
                
                if (nominalPoint > 0) {
                  print('🎁 Adding $nominalPoint loyalty points...');
                  final loyaltyAdded = await _addLoyaltyPoints(
                    refId: _getTransactionId(),
                    nominalPoint: nominalPoint,
                  );
                  
                  if (loyaltyAdded && !isAutoRefresh && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$nominalPoint loyalty points telah ditambahkan!'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('❌ Error adding loyalty points: $e');
              }
            }
          } else if (newStatus == 'FAILED' || newStatus == 'GAGAL') {
            print('❌ Transaction FAILED - Refunding amount...');
            
            if (!_fundRefunded.contains(_getTransactionId())) {
              print('💰 Refunding $correctPrice to wallet...');
              final refundSuccess = await _addFundToWallet(
                amount: correctPrice,
                refId: _getTransactionId(),
              );
              
              if (refundSuccess) {
                print('✅ Fund refunded successfully');
                
                if (!isAutoRefresh && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rp${_formatPrice(correctPrice.toString())} telah dikembalikan ke saldo Anda'),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              } else {
                print('⚠️ Failed to refund');
              }
            }
          }

          setState(() {
            currentTransactionData = responseData;
          });

          if (isAutoRefresh) {
            _autoRefreshCount++;
          }
          
          if (!_isTransactionPending()) {
            _stopAutoRefresh();
            
            if (isAutoRefresh && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isTransactionSuccessful() 
                      ? 'Transaksi berhasil!' 
                      : 'Transaksi gagal, saldo telah dikembalikan'
                  ),
                  duration: const Duration(seconds: 3),
                  backgroundColor: _isTransactionSuccessful() 
                    ? Colors.green 
                    : Colors.orange,
                ),
              );
            }
          }
        } else {
          setState(() {
            currentTransactionData = responseData;
          });

          if (isAutoRefresh) {
            _autoRefreshCount++;
          }
        }
      }
    } catch (e) {
      if (!isAutoRefresh && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text berhasil disalin'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareReceipt() {
    final transactionId = _getTransactionId();
    final dateTime = _formatDateTime();
    final price = _getPrice();
    final productName = _getProductName();
    final statusText = _getStatusText();
    
    String statusEmoji = '⏳';
    if (_isTransactionSuccessful()) statusEmoji = '✅';
    if (_isTransactionFailed()) statusEmoji = '❌';
    
    String shareText = '''
🧾 STRUK TRANSAKSI $productName

📅 $dateTime
🆔 ID Transaksi: $transactionId

$statusEmoji $statusText

📦 Produk: $productName
📱 Nomor: ${widget.phoneNumber}
''';

    if (_isPLNProduct() && _isTransactionSuccessful()) {
      final token = _extractPLNToken();
      if (token.isNotEmpty) {
        shareText += '\n🔑 Token PLN: $token';
      }
    }

    shareText += '\n\nTerima kasih telah menggunakan layanan kami!';

    Share.share(shareText);
  }

  String _getStatusText() {
    if (_isTransactionSuccessful()) return 'Transaksi Berhasil';
    if (_isTransactionPending()) return 'Transaksi Pending';
    return 'Transaksi Gagal';
  }

  String _getPageTitle() {
    if (_isTransactionSuccessful()) return 'Pembayaran Berhasil';
    if (_isTransactionFailed()) return 'Pembayaran Gagal';
    return 'Struk Transaksi';
  }

  String _getHeaderStatus() {
    if (_isTransactionSuccessful()) return 'Transaksi Berhasil';
    if (_isTransactionFailed()) return 'Transaksi Gagal';
    return 'Transaksi Pending';
  }

  Widget _getSuccessIcon() {
    return Container(
      margin: const EdgeInsets.only(bottom: 42),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            child: Center(
              child: Image.asset(
                'assets/image/successtrx.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFailedIcon() {
    return Container(
      margin: const EdgeInsets.only(bottom: 48),
      child: Container(
        width: 150,
        height: 150,
        child: Center(
          child: Image.asset(
            'assets/image/failedtrx.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _getPendingIcon() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 30),
      child: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFF7931E),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'T',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getBottomMessage() {
    if (_isTransactionSuccessful()) {
      return "Pembayaran anda telah berhasil. \nTerimakasih telah menggunakan O-Payment dari ditokoku.id untuk melakukan transaksi.";
    } else if (_isTransactionFailed()) {
      return "Pembayaran gagal. Saldo telah dikembalikan ke akun Anda.";
    }
    return "Transaksi sedang diproses. Saldo telah dipotong dan akan dikembalikan jika transaksi gagal.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isTransactionPending())
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Struk Transaksi',
                          style: TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: isRefreshing ? null : () => _refreshTransactionStatus(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isRefreshing
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(top: 46, bottom: 50),
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        _getPageTitle(),
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Positioned(
                        right: 16,
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(context, _getTransactionId()),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: Image.asset(
                              'assets/image/downicon.png',
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_isTransactionPending()) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: Container(
                      width: 46,
                      height: 62,
                      child: Image.asset(
                        widget.providerLogo ?? 'assets/image/t_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                Container(
                  margin: const EdgeInsets.only(bottom: 23, left: 34, right: 34),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF2F318B),
                            ),
                            padding: const EdgeInsets.only(top: 19, bottom: 80, left: 20, right: 20),
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDateTime(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Text(
                                  _getTransactionId(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(context, _getTransactionId()),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 1),
                                    width: 16,
                                    height: 16,
                                    child: const Icon(
                                      Icons.copy,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Transform.translate(
                          offset: const Offset(0, 7),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 13, bottom: 11, left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Nama Produk',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        _getProductName(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: const Color(0xFFD9D9D9),
                                  margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                                  height: 1,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 7, left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Nomor Pelanggan',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        widget.phoneNumber,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 9, left: 39, right: 39),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 7),
                        width: 21,
                        height: 21,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9A021),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Transaksi Pending',
                          style: TextStyle(
                            color: Color(0xFFF9A021),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFF9400),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFFFF2DF),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.only(bottom: 100, left: 34, right: 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9, left: 41, right: 41),
                        child: const Text(
                          'Transaksi sedang diproses.\nSaldo telah dipotong dan akan dikembalikan jika transaksi gagal.\nStatus akan diperbarui otomatis setiap 3 detik',
                          style: TextStyle(
                            color: Color(0xFFF89506),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 41),
                        child: Text(
                          'Auto refresh aktif (${_autoRefreshCount}/$maxAutoRefreshAttempts)',
                          style: const TextStyle(
                            color: Color(0xFFF89506),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4, left: 33, right: 33), 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // WhatsApp support action
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF2F318B),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x0D14142B),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            margin: const EdgeInsets.only(right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 29,
                                  height: 29,
                                  margin: const EdgeInsets.only(right: 6),
                                  child: Image.asset(
                                    'assets/image/waicon.png',
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const Text(
                                  'Bantuan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _shareReceipt,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF2F318B),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x0D14142B),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 39, right: 16),
                  width: double.infinity,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        'Kembali Ke Beranda',
                        style: TextStyle(
                          color: Color(0xFF2F318B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 31, left: 34, right: 34),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Color(0xFF2F318B),
                        ),
                        padding: const EdgeInsets.only(top: 14, bottom: 16, left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getHeaderStatus(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDateTime(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.only(top: 15, bottom: 29, left: 12, right: 12),
                        child: Column(
                          children: [
                            if (_isTransactionSuccessful())
                              _getSuccessIcon()
                            else if (_isTransactionFailed())
                              _getFailedIcon(),

                            _buildDetailRow('Nama Produk', _getProductName()),
                            _buildDivider(),
                            _buildDetailRow('Nomor Telepon', widget.phoneNumber),
                            _buildDivider(),
                            _buildDetailRow('Harga', 'Rp. ${_getPrice()}'),
                            _buildDetailRow('Biaya Admin', 'Gratis!', isGreen: true),
                            _buildDetailRow('Keterangan', _getProductName()),
                            _buildDivider(),
                            _buildTotalRow('Total Pembayaran', 'Rp ${_getPrice()}'),
                            
                            if (_isPLNProduct() && _isTransactionSuccessful() && _extractPLNToken().isNotEmpty) ...[
                              _buildDivider(),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFA726)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.electric_bolt,
                                          color: Color(0xFFFFA726),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Token PLN',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF000000),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _extractPLNToken(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF000000),
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _copyToClipboard(context, _extractPLNToken()),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFA726),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.copy,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(
                    bottom: _isTransactionSuccessful() ? 50 : 80, 
                    left: 34, 
                    right: 34
                  ),
                  width: double.infinity,
                  child: Text(
                    _getBottomMessage(),
                    style: const TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 60, left: 33, right: 33),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF2F318B),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x0D14142B),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            margin: const EdgeInsets.only(right: 12),
                            child: const Text(
                              "Kembali ke Beranda",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _shareReceipt,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF2F318B),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x0D14142B),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isGreen = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isGreen ? const Color(0xFF72A677) : const Color(0xFF000000),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      color: const Color(0xFFD9D9D9),
      margin: const EdgeInsets.only(bottom: 8),
      height: 1,
      width: double.infinity,
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2F318B)
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.6;

    for (int i = 0; i < 10; i++) {
      final angle = (i * 36) * (math.pi / 180);
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians);