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
            child: _buildTransactionList(filteredList),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<PPOBTransactionModel> filteredList) {
    if (!AuthHelper.isLoggedIn()) {
      return _buildEmptyState(
        icon: Icons.login,
        title: 'Silakan Login',
        subtitle: 'Login untuk melihat riwayat transaksi',
        showButton: true,
        buttonText: 'Login',
        onButtonPressed: () {},
      );
    }

    if (isLoading && transactions.isEmpty) {
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => _buildTransactionShimmer(),
      );
    }

    if (errorMessage != null && transactions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Oops!',
        subtitle: errorMessage!,
        showButton: true,
        buttonText: 'Coba Lagi',
        onButtonPressed: () => _loadTransactions(refresh: true),
      );
    }

    if (filteredList.isEmpty && transactions.isNotEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: 'Tidak Ada Hasil',
        subtitle: 'Tidak ditemukan transaksi sesuai filter',
        showButton: true,
        buttonText: 'Reset Filter',
        onButtonPressed: () {
          setState(() {
            selectedStatus = 'Semua';
            selectedCategory = 'Semua';
            searchQuery = '';
            _searchController.clear();
          });
        },
      );
    }

    if (filteredList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum Ada Transaksi',
        subtitle: 'Transaksi Anda akan muncul di sini',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTransactions(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredList.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredList.length) {
            return _buildLoadingMore();
          }
          
          return _buildTransactionItem(filteredList[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (showButton && buttonText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildTransactionShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Shimmer(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(
                  child: Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer(
                  child: Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer(
                  child: Container(
                    height: 20,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Shimmer(
            child: Container(
              height: 16,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(PPOBTransactionModel transaction) {
    final isPending = transaction.status.toLowerCase() == 'pending';
    final isRefreshing = _refreshingTransactions.contains(transaction.refId);

    IconData getTransactionIcon(String category) {
      switch (category.toLowerCase()) {
        case 'pulsa':
          return Icons.smartphone;
        case 'data':
          return Icons.wifi;
        case 'pln':
        case 'listrik':
          return Icons.bolt;
        case 'game':
          return Icons.sports_esports;
        default:
          return Icons.receipt;
      }
    }

    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'success':
        case 'sukses':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'failed':
        case 'gagal':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String formatDate(DateTime date) {
      final adjustedDate = date.add(const Duration(hours: 9));
      
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      return '${adjustedDate.day} ${months[adjustedDate.month - 1]} ${adjustedDate.year} ${adjustedDate.hour.toString().padLeft(2, '0')}:${adjustedDate.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPending ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTransactionDetail(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: getStatusColor(transaction.status),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            getTransactionIcon(transaction.categoryName),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        if (isPending)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  transaction.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              if (isPending && _autoRefreshTimer != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'AUTO',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.customerNo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(transaction.createdAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FutureBuilder<String>(
                          future: _getCorrectPrice(transaction),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            
                            return Text(
                              snapshot.data ?? PriceConverter.convertPrice(transaction.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(transaction.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                transaction.status.toUpperCase(),
                                style: TextStyle(
                                  color: getStatusColor(transaction.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isPending) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: isRefreshing ? null : () => _refreshSingleTransaction(transaction),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: isRefreshing
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.refresh,
                                          color: Colors.blue,
                                          size: 12,
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (transaction.message.isNotEmpty && transaction.message != transaction.productName) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      transaction.message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: statusOptions.map((status) {
                      return FilterChip(
                        label: Text(status),
                        selected: selectedStatus == status,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedStatus = status;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categoryOptions.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              selectedStatus = 'Semua';
                              selectedCategory = 'Semua';
                            });
                            setState(() {
                              selectedStatus = 'Semua';
                              selectedCategory = 'Semua';
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _getCorrectPrice(PPOBTransactionModel transaction) async {
    try {
      final productData = await _getProductData(transaction.buyerSkuCode ?? '');
      
      if (productData == null) {
        return PriceConverter.convertPrice(transaction.price);
      }

      String typeName = productData['type_name']?.toString().toLowerCase() ?? '';
      
      if (typeName == 'pascabayar') {
        double price = double.tryParse(productData['price']?.toString() ?? '0') ?? transaction.price;
        return PriceConverter.convertPrice(price);
      }
      
      if (isAgen) {
        double price = double.tryParse(productData['price']?.toString() ?? '0') ?? transaction.price;
        return PriceConverter.convertPrice(price);
      } else {
        double price = double.tryParse(
          productData['priceTierTwo']?.toString() ?? 
          productData['price']?.toString() ?? '0'
        ) ?? transaction.price;
        return PriceConverter.convertPrice(price);
      }
    } catch (e) {
      print('Error getting correct price: $e');
      return PriceConverter.convertPrice(transaction.price);
    }
  }

  void _showTransactionDetail(PPOBTransactionModel transaction) async {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'success':
        case 'sukses':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'failed':
        case 'gagal':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    final isPLN = _isPLNProduct(transaction);
    final isPascabayar = isPLN ? await _isPLNPascabayar(transaction.buyerSkuCode ?? '') : false;
    final showPLNToken = isPLN && !isPascabayar && transaction.status.toLowerCase() == 'sukses';
    final plnToken = showPLNToken ? _extractPLNToken(transaction.sn) : '';
    
    final correctPrice = await _getCorrectPrice(transaction);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            bool isCopied = false;
            
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detail Transaksi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (transaction.status.toLowerCase() == 'pending')
                                IconButton(
                                  onPressed: () => _refreshSingleTransaction(transaction),
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.blue[600],
                                  ),
                                  tooltip: 'Refresh Status',
                                ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: getStatusColor(transaction.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  transaction.status.toUpperCase(),
                                  style: TextStyle(
                                    color: getStatusColor(transaction.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              _buildDetailRow('ID Transaksi', transaction.refId),
                              _buildDetailRow('Produk', transaction.productName),
                              _buildDetailRow('Kategori', transaction.categoryName),
                              _buildDetailRow('Brand', transaction.brandName),
                              _buildDetailRow('Nomor Pelanggan', transaction.customerNo),
                              _buildDetailRow('Harga', correctPrice),
                              _buildDetailRow('Waktu Transaksi', 
                                () {
                                  final adjustedDate = transaction.createdAt.add(const Duration(hours: 9));
                                  return '${adjustedDate.day}/${adjustedDate.month}/${adjustedDate.year} ${adjustedDate.hour.toString().padLeft(2, '0')}:${adjustedDate.minute.toString().padLeft(2, '0')}';
                                }()),
                              
                              if (transaction.sn.isNotEmpty && !showPLNToken) 
                                _buildDetailRow('Serial Number', transaction.sn),
                              
                              if (transaction.message.isNotEmpty)
                                _buildDetailRow('Pesan', transaction.message),
                              
                              if (showPLNToken && plnToken.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
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
                                              plnToken,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF000000),
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: plnToken));
                                              
                                              setModalState(() {
                                                isCopied = true;
                                              });
                                              
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text('Token PLN berhasil disalin'),
                                                    ],
                                                  ),
                                                  duration: const Duration(seconds: 2),
                                                  backgroundColor: Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                  margin: const EdgeInsets.all(16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                              
                                              Future.delayed(const Duration(milliseconds: 500), () {
                                                if (context.mounted) {
                                                  setModalState(() {
                                                    isCopied = false;
                                                  });
                                                }
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isCopied 
                                                    ? Colors.green 
                                                    : const Color(0xFFFFA726),
                                                borderRadius: BorderRadius.circular(6),
                                                boxShadow: isCopied
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.green.withOpacity(0.4),
                                                          spreadRadius: 2,
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ]
                                                    : [],
                                              ),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 200),
                                                child: Icon(
                                                  isCopied ? Icons.check : Icons.copy,
                                                  key: ValueKey<bool>(isCopied),
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}