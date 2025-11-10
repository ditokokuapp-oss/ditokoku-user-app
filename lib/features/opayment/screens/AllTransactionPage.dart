import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/services/transaction_service.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AllTransactionPage extends StatefulWidget {
  const AllTransactionPage({super.key});

  @override
  State<AllTransactionPage> createState() => _AllTransactionPageState();
}

class _AllTransactionPageState extends State<AllTransactionPage> {
  List<PPOBTransactionModel> transactions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 0;
  final int pageSize = 10;
  bool hasMore = true;
  
  String selectedStatus = 'Semua';
  String selectedCategory = 'Semua';
  String searchQuery = '';
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  Timer? _autoRefreshTimer;
  final Set<String> _refreshingTransactions = <String>{};
  final Set<String> _loyaltyPointsAdded = <String>{};
  final Set<String> _walletDeducted = <String>{};
  final Set<String> _fundRefunded = <String>{};
  
  bool isAgen = false;
  bool isLoadingAgen = true;
  
  final List<String> statusOptions = ['Semua', 'Success', 'Pending', 'Failed'];
  final List<String> categoryOptions = ['Semua', 'Pulsa', 'Data', 'PLN', 'Game', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _checkAgenStatus();
    _loadTransactions(refresh: true);
    _scrollController.addListener(_onScroll);
    _startAutoRefreshTimer();
  }

  @override
  void dispose() {
    _stopAutoRefreshTimer();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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

  double _getCorrectPriceForTransaction(PPOBTransactionModel transaction, Map<String, dynamic>? productData) {
    if (productData == null) {
      return transaction.price;
    }

    String typeName = productData['type_name']?.toString().toLowerCase() ?? '';
    
    if (typeName == 'pascabayar') {
      return double.tryParse(productData['price']?.toString() ?? '0') ?? transaction.price;
    }
    
    if (isAgen) {
      return double.tryParse(productData['price']?.toString() ?? '0') ?? transaction.price;
    } else {
      return double.tryParse(
        productData['priceTierTwo']?.toString() ?? 
        productData['price']?.toString() ?? '0'
      ) ?? transaction.price;
    }
  }

  Future<Map<String, dynamic>?> _getProductData(String buyerSkuCode) async {
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

        return product;
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
    
    return null;
  }

  bool _isPLNProduct(PPOBTransactionModel transaction) {
    final productName = transaction.productName.toUpperCase();
    final buyerSkuCode = transaction.buyerSkuCode?.toUpperCase() ?? '';
    
    return productName.contains('PLN') || 
           productName.contains('TOKEN') ||
           productName.contains('LISTRIK') ||
           buyerSkuCode.contains('PLN');
  }

  Future<bool> _isPLNPascabayar(String buyerSkuCode) async {
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

        if (product != null && product['type_name'] != null) {
          return product['type_name'].toString().toLowerCase() == 'pascabayar';
        }
      }
    } catch (e) {
      print('Error checking PLN type: $e');
    }
    
