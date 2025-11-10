import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'DaftarAgenPage.dart';

import 'PaymentDetailPage.dart';

class PLNTopUpPage extends StatefulWidget {
  final String serviceName;
  final String serviceDescription;
  final String logoPath;
  final String serviceType;

  const PLNTopUpPage({
    super.key,
    required this.serviceName,
    required this.serviceDescription,
    required this.logoPath,
    required this.serviceType,
  });

  @override
  State<PLNTopUpPage> createState() => _PLNTopUpPageState();
}

class _PLNTopUpPageState extends State<PLNTopUpPage> {
  final TextEditingController _idController = TextEditingController();
  List<dynamic> products = [];
  bool isLoading = false;
  bool isCheckingCustomer = false;
  Map<String, dynamic>? customerInfo;
  bool sortByLowestPrice = false;
  
  bool isAgen = false;
  bool isLoadingAgen = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _checkAgenStatus();
  }

  @override
  void dispose() {
    _idController.dispose();
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
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
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

  Color get serviceColor {
    return widget.serviceType == 'pascabayar' ? Colors.blue[700]! : Colors.orange[700]!;
  }

  String get inputHint {
    return widget.serviceType == 'pascabayar' 
      ? 'Masukan ID Pelanggan PLN'
      : 'Masukan Nomor Meter/Token';
  }

  String get inputLabel {
    return widget.serviceType == 'pascabayar' 
      ? 'ID Pelanggan'
      : 'Nomor Meter';
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
            return brandName == 'PLN';
          }).toList();
          
          if (sortByLowestPrice) {
            _sortProductsByPrice();
          }
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

  void _sortProductsByPrice() {
    products.sort((a, b) {
      double priceA = double.tryParse(isAgen ? (a['price'] ?? '0') : (a['priceTierTwo'] ?? a['price'] ?? '0')) ?? 0;
      double priceB = double.tryParse(isAgen ? (b['price'] ?? '0') : (b['priceTierTwo'] ?? b['price'] ?? '0')) ?? 0;
      return priceA.compareTo(priceB);
    });
  }

  void _togglePriceFilter() {
    setState(() {
      sortByLowestPrice = !sortByLowestPrice;
      if (sortByLowestPrice) {
        _sortProductsByPrice();
      } else {
        _fetchProducts();
      }
    });
  }

  Future<void> _checkCustomer() async {
    if (_idController.text.isEmpty) return;

    setState(() {
      isCheckingCustomer = true;
      customerInfo = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.ditokoku.id/api/pln/inquiry'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer_id': _idController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true && data['data'] != null) {
          setState(() {
            customerInfo = {
              'name': data['data']['name'] ?? data['data']['customer_name'] ?? 'Tidak tersedia',
              'address': data['data']['address'] ?? data['data']['customer_address'] ?? 'Tidak tersedia',
              'tariff': data['data']['tariff'] ?? data['data']['power'] ?? 'Tidak tersedia',
              'customer_id': _idController.text,
            };
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'] ?? 'Data pelanggan tidak ditemukan'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memeriksa data pelanggan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking customer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isCheckingCustomer = false;
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
            Text(
              widget.serviceName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                // Filter Harga Terendah
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _togglePriceFilter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Harga Terendah',
                          style: TextStyle(
                            color: sortByLowestPrice 
                              ? const Color(0xFF2F318B) 
                              : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.tune,
                          size: 16,
                          color: sortByLowestPrice 
                            ? const Color(0xFF2F318B) 
                            : Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    inputLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                                controller: _idController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: inputHint,
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
                                onChanged: (value) {
                                  if (value.length >= 11 && widget.serviceType == 'pascabayar') {
                                    _checkCustomer();
                                  }
                                },
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Image.asset(
                                widget.logoPath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: serviceColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.flash_on,
                                      size: 16,
                                      color: serviceColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (widget.serviceType == 'pascabayar') ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: isCheckingCustomer ? null : _checkCustomer,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x662F318B),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isCheckingCustomer
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(serviceColor),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  color: serviceColor,
                                  size: 24,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                if (customerInfo != null && widget.serviceType == 'pascabayar') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Data Pelanggan',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Nama: ${customerInfo!['name']}'),
                        Text('Alamat: ${customerInfo!['address']}'),
                        Text('Tarif: ${customerInfo!['tariff']}'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_off_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada produk ${widget.serviceName} tersedia',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
        if (widget.serviceType == 'pascabayar' && customerInfo == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan periksa data pelanggan terlebih dahulu'),
            ),
          );
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailPage(
              product: product,
              phoneNumber: _idController.text,
              provider: widget.serviceName,
              providerLogo: widget.logoPath,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 80, // ✅ Set fixed height 80
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0x332F318B),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Logo Provider
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 0),
                    child: Image.asset(
                      widget.logoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: serviceColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.flash_on,
                              size: 20,
                              color: serviceColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product['product_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                          maxLines: 2, // ✅ Allow 2 lines
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAgen 
                            ? _formatPrice(product['price'] ?? '0')
                            : _formatPrice(product['priceTierTwo'] ?? product['price'] ?? '0'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    margin: const EdgeInsets.only(right: 3),
                    color: Colors.grey[300],
                  ),
                  
                  // Poin
                  if (nominalPoint.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Text(
                        nominalPoint,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFB800),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Divider
                  Container(
                    width: 1,
                    height: 40,
                    margin: const EdgeInsets.only(left: 3, right: 5),
                    color: Colors.grey[300],
                  ),
                  
                  // Harga Agen Platinum dengan Text untuk Agen
                  if (isAgen)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Anda mendapatkan harga\nagen platinum',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text "Harga Agen Platinum" di kanan
                          const Text(
                            'Harga Agen Platinum',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFAFAFB2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Harga dan Icon dalam 1 baris
                          Row(
                            children: [
                              Text(
                                _formatPrice(product['price'] ?? '0'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFAFAFB2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DaftarAgenPage(),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/image/verifiedblue.png',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2F318B),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2F318B).withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Text info di bawah card
          if (!isAgen)
            const Padding(
              padding: EdgeInsets.only(bottom: 8, right: 4),
              child: Text(
                '*Klik di icon centang biru untuk daftar agen platinum',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}