import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'DaftarAgenPage.dart';
import 'package:sixam_mart/services/transaction_service.dart';
import 'SemuaProdukPage.dart';
import 'TopUpPage.dart';
import 'ETollPage.dart';
import 'VoucherPage.dart';
import 'PajakLayananPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/loyalty/screens/loyalty_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sixam_mart/features/home/widgets/ppob_banner_view.dart';
import 'PulsaDataPage.dart';
import 'UangElektronikPage.dart';
import 'PLNPage.dart';
import 'MultifinancePage.dart';

import 'GamesPage.dart';
import 'InternetTVPage.dart';
import 'PDAMPage.dart';
import 'AllTransactionPage.dart';
import 'PascabayarHPPage.dart';
import 'PascabayarTopUpPage.dart';
import 'TopUpHistoryPage.dart';

Future<void> _openWhatsapp() async {
  final Uri url = Uri.parse('https://wa.me/6285220082024');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Tidak bisa membuka $url';
  }
}

class DashboardOPayment extends StatefulWidget {
  const DashboardOPayment({super.key});

  @override
  State<DashboardOPayment> createState() => _DashboardOPaymentState();
}

class _DashboardOPaymentState extends State<DashboardOPayment> {
  List<PPOBTransactionModel> recentTransactions = [];
  bool isLoadingTransactions = true;
  String? transactionError;
  
  // Variabel untuk agen
  bool isLoadingAgen = true;
  String? namaKonter;
  bool isAgen = false;

  // Variabel untuk PPOB Menu <--- BARU DITAMBAH
  List<Map<String, dynamic>> ppobMenuItems = [];
  bool isLoadingMenu = true;

  // Auto-refresh variables
  Timer? _autoRefreshTimer;
  final Set<String> _refreshingTransactions = <String>{};
  final Set<String> _loyaltyPointsAdded = <String>{};
  final Set<String> _walletDeducted = <String>{};

  @override
  void initState() {
    super.initState();
    _loadRecentTransactions();
    _checkAgenStatus();
    _loadPPOBMenu(); // Load dynamic menu <--- BARU DITAMBAH
    _startAutoRefreshTimer();

     WidgetsBinding.instance.addPostFrameCallback((_) {
    print('🔵 DashboardOPayment - Loading PPOB banner...');
    try {
      final bannerController = Get.find<BannerController>();
      print('🔵 BannerController found: $bannerController');
      bannerController.getPpobBannerList(true);
    } catch (e, stackTrace) {
      print('❌ Error loading banner: $e');
      print('❌ StackTrace: $stackTrace');
    }
  });
  }


 


