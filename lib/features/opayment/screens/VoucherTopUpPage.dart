import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

import 'PaymentDetailPage.dart';

class VoucherTopUpPage extends StatefulWidget {
  final String voucherName;
  final String voucherDescription;
  final String logoPath;
  final String voucherId;
  final bool isNetwork;

  const VoucherTopUpPage({
    super.key,
    required this.voucherName,
    required this.voucherDescription,
    required this.logoPath,
    required this.voucherId,
    this.isNetwork = false,
  });

  @override
  State<VoucherTopUpPage> createState() => _VoucherTopUpPageState();
}

class _VoucherTopUpPageState extends State<VoucherTopUpPage> {
  final TextEditingController _phoneController = TextEditingController();
  List<dynamic> products = [];
  bool isLoading = false;
  
  bool isAgen = false;
  bool isLoadingAgen = true;

  final Map<String, Map<String, dynamic>> voucherInfo = {
    'telkomsel': {
      'color': Colors.red[700],
      'backgroundColor': Color(0xFFD32F2F),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor Telkomsel',
    },
    'indosat': {
      'color': Colors.yellow[800],
      'backgroundColor': Color(0xFFFFB300),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor Indosat',
    },
    'xl': {
      'color': Colors.blue[700],
      'backgroundColor': Color(0xFF1565C0),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor XL',
    },
    'axis': {
      'color': Colors.purple[700],
      'backgroundColor': Color(0xFF6A1B9A),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor Axis',
    },
    'smartfren': {
      'color': Colors.pink[700],
      'backgroundColor': Color(0xFFC2185B),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor Smartfren',
    },
    'tri': {
      'color': Colors.orange[700],
      'backgroundColor': Color(0xFFE64A19),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor 3 (Tri)',
    },
    'byu': {
      'color': Colors.teal[700],
      'backgroundColor': Color(0xFF00897B),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor By.U',
    },
    'alfamart': {
      'color': Colors.blue[800],
      'backgroundColor': Color(0xFF0D47A1),
      'requiresPhone': false,
      'phoneLabel': 'Email / Nomor HP',
      'phoneHint': 'Masukan email atau nomor HP',
    },
    'indomaret': {
      'color': Colors.red[700],
      'backgroundColor': Color(0xFFD32F2F),
      'requiresPhone': false,
      'phoneLabel': 'Email / Nomor HP',
      'phoneHint': 'Masukan email atau nomor HP',
    },
    'spotify': {
      'color': Colors.green[700],
      'backgroundColor': Color(0xFF1DB954),
      'requiresPhone': false,
      'phoneLabel': 'Email Spotify',
      'phoneHint': 'Masukan email Spotify',
    },
    'pointblank': {
      'color': Colors.orange[900],
      'backgroundColor': Color(0xFFE65100),
      'requiresPhone': false,
      'phoneLabel': 'User ID',
      'phoneHint': 'Masukan User ID Point Blank',
    },
    'grab': {
      'color': Colors.green[700],
      'backgroundColor': Color(0xFF00B14F),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor HP terdaftar Grab',
    },
    'kopikenangan': {
      'color': Colors.brown[700],
      'backgroundColor': Color(0xFF5D4037),
      'requiresPhone': true,
      'phoneLabel': 'Nomor Telepon',
      'phoneHint': 'Masukan nomor HP',
    },
    'visionplus': {
      'color': Colors.purple[700],
      'backgroundColor': Color(0xFF6A1B9A),
      'requiresPhone': false,
      'phoneLabel': 'Email / Nomor HP',
      'phoneHint': 'Masukan email atau nomor HP',
    },
    'vidio': {
      'color': Colors.red[700],
      'backgroundColor': Color(0xFFD32F2F),
      'requiresPhone': false,
      'phoneLabel': 'Email / Nomor HP',
      'phoneHint': 'Masukan email atau nomor HP',
    },
    'wetv': {
      'color': Colors.orange[700],
      'backgroundColor': Color(0xFFFF6B35),
      'requiresPhone': false,
      'phoneLabel': 'Email / Nomor HP',
      'phoneHint': 'Masukan email atau nomor HP',
    },
    'ematerai': {
      'color': Colors.blue[900],
      'backgroundColor': Color(0xFF0D47A1),
      'requiresPhone': false,
      'phoneLabel': 'Email',
      'phoneHint': 'Masukan email untuk e-Materai',
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _checkAgenStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
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

  Map<String, dynamic> get currentVoucherInfo {
    return voucherInfo[widget.voucherId] ?? {
      'color': Colors.blue[700],
      'backgroundColor': Color(0xFF1565C0),
      'requiresPhone': false,
      'phoneLabel': 'Email / Nomor HP',
      'phoneHint': 'Masukan email atau nomor HP',
    };
  }

  Color get voucherColor {
    return currentVoucherInfo['color'] ?? Colors.blue[700]!;
  }

  Color get voucherBackgroundColor {
    return currentVoucherInfo['backgroundColor'] ?? Colors.blue[700]!;
  }

  bool get requiresPhone {
    return currentVoucherInfo['requiresPhone'] ?? false;
  }

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> allProducts = json.decode(response.body);
        
        setState(() {
          products = allProducts.where((product) {
            String brandName = product['brand_name'].toString().toUpperCase();
            String voucherNameUpper = widget.voucherName.toUpperCase();
            String buyerSkuCode = product['buyer_sku_code'].toString().toLowerCase();
            
            // List provider telco yang perlu filter dengan SKU "voc"
            List<String> telcoProviders = ['TELKOMSEL', 'XL', 'INDOSAT', 'TRI', 'SMARTFREN', 'AXIS'];
            
            // Cek apakah voucher ini adalah provider telco
            bool isTelcoProvider = telcoProviders.any((provider) => 
              voucherNameUpper.contains(provider) || voucherNameUpper == provider
            );
            
            // Special handling untuk nama brand yang berbeda
            if (voucherNameUpper == 'TRI') {
              isTelcoProvider = true;
              // Cek brand dengan "3" atau "TRI"
              bool brandMatches = brandName == '3' || brandName == 'TRI' || brandName.contains('TRI');
              if (isTelcoProvider) {
                return brandMatches && buyerSkuCode.startsWith('voc');
              }
              return brandMatches;
            }
            
            if (voucherNameUpper == 'BY.U') {
              return brandName == 'BYU' || brandName == 'BY.U' || brandName.contains('BY');
            }
            
            // Filter berdasarkan brand name
            bool brandMatches = brandName == voucherNameUpper || 
                                brandName.contains(voucherNameUpper);
            
            // Jika provider telco, tambahkan filter SKU harus dimulai dengan "voc"
            if (isTelcoProvider) {
              return brandMatches && buyerSkuCode.startsWith('voc');
            }
            
            // Untuk non-telco, hanya cek brand name
            return brandMatches;
          }).toList();
          
          print('=== Found ${products.length} products for ${widget.voucherName} ===');
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatPrice(String price) {
    double priceDouble = double.tryParse(price) ?? 0;
    return 'Rp${priceDouble.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/image/goback.png',
                  width: 31,
                  height: 31,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                widget.voucherName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Image.network(
                      widget.logoPath,
                      width: 101,
                      height: 101,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          widget.isNetwork ? Icons.sim_card : Icons.card_giftcard,
                          size: 60,
                          color: Colors.grey,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            voucherColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentVoucherInfo['phoneLabel'] ?? 'Email / Nomor HP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0x662F318B),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: widget.isNetwork || requiresPhone 
                              ? TextInputType.phone 
                              : TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: currentVoucherInfo['phoneHint'],
                            hintStyle: const TextStyle(
                              color: Color(0xFFBAB0B0),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.network(
                          widget.logoPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: voucherColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                widget.isNetwork ? Icons.sim_card : Icons.card_giftcard,
                                size: 16,
                                color: voucherColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isNetwork ? Icons.sim_card_outlined : Icons.card_giftcard_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada produk ${widget.voucherName} tersedia',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    String nominalPoint = '';
    if (product['nominal_point'] != null) {
      double? pointValue = double.tryParse(product['nominal_point'].toString());
      if (pointValue != null) {
        nominalPoint = '${pointValue.toInt()} Poin';
      } else {
        nominalPoint = '${product['nominal_point']} Poin';
      }
    }

    return GestureDetector(
      onTap: () {
        if (_phoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silakan masukan ${currentVoucherInfo['phoneLabel']} terlebih dahulu'),
            ),
          );
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailPage(
              product: product,
              phoneNumber: _phoneController.text,
              provider: widget.voucherName,
              providerLogo: widget.logoPath,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0x662F318B),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    child: Image.network(
                      widget.logoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: voucherColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Icon(
                              widget.isNetwork ? Icons.sim_card : Icons.card_giftcard,
                              size: 12,
                              color: voucherColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Flexible(
                    child: Text(
                      widget.voucherName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: voucherColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Text(
                product['product_name'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              
              if (nominalPoint.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  nominalPoint,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 0),
              
              if (isAgen) ...[
                Text(
                  _formatPrice(product['price'] ?? '0'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: voucherColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Column(
                  children: [
                    Text(
                      _formatPrice(product['priceTierTwo'] ?? product['price'] ?? '0'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Harga Agen Platinum ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatPrice(product['price'] ?? '0'),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}