    return false;
  }

  String _extractPLNToken(String sn) {
    if (sn.isEmpty) return '';
    
    final parts = sn.split('/');
    if (parts.isNotEmpty) {
      return parts[0].trim();
    }
    return '';
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _autoRefreshPendingTransactions();
    });
  }

  void _stopAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  void _autoRefreshPendingTransactions() {
    if (!mounted) return;
    
    final pendingTransactions = transactions.where((t) => 
      t.status.toLowerCase() == 'pending' && 
      !_refreshingTransactions.contains(t.refId)
    ).toList();

    for (final transaction in pendingTransactions) {
      _refreshSingleTransaction(transaction, isAutoRefresh: true);
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

  Future<void> _refreshSingleTransaction(PPOBTransactionModel transaction, {bool isAutoRefresh = false}) async {
    if (_refreshingTransactions.contains(transaction.refId)) return;

    setState(() {
      _refreshingTransactions.add(transaction.refId);
    });

    try {
      final checkResponse = await http.post(
        Uri.parse('https://api.ditokoku.id/api/check-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_no': transaction.customerNo,
          'buyer_sku_code': transaction.buyerSkuCode ?? '',
          'ref_id': transaction.refId,
          'testing': false,
        }),
      );

      if (checkResponse.statusCode == 200) {
        final responseData = jsonDecode(checkResponse.body);
        
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

        if (newStatus != transaction.status.toUpperCase()) {
          print('🔄 Status changed from ${transaction.status} to $newStatus for ${transaction.refId}');
          
          final productData = await _getProductData(transaction.buyerSkuCode ?? '');
          final correctPrice = _getCorrectPriceForTransaction(transaction, productData);
          
          await _updateTransactionStatusInDatabase(
            refId: transaction.refId,
            status: newStatus,
            message: newMessage,
            sn: newSn,
            price: correctPrice,
          );

          // FLOW BARU
          if (newStatus == 'SUCCESS' || newStatus == 'SUKSES') {
            print('✅ Transaction SUCCESS - No action needed (already deducted)');
            
            // Hanya tambahkan loyalty points
            if (!_loyaltyPointsAdded.contains(transaction.refId)) {
              print('✅ Starting loyalty points process for ${transaction.refId}');
              try {
                print('📦 Getting nominal point for buyer_sku_code: ${transaction.buyerSkuCode}');
                final nominalPoint = await _getNominalPointFromProducts(transaction.buyerSkuCode ?? '');
                print('🎁 Nominal point retrieved: $nominalPoint');
                
                if (nominalPoint > 0) {
                  print('💎 Adding $nominalPoint loyalty points for ${transaction.refId}');
                  final loyaltyAdded = await _addLoyaltyPoints(
                    refId: transaction.refId,
                    nominalPoint: nominalPoint,
                  );
                  
                  print('🎉 Loyalty points added successfully: $loyaltyAdded');
                  
                  if (loyaltyAdded && !isAutoRefresh && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$nominalPoint loyalty points telah ditambahkan!'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  print('⚠️ Nominal point is 0 or negative, skipping loyalty points');
                }
              } catch (e) {
                print('❌ Error adding loyalty points: $e');
              }
            }
          } else if (newStatus == 'FAILED' || newStatus == 'GAGAL') {
            print('❌ Transaction FAILED - Refunding amount...');
            
            if (!_fundRefunded.contains(transaction.refId)) {
              print('💰 Refunding $correctPrice to wallet...');
              final refundSuccess = await _addFundToWallet(
                amount: correctPrice,
                refId: transaction.refId,
              );
              
              if (refundSuccess) {
                print('✅ Fund refunded successfully');
                
                if (!isAutoRefresh && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rp${PriceConverter.convertPrice(correctPrice)} telah dikembalikan ke saldo Anda'),
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
            final index = transactions.indexWhere((t) => t.refId == transaction.refId);
            if (index != -1) {
              final updatedTransaction = _createUpdatedTransaction(
                transactions[index], 
                newStatus, 
                newMessage, 
                newSn
              );
              transactions[index] = updatedTransaction;
            }
          });

          if (!isAutoRefresh && mounted) {
            String message = 'Status transaksi diperbarui: $newStatus';
            Color bgColor = Colors.orange;
            
            if (newStatus == 'SUCCESS' || newStatus == 'SUKSES') {
              message = 'Transaksi berhasil!';
              bgColor = Colors.green;
            } else if (newStatus == 'FAILED' || newStatus == 'GAGAL') {
              message = 'Transaksi gagal, saldo telah dikembalikan';
              bgColor = Colors.orange;
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 2),
                backgroundColor: bgColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!isAutoRefresh && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengecek status: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _refreshingTransactions.remove(transaction.refId);
        });
      }
    }
  }

  PPOBTransactionModel _createUpdatedTransaction(
    PPOBTransactionModel original,
    String newStatus,
    String? newMessage,
    String? newSn,
  ) {
    try {
      return PPOBTransactionModel.fromJson({
        'ref_id': original.refId,
        'product_name': original.productName,
        'category_name': original.categoryName,
        'brand_name': original.brandName,
        'customer_no': original.customerNo,
        'price': original.price,
        'status': newStatus,
        'message': newMessage ?? original.message,
        'sn': newSn ?? original.sn,
        'created_at': original.createdAt.toIso8601String(),
        'buyer_sku_code': original.buyerSkuCode,
      });
    } catch (e) {
      print('Error creating updated transaction: $e');
      return original;
    }
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
    double? price,
  }) async {
    try {
      final transaction = transactions.firstWhere(
        (t) => t.refId == refId,
        orElse: () => throw Exception('Transaction not found'),
      );

      int? userId;
      try {
        final profileController = Get.find<ProfileController>();
        userId = profileController.userInfoModel?.id;
      } catch (e) {
        print('Error getting user ID: $e');
        userId = 1;
      }

      final response = await http.put(
        Uri.parse('https://api.ditokoku.id/api/ppob/${transaction.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_no': transaction.customerNo,
          'buyer_sku_code': transaction.buyerSkuCode,
          'message': message ?? transaction.message,
          'status': status,
          'rc': status == 'SUCCESS' ? '00' : '01',
          'buyer_last_saldo': 0,
          'sn': sn ?? transaction.sn,
          'price': price ?? transaction.price,
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

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (hasMore && !isLoadingMore) {
        _loadMoreTransactions();
      }
    }
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    if (!AuthHelper.isLoggedIn()) {
      setState(() {
        isLoading = false;
        errorMessage = 'Silakan login terlebih dahulu';
      });
      return;
    }

    try {
      if (refresh) {
        setState(() {
          isLoading = true;
          errorMessage = null;
          currentPage = 0;
          hasMore = true;
          transactions.clear();
        });
      }

      final response = await TransactionService.getTransactionHistory(
        limit: pageSize,
        offset: currentPage * pageSize,
      );

      setState(() {
        if (response.success) {
          if (refresh) {
            transactions = response.transactions;
          } else {
            transactions.addAll(response.transactions);
          }
          hasMore = response.hasMore;
          if (refresh) currentPage = 1;
        } else {
          errorMessage = response.message ?? 'Gagal memuat transaksi';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await TransactionService.getTransactionHistory(
        limit: pageSize,
        offset: currentPage * pageSize,
      );

      setState(() {
        if (response.success) {
          transactions.addAll(response.transactions);
          hasMore = response.hasMore;
          currentPage++;
        }
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more: $e')),
      );
    }
  }

  List<PPOBTransactionModel> get filteredTransactions {
    return transactions.where((transaction) {
      bool statusMatch = selectedStatus == 'Semua' || 
          transaction.status.toLowerCase() == selectedStatus.toLowerCase();
      
      bool categoryMatch = selectedCategory == 'Semua' || 
          transaction.categoryName == selectedCategory;
      
      bool searchMatch = searchQuery.isEmpty ||
          transaction.productName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          transaction.customerNo.contains(searchQuery) ||
          transaction.refId.toLowerCase().contains(searchQuery.toLowerCase());
      
      return statusMatch && categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = filteredTransactions;
    final pendingCount = transactions.where((t) => t.status.toLowerCase() == 'pending').length;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semua Transaksi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (pendingCount > 0)
              Text(
                '$pendingCount transaksi pending (auto-refresh aktif)',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(
              _autoRefreshTimer != null ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (_autoRefreshTimer != null) {
                _stopAutoRefreshTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auto-refresh dihentikan'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                _startAutoRefreshTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auto-refresh diaktifkan'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              setState(() {});
            },
            tooltip: _autoRefreshTimer != null ? 'Pause auto-refresh' : 'Start auto-refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          
          if (selectedStatus != 'Semua' || selectedCategory != 'Semua')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Wrap(
                spacing: 8,
                children: [
                  if (selectedStatus != 'Semua')
                    FilterChip(
                      label: Text('Status: $selectedStatus'),
                      selected: true,
                      onSelected: (bool value) {},
                      onDeleted: () {
                        setState(() {
                          selectedStatus = 'Semua';
                        });
                      },
                    ),
                  if (selectedCategory != 'Semua')
                    FilterChip(
                      label: Text('Kategori: $selectedCategory'),
                      selected: true,
                      onSelected: (bool value) {},
                      onDeleted: () {
                        setState(() {
                          selectedCategory = 'Semua';
                        });
                      },
                    ),
                ],
              ),
              ),
          Expanded(
            child: isLoading
                ? _buildShimmerLoading()
                : errorMessage != null
                    ? _buildErrorState()
                    : filteredList.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => _loadTransactions(refresh: true),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredList.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == filteredList.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _buildTransactionCard(filteredList[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          color: Colors.white,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Terjadi kesalahan',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadTransactions(refresh: true),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaksi Anda akan muncul di sini',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PPOBTransactionModel transaction) {
    final isRefreshing = _refreshingTransactions.contains(transaction.refId);
    final isPending = transaction.status.toLowerCase() == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetail(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.categoryName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(transaction.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No. Pelanggan',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.customerNo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PriceConverter.convertPrice(transaction.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(transaction.createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  if (isPending)
                    TextButton.icon(
                      onPressed: isRefreshing
                          ? null
                          : () => _refreshSingleTransaction(transaction),
                      icon: isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh, size: 16),
                      label: Text(
                        isRefreshing ? 'Mengecek...' : 'Cek Status',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'success':
      case 'sukses':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        icon = Icons.schedule;
        break;
      case 'failed':
      case 'gagal':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Transaksi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: statusOptions.map((status) {
                      return ChoiceChip(
                        label: Text(status),
                        selected: selectedStatus == status,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedStatus = status;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kategori',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categoryOptions.map((category) {
                      return ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedStatus = 'Semua';
                      selectedCategory = 'Semua';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTransactionDetail(PPOBTransactionModel transaction) async {
    final isPLN = _isPLNProduct(transaction);
    final isPLNPascabayarResult = isPLN
        ? await _isPLNPascabayar(transaction.buyerSkuCode ?? '')
        : false;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Produk', transaction.productName),
                    _buildDetailRow('Kategori', transaction.categoryName),
                    _buildDetailRow('Brand', transaction.brandName),
                    _buildDetailRow('No. Pelanggan', transaction.customerNo),
                    _buildDetailRow(
                      'Harga',
                      PriceConverter.convertPrice(transaction.price),
                    ),
                    _buildDetailRow('Status', transaction.status.toUpperCase()),
                    _buildDetailRow('Ref ID', transaction.refId),
                    if (transaction.message.isNotEmpty)
                      _buildDetailRow('Pesan', transaction.message),
                    if (transaction.sn.isNotEmpty && !isPLNPascabayarResult)
                      _buildDetailRow(
                        isPLN ? 'Token Listrik' : 'Serial Number',
                        isPLN
                            ? _extractPLNToken(transaction.sn)
                            : transaction.sn,
                        copyable: true,
                      ),
                    _buildDetailRow(
                      'Tanggal',
                      _formatDate(transaction.createdAt),
                    ),
                    const SizedBox(height: 24),
                    if (transaction.status.toLowerCase() == 'pending')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _refreshSingleTransaction(transaction);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Cek Status Terbaru'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (copyable)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Disalin ke clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}