  @override
  void dispose() {
    _stopAutoRefreshTimer();
    super.dispose();
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _autoRefreshPendingTransactions();
    });
  }

  void _stopAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  // MARK: PPOB Menu Dynamic Fetch <--- BARU DITAMBAH
  Future<void> _loadPPOBMenu() async {
    setState(() {
      isLoadingMenu = true;
    });

    try {
      // Use the actual API URL
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/menu-ppob'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true && responseData['data'] is List) {
          final List<dynamic> menuData = responseData['data'];

          final List<dynamic> activeMenuData = menuData
              .where((item) => item['is_active'] == 1)
              .toList();


          setState(() {
            ppobMenuItems = activeMenuData.map((item) {
              final String iconUrl = item['icon_url'] ?? '';
              // Determine if it's a local asset (starts with 'assets/') or a network URL
              final bool isAsset = iconUrl.startsWith('assets/'); 
              
              return {
                'image': iconUrl,
                'label': item['label'],
                'route': item['route'],
                'isAsset': isAsset, // Pass the flag
              };
            }).toList();
          });
        } else {
          _setFallbackMenu();
        }
      } else {
        _setFallbackMenu();
      }
    } catch (e) {
      print('❌ Error loading PPOB menu: $e');
      _setFallbackMenu();
    } finally {
      setState(() {
        isLoadingMenu = false;
      });
    }
  }

  // Fallback if API call fails <--- BARU DITAMBAH
  void _setFallbackMenu() {
    setState(() {
      ppobMenuItems = [
        {'image': 'assets/image/pulsa_data_icon.png', 'label': 'Pulsa & Data', 'route': 'PulsaDataPage', 'isAsset': true},
        {'image': 'assets/image/pln_icon.png', 'label': 'Listrik PLN', 'route': 'PLNPage', 'isAsset': true},
        {'image': 'assets/image/internet_tv_icon.png', 'label': 'Internet & TV', 'route': 'InternetTVPage', 'isAsset': true},
        {'image': 'assets/image/emoney_icon.png', 'label': 'E-Wallet', 'route': 'UangElektronikPage', 'isAsset': true},
        {'image': 'assets/image/pdam_icon.png', 'label': 'PDAM', 'route': 'PDAMPage', 'isAsset': true},
        {'image': 'assets/image/game_icon.png', 'label': 'Game', 'route': 'GamesPage', 'isAsset': true},
        {'image': 'assets/image/bpjs_icon.png', 'label': 'BPJS', 'route': 'BPJSPage', 'isAsset': true},
        {'image': 'assets/image/pascabayar_icon.png', 'label': 'Pascabayar', 'route': 'PascabayarHPPage', 'isAsset': true},
        {'image': 'assets/image/asset-management.png', 'label': 'Multifinance', 'route': 'MultifinancePage', 'isAsset': true},
        {'image': 'assets/image/emoney.png', 'label': 'e-Money', 'route': 'ETollPage', 'isAsset': true},
        {'image': 'assets/image/taxes.png', 'label': 'Pajak dll', 'route': 'PajakLayananPage', 'isAsset': true},
        {'image': 'assets/image/voucher.png', 'label': 'Voucher', 'route': 'VoucherPage', 'isAsset': true},
      ];
    });
  }

  void _autoRefreshPendingTransactions() async {
    if (!mounted || !AuthHelper.isLoggedIn()) return;
    
    final pendingTransactions = recentTransactions.where((t) => 
      t.status.toLowerCase() == 'pending' && 
      !_refreshingTransactions.contains(t.refId)
    ).toList();

    // Batasi maksimal 3 transaksi per refresh cycle
    final transactionsToRefresh = pendingTransactions.take(3).toList();

    for (int i = 0; i < transactionsToRefresh.length; i++) {
      final transaction = transactionsToRefresh[i];
      await _refreshSingleTransaction(transaction);
      
      // Delay 1 detik antar request
      if (i < transactionsToRefresh.length - 1) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> _refreshSingleTransaction(PPOBTransactionModel transaction) async {
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
          
          // UPDATE STATUS KE DATABASE
          await _updateTransactionStatusInDatabase(
            transaction: transaction,
            newStatus: newStatus,
            newMessage: newMessage,
            newSn: newSn,
          );

          // PROSES TAMBAHAN JIKA STATUS SUCCESS
          if (newStatus == 'SUCCESS' || newStatus == 'SUKSES') {
            print('💰 Transaction SUCCESS - Processing loyalty points...');
            
            // Tambah Loyalty Points
            if (!_loyaltyPointsAdded.contains(transaction.refId)) {
              try {
                final nominalPoint = await _getNominalPointFromProducts(transaction.buyerSkuCode ?? '');
                
                if (nominalPoint > 0) {
                  await _addLoyaltyPoints(
                    refId: transaction.refId,
                    nominalPoint: nominalPoint,
                  );
                }
              } catch (e) {
                print('❌ Error adding loyalty points: $e');
              }
            }
          }
          
          // Reload transaksi
          await _loadRecentTransactions();
        }
      }
    } catch (e) {
      print('Error refreshing transaction: $e');
    } finally {
      if (mounted) {
        setState(() {
          _refreshingTransactions.remove(transaction.refId);
        });
      }
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
      print('Error fetching nominal point: $e');
    }
    
    return 10;
  }

  Future<bool> _addLoyaltyPoints({
    required String refId,
    required int nominalPoint,
  }) async {
    try {
      if (_loyaltyPointsAdded.contains(refId)) {
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
        return false;
      }

      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/loyalty/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "point": nominalPoint,
          "user_id": userId,
          "ref_id": refId,
          "source": "ppob_transaction",
          "type": "add"
        }),
      );

      if (response.statusCode == 200) {
        _loyaltyPointsAdded.add(refId);
        
        try {
          Get.find<ProfileController>().getUserInfo();
        } catch (e) {
          print('Error refreshing profile: $e');
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding loyalty points: $e');
      return false;
    }
  }

  Future<void> _updateTransactionStatusInDatabase({
    required PPOBTransactionModel transaction,
    required String newStatus,
    String? newMessage,
    String? newSn,
  }) async {
    try {
      int? userId;
      try {
        final profileController = Get.find<ProfileController>();
        userId = profileController.userInfoModel?.id;
      } catch (e) {
        userId = 1;
      }

      final response = await http.put(
        Uri.parse('https://api.ditokoku.id/api/ppob/${transaction.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_no': transaction.customerNo,
          'buyer_sku_code': transaction.buyerSkuCode,
          'message': newMessage ?? transaction.message,
          'status': newStatus,
          'rc': newStatus == 'SUCCESS' ? '00' : '01',
          'buyer_last_saldo': 0,
          'sn': newSn ?? transaction.sn,
          'price': transaction.price,
          'tele': '',
          'wa': '',
          'user_id': userId ?? 1,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Status updated in database');
      }
    } catch (e) {
      print('❌ Error updating status: $e');
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
      
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/users/agen/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && data['data'].isNotEmpty) {
          setState(() {
            isAgen = true;
            namaKonter = data['data'][0]['nama_konter'];
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
      setState(() {
        isAgen = false;
        isLoadingAgen = false;
      });
    }
  }

  Future<void> _loadRecentTransactions() async {
    if (!AuthHelper.isLoggedIn()) {
      setState(() {
        isLoadingTransactions = false;
      });
      return;
    }

    try {
      setState(() {
        isLoadingTransactions = true;
        transactionError = null;
      });

      final response = await TransactionService.getRecentTransactions();
      
      setState(() {
        if (response.success) {
          recentTransactions = response.transactions;
        } else {
          transactionError = response.message;
        }
        isLoadingTransactions = false;
      });
    } catch (e) {
      setState(() {
        transactionError = 'Gagal memuat transaksi: $e';
        isLoadingTransactions = false;
      });
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Login Diperlukan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black
          ),
        ),
        content: const Text(
          'Silakan login terlebih dahulu untuk menggunakan fitur ini',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
              if (AuthHelper.isLoggedIn()) {
                Get.find<ProfileController>().getUserInfo();
                _checkAgenStatus();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // OLD static menuItems list REMOVED here
    
    final List<Map<String, dynamic>> quickActions = [
      {'image': 'assets/image/isi_saldo_icon.png', 'label': 'Isi Saldo'},
      {'image': 'assets/image/poin_icon.png', 'label': 'Poin'},
      {'image': 'assets/image/riwayat_icon.png', 'label': 'Riwayat'},
      {'image': 'assets/image/bantuan_icon.png', 'label': 'Bantuan'},
    ];

    final pendingCount = recentTransactions.where((t) => t.status.toLowerCase() == 'pending').length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: GetBuilder<ProfileController>(
        builder: (profileController) {
          final bool isLoggedIn = AuthHelper.isLoggedIn();
          
          return RefreshIndicator(
            onRefresh: () async {
              await _loadRecentTransactions();
              await _checkAgenStatus();
              await _loadPPOBMenu(); // Refresh menu
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan saldo
                  _buildHeader(isLoggedIn, profileController),
                  
                  // Quick actions
                  _buildQuickActions(isLoggedIn, quickActions),
                  
                  const SizedBox(height: 24),

                  // Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: double.infinity,
                    child: const PpobBannerView(),
                  ),

                  const SizedBox(height: 24),

                  // Menu Grid
                  _buildMenuGrid(isLoggedIn), // Menggunakan data dinamis ppobMenuItems

                  const SizedBox(height: 24),

                  // Transaction header
                  _buildTransactionHeader(isLoggedIn, pendingCount),
                  
                  const SizedBox(height: 16),

                  // Transaction list
                  _buildTransactionList(isLoggedIn),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isLoggedIn, ProfileController profileController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset('assets/image/goback.png', width: 31, height: 31),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo Tersedia', style: robotoRegular.copyWith(fontSize: 14, color: Colors.black)),
                    const SizedBox(height: 2),
                    isLoggedIn && profileController.userInfoModel == null
                        ? Shimmer(child: Container(height: 30, width: 150, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))))
                        : Text(
                            isLoggedIn && profileController.userInfoModel != null
                                ? PriceConverter.convertPrice(profileController.userInfoModel!.walletBalance)
                                : 'Anda Belum Login',
                            style: robotoBold.copyWith(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Transform.translate(offset: const Offset(0, -15), child: Image.asset('assets/image/opaymentlogo.png', height: 47)),
                  if (isLoggedIn) Transform.translate(offset: const Offset(0, -18), child: _buildAgenBadge()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgenBadge() {
    if (isLoadingAgen) {
      return Shimmer(child: Container(width: 120, height: 25, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))));
    }
    
    if (isAgen && namaKonter != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(namaKonter!, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Image.asset('assets/image/verifiedagent.png', width: 18, height: 18),
          ],
        ),
      );
    }
    
    return Container(
      width: 140,
      height: 25,
      decoration: BoxDecoration(color: const Color(0xFF2F318B), borderRadius: BorderRadius.circular(4)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarAgenPage())),
          borderRadius: BorderRadius.circular(4),
          child: const Center(child: Text('Daftar Agen Platinum', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500))),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isLoggedIn, List<Map<String, dynamic>> quickActions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 19),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: quickActions.asMap().entries.map((entry) {
          int i = entry.key;
          var action = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i > 0 ? 20 : 0),
              child: _buildQuickAction(
                imagePath: action['image'],
                label: action['label'],
                onTap: () {
                  if (!isLoggedIn) {
                    _showLoginDialog();
                    return;
                  }
                  _handleQuickAction(action['label']);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickAction({required String imagePath, required String label, required VoidCallback onTap}) {
    double iconSize = label == 'Isi Saldo' ? 37 : (label == 'Poin' || label == 'Riwayat' ? 43 : 35);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          SizedBox(width: 39, height: 39, child: Center(child: Image.asset(imagePath, width: iconSize, height: iconSize, fit: BoxFit.contain))),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'Isi Saldo':
        Navigator.push(context, MaterialPageRoute(builder: (context) => TopUpPage()));
        break;
      case 'Poin':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoyaltyScreen(fromNotification: false)));
        break;
      case 'Riwayat':
        Navigator.push(context, MaterialPageRoute(builder: (context) => TopUpHistoryPage()));
        break;
      case 'Bantuan':
        _openWhatsapp();
        break;
    }
  }

  // MENGGANTIKAN _buildMenuGrid LAMA DENGAN VERSI DINAMIS + SHIMMER LOADING
  Widget _buildMenuGrid(bool isLoggedIn) {
    if (isLoadingMenu) {
      // Shimmer loading state for the grid
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.65,
          ),
          itemCount: 8, // Show a few shimmer items
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Shimmer(child: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle))),
                const SizedBox(height: 8),
                Shimmer(child: Container(width: 50, height: 10, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
              ],
            );
          },
        ),
      );
    }
    
    // Use dynamic ppobMenuItems
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 0.65,
        ),
        itemCount: ppobMenuItems.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final menuItem = ppobMenuItems[index];
          return _buildServiceItem(
            imagePath: menuItem['image'],
            label: menuItem['label'],
            isAsset: menuItem['isAsset'] ?? false, // <--- PASS isAsset FLAG
            onTap: () {
              if (!isLoggedIn) {
                _showLoginDialog();
                return;
              }
              _handleServiceNavigation(
                context, 
                menuItem['route'], 
                menuItem['image'], 
                menuItem['isAsset'] ?? false, // Pass image path and isAsset
              );
            },
          );
        },
      ),
    );
  }

  // MENGGANTIKAN _buildServiceItem LAMA DENGAN VERSI ASSET/NETWORK
  Widget _buildServiceItem({required String imagePath, required String label, required VoidCallback onTap, required bool isAsset}) {
    Widget iconWidget;
    
    if (isAsset) {
      // Use Image.asset for local assets
      iconWidget = Image.asset(
        imagePath, 
        width: 34, 
        height: 34, 
        fit: BoxFit.contain, 
        errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, color: Colors.grey[400], size: 20),
      );
    } else {
      // Use Image.network for URLs
      iconWidget = Image.network(
        imagePath, 
        width: 34, 
        height: 34, 
        fit: BoxFit.contain, 
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, color: Colors.grey[400], size: 20),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: iconWidget, // MENGGUNAKAN WIDGET ICON YANG SUDAH DIPILIH
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500, height: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  // MENGGANTIKAN _handleServiceNavigation LAMA DENGAN TAMBAHAN PARAMETER ICON
  void _handleServiceNavigation(BuildContext context, String route, String iconPath, bool isAsset) {
    Widget? page;
    
    switch (route) {
      case 'PulsaDataPage':
        page = const PulsaDataPage();
        break;
      case 'PLNPage':
        page = const PLNPage();
        break;
      case 'InternetTVPage':
        page = const InternetTVPage();
        break;
      case 'UangElektronikPage':
        page = const UangElektronikPage();
        break;
         case 'ETollPage':
        page = const ETollPage();
        break;
      case 'PDAMPage':
        page = const PDAMPage();
        break;
      case 'GamesPage':
        page = const GamesPage();
        break;
      case 'PascabayarHPPage':
        page = const PascabayarHPPage();
        break;
           case 'MultifinancePage':
        page = const MultifinancePage();
        break;
            case 'PajakLayananPage':
        page = const PajakLayananPage();
        break;
           case 'VoucherPage':
        page = const VoucherPage();
        break;
      case 'BPJSPage':
        // Jika rute adalah BPJS, gunakan PascabayarTopUpPage
        page = PascabayarTopUpPage(
          serviceName: 'BPJS Kesehatan',
          serviceDescription: 'Bayar BPJS Kesehatan',
          logoPath: iconPath, // Menggunakan path dinamis
          buyerSkuCode: 'BPJS',
          serviceType: 'bpjs',
          isNetworkIcon: !isAsset, // Menggunakan flag isAsset untuk menentukan isNetworkIcon
        );
        break;
    }
    
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
    }
  }

  Widget _buildTransactionHeader(bool isLoggedIn, int pendingCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Transaksi Terakhir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
              if (pendingCount > 0 && _autoRefreshTimer != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.autorenew, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('$pendingCount pending', style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          GestureDetector(
            onTap: () {
              if (!isLoggedIn) {
                _showLoginDialog();
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) => AllTransactionPage()));
            },
            child: Text('Lihat Semua', style: TextStyle(fontSize: 14, color: Colors.blue[600], fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(bool isLoggedIn) {
    if (!isLoggedIn) {
      return _buildEmptyState('Belum ada transaksi');
    }

    if (isLoadingTransactions) {
      return Column(children: List.generate(3, (index) => _buildTransactionShimmer()));
    }

    if (transactionError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(transactionError!, style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadRecentTransactions, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    if (recentTransactions.isEmpty) {
      return _buildEmptyState('Belum ada transaksi');
    }

    return Column(children: recentTransactions.map((transaction) => _buildTransactionItem(transaction)).toList());
  }

  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Center(child: Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500))),
    );
  }

  Widget _buildTransactionShimmer() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Shimmer(child: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer(child: Container(height: 16, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 8),
                Shimmer(child: Container(height: 14, width: 150, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
              ],
            ),
          ),
          Shimmer(child: Container(height: 16, width: 80, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
        ],
      ),
    );
  }

// Method untuk mengambil data produk dari API
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

// Method untuk mengambil harga yang benar berdasarkan status agen
Future<String> _getCorrectPrice(PPOBTransactionModel transaction) async {
  try {
    // Ambil data produk dari API
    final productData = await _getProductData(transaction.buyerSkuCode ?? '');
    
    if (productData == null) {
      return PriceConverter.convertPrice(transaction.price);
    }

    // Cek tipe produk
    String typeName = productData['type_name']?.toString().toLowerCase() ?? '';
    
    // Jika pascabayar, selalu gunakan price
    if (typeName == 'pascabayar') {
      double price = double.tryParse(productData['price']?.toString() ?? '0') ?? transaction.price;
      return PriceConverter.convertPrice(price);
    }
    
    // Jika bukan pascabayar, cek status agen
    if (isAgen) {
      // Agen menggunakan price
      double price = double.tryParse(productData['price']?.toString() ?? '0') ?? transaction.price;
      return PriceConverter.convertPrice(price);
    } else {
      // Non-agen menggunakan priceTierTwo, fallback ke price jika tidak ada
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

// Ganti method _buildTransactionItem dengan yang ini
Widget _buildTransactionItem(PPOBTransactionModel transaction) {
  final isPending = transaction.status.toLowerCase() == 'pending';
  final isRefreshing = _refreshingTransactions.contains(transaction.refId);

  return Container(
    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: isPending ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1) : null,
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Row(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: _getStatusColor(transaction.status), shape: BoxShape.circle),
              child: Icon(_getTransactionIcon(transaction.categoryName), color: Colors.white, size: 24),
            ),
            if (isPending && _autoRefreshTimer != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: isRefreshing
                      ? const SizedBox(width: 8, height: 8, child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Icon(Icons.autorenew, color: Colors.white, size: 8),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)),
              const SizedBox(height: 4),
              Text('${transaction.customerNo} • ${_formatDate(transaction.createdAt)}', style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: _getStatusColor(transaction.status).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(transaction.status.toUpperCase(), style: TextStyle(color: _getStatusColor(transaction.status), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        // Gunakan FutureBuilder untuk menampilkan harga yang benar
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
                fontSize: 13,
                color: Colors.black,
              ),
            );
          },
        ),
      ],
    ),
  );
}

  IconData _getTransactionIcon(String category) {
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

  Color _getStatusColor(String status) {
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

  String _formatDate(DateTime date) {
    final wibDate = date.toUtc().add(const Duration(hours: 7));
    final now = DateTime.now();
    final difference = now.difference(wibDate);
    
    if (difference.inDays == 0) {
      return 'Hari ini ';
    } else if (difference.inDays == 1) {
      return 'Kemarin ';
    } else {
      return '${wibDate.day}/${wibDate.month}/${wibDate.year} ';
    }
  }
}