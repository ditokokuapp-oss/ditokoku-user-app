import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'PinVerificationPage.dart';
import 'PinVerificationModal.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TopUpPage.dart';

class PaymentDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final String phoneNumber;
  final String provider;
  final String? providerLogo;

  const PaymentDetailPage({
    super.key,
    required this.product,
    required this.phoneNumber,
    required this.provider,
    this.providerLogo, 
  });

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  bool isAgen = false;
  bool isLoadingAgen = true;
  double minSaldo = 10000; // Default min saldo
  bool isLoadingConfig = true;

  // Computed property untuk cek apakah semua loading sudah selesai
  bool get isAllDataLoaded => !isLoadingConfig && !isLoadingAgen;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Fetch kedua API secara paralel
    await Future.wait([
      _fetchConfigPrice(),
      _checkAgenStatus(),
    ]);
  }

  Future<void> _fetchConfigPrice() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/config-price'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          setState(() {
            minSaldo = double.parse(jsonData['data']['min_saldo']);
            isLoadingConfig = false;
          });
        } else {
          throw Exception('Failed to load config price');
        }
      } else {
        throw Exception('Failed to load config price');
      }
    } catch (e) {
      print('Error fetching config price: $e');
      setState(() {
        isLoadingConfig = false;
      });
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

  String _getPrice() {
    String typeName = widget.product['type_name']?.toString().toLowerCase() ?? '';
    
    // Jika pascabayar, selalu gunakan price
    if (typeName == 'pascabayar') {
      return widget.product['price']?.toString() ?? '0';
    }
    
    // Jika bukan pascabayar, cek status agen
    if (isAgen) {
      // Agen menggunakan price
      return widget.product['price']?.toString() ?? '0';
    } else {
      // Non-agen menggunakan priceTierTwo, fallback ke price jika tidak ada
      return widget.product['priceTierTwo']?.toString() ?? 
             widget.product['price']?.toString() ?? '0';
    }
  }

  String _formatPrice(String price) {
    double priceDouble = double.tryParse(price) ?? 0;
    return 'Rp${priceDouble.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}';
  }

  bool _isSaldoCukup(double walletBalance) {
    double productPrice = double.tryParse(_getPrice()) ?? 0;
    
    // Jika agen, cek apakah saldo cukup untuk transaksi + min_saldo
    if (isAgen) {
      double sisaSaldo = walletBalance - productPrice;
      return sisaSaldo >= minSaldo;
    }
    
    // Jika bukan agen, cek hanya apakah saldo cukup untuk transaksi
    return walletBalance >= productPrice;
  }

  void _showInsufficientBalanceDialog(BuildContext context, double walletBalance) {
    double productPrice = double.tryParse(_getPrice()) ?? 0;
    
    String title;
    String message;
    double kekurangan;
    
    if (isAgen) {
      double sisaSetelahTransaksi = walletBalance - productPrice;
      if (sisaSetelahTransaksi < minSaldo) {
        title = 'Saldo Minimum Agen';
        message = 'Sebagai agen, Anda harus menyisakan minimal ${_formatPrice(minSaldo.toString())} setelah transaksi.';
        kekurangan = (productPrice + minSaldo) - walletBalance;
      } else {
        title = 'Saldo Tidak Cukup';
        message = 'Saldo Anda tidak mencukupi untuk melakukan transaksi ini.';
        kekurangan = productPrice - walletBalance;
      }
    } else {
      title = 'Saldo Tidak Cukup';
      message = 'Saldo Anda tidak mencukupi untuk melakukan transaksi ini.';
      kekurangan = productPrice - walletBalance;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo Anda:', style: TextStyle(fontSize: 14, color: Colors.black)),
                        Text(
                          PriceConverter.convertPrice(walletBalance),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran:', style: TextStyle(fontSize: 14, color: Colors.black)),
                        Text(
                          _formatPrice(_getPrice()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (isAgen) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Min. Saldo Agen:', style: TextStyle(fontSize: 14, color: Colors.black)),
                          Text(
                            _formatPrice(minSaldo.toString()),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAgen ? 'Saldo Dibutuhkan:' : 'Kekurangan:', 
                          style: const TextStyle(fontSize: 14, color: Colors.black)
                        ),
                        Text(
                          isAgen 
                            ? _formatPrice((productPrice + minSaldo).toString())
                            : _formatPrice(kekurangan.toString()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Nanti',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TopUpPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF396EB0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Isi Saldo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPinModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinVerificationModal(
        product: widget.product,
        phoneNumber: widget.phoneNumber,
        provider: widget.provider,
        providerLogo: widget.providerLogo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String productPrice = _formatPrice(_getPrice());
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            GetBuilder<ProfileController>(
              builder: (profileController) {
                final double walletBalance = 
                    profileController.userInfoModel?.walletBalance ?? 0;
                final bool saldoCukup = _isSaldoCukup(walletBalance);
                
                return Container(
                  constraints: const BoxConstraints.expand(),
                  color: const Color(0xFFFFFFFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 24, bottom: 32),
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 16),
                                        width: 32,
                                        height: 32,
                                        child: Image.asset(
                                          'assets/image/goback.png',
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Text(
                                        "Pembayaran",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF222222),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32)
                                  ],
                                ),
                              ),
                              
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFF2F318B),
                                ),
                                margin: const EdgeInsets.only(bottom: 24),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 20, bottom: 16, left: 20),
                                      child: const Text(
                                        "Detail Pembayaran",
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF0F2FF),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRowWithDivider(
                                            'Nama Produk', 
                                            widget.product['product_name'] ?? '-', 
                                            showDivider: true
                                          ),
                                          
                                          _buildDetailRowWithDivider(
                                            'Nomor Pelanggan', 
                                            widget.phoneNumber, 
                                            showDivider: true
                                          ),
                                          
                                          _buildDetailRow('Harga', productPrice),
                                          
                                          _buildDetailRow('Biaya Admin', 'Gratis!', isGreen: true),
                                          
                                          _buildDetailRowWithDivider(
                                            'Keterangan', 
                                            widget.provider, 
                                            showDivider: true, 
                                            addVerticalMargin: true
                                          ),
                                          
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  "Total Pembayaran",
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  productPrice,
                                                  style: const TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              InkWell(
                                onTap: () {
                                  print('Saldo tapped');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFEBF3FF),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Saldo Anda",
                                        style: TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        PriceConverter.convertPrice(walletBalance),
                                        style: const TextStyle(
                                          color: Color(0xFF2F318B),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Info Min Saldo untuk Agen - hanya tampil jika data sudah load
                              if (isAllDataLoaded && isAgen)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.orange[50],
                                    border: Border.all(color: Colors.orange[200]!),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 32),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Sebagai agen, Anda harus menyisakan minimal ${_formatPrice(minSaldo.toString())} setelah transaksi',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[900],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (!isAllDataLoaded)
                                const SizedBox(height: 16)
                              else
                                const SizedBox(height: 16),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom button section - hanya tampil jika semua data sudah load
                      if (isAllDataLoaded)
                        Container(
                          color: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                width: double.infinity,
                                child: const Text(
                                  "Selanjutnya anda akan diarahkan untuk memasukkan PIN/Password untuk melanjutkan transaksi.",
                                  style: TextStyle(
                                    color: Color(0xFF808080),
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              InkWell(
                                onTap: () {
                                  if (saldoCukup) {
                                    _showPinModal(context);
                                  } else {
                                    _showInsufficientBalanceDialog(context, walletBalance);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: saldoCukup ? const Color(0xFF2F318B) : Colors.grey[400],
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x0D14142B),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  width: double.infinity,
                                  child: Text(
                                    saldoCukup ? "Bayar Sekarang" : "SALDO TIDAK CUKUP",
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            
            // Loading Overlay - Block semua interaksi sampai API selesai
            if (!isAllDataLoaded)
              Container(
                color: Colors.white.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F318B)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Memuat data...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isGreen = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            value,
            style: TextStyle(
              color: isGreen ? const Color(0xFF72A677) : const Color(0xFF000000),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithDivider(String label, String value, {bool showDivider = false, bool addVerticalMargin = false}) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            bottom: showDivider ? 12 : 8,
            top: addVerticalMargin ? 4 : 0,
          ),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            color: const Color(0xFFD9D9D9),
            margin: EdgeInsets.only(
              bottom: addVerticalMargin ? 16 : 12,
            ),
            height: 1,
            width: double.infinity,
          ),
      ],
    );
  }
}