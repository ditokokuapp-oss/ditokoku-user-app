import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

import 'PaymentDetailPage.dart';

class GameTopUpPage extends StatefulWidget {
  final String gameName;
  final String gameDescription;
  final String logoPath;
  final String gameId;

  const GameTopUpPage({
    super.key,
    required this.gameName,
    required this.gameDescription,
    required this.logoPath,
    required this.gameId,
  });

  @override
  State<GameTopUpPage> createState() => _GameTopUpPageState();
}

class _GameTopUpPageState extends State<GameTopUpPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _zoneIdController = TextEditingController();
  List<dynamic> products = [];
  bool isLoading = false;
  
  bool isAgen = false;
  bool isLoadingAgen = true;

  final Map<String, Map<String, dynamic>> gameInfo = {
    'freefire': {
      'color': Colors.orange[700],
      'backgroundColor': Color(0xFFFF6B35),
      'requiresZoneId': false,
      'userIdLabel': 'User ID',
      'userIdHint': 'Masukan User ID Free Fire',
      'currency': 'Diamond',
    },
    'mobilelegends': {
      'color': Colors.blue[700],
      'backgroundColor': Color(0xFF1565C0),
      'requiresZoneId': true,
      'userIdLabel': 'User ID',
      'zoneIdLabel': 'Zone ID',
      'userIdHint': 'Masukan User ID Mobile Legends',
      'zoneIdHint': 'Masukan Zone ID',
      'currency': 'Diamond',
    },
    'pubgmobile': {
      'color': Colors.yellow[800],
      'backgroundColor': Color(0xFFFFB300),
      'requiresZoneId': false,
      'userIdLabel': 'User ID',
      'userIdHint': 'Masukan User ID PUBG Mobile',
      'currency': 'UC',
    },
    'garena': {
      'color': Colors.green[700],
      'backgroundColor': Color(0xFF2E7D32),
      'requiresZoneId': false,
      'userIdLabel': 'User ID',
      'userIdHint': 'Masukan User ID Garena',
      'currency': 'Shell',
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
    _userIdController.dispose();
    _zoneIdController.dispose();
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

  Map<String, dynamic> get currentGameInfo {
    return gameInfo[widget.gameId] ?? gameInfo['freefire']!;
  }

  Color get gameColor {
    return currentGameInfo['color'] ?? Colors.blue[700]!;
  }

  Color get gameBackgroundColor {
    return currentGameInfo['backgroundColor'] ?? Colors.blue[700]!;
  }

  bool get requiresZoneId {
    return currentGameInfo['requiresZoneId'] ?? false;
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
            return brandName == widget.gameName.toUpperCase() || 
                   brandName.contains(widget.gameName.toUpperCase());
          }).toList();
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

  String _getCombinedUserId() {
    if (requiresZoneId && _zoneIdController.text.isNotEmpty) {
      return '${_userIdController.text}(${_zoneIdController.text})';
    }
    return _userIdController.text;
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
              'Top Up ${widget.gameName}',
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
                Container(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Image.asset(
                      widget.logoPath,
                      width: 101,
                      height: 101,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.sports_esports,
                          size: 60,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentGameInfo['userIdLabel'] ?? 'User ID',
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
                          controller: _userIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: currentGameInfo['userIdHint'],
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
                        child: Image.asset(
                          widget.logoPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: gameColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.sports_esports,
                                size: 16,
                                color: gameColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (requiresZoneId) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currentGameInfo['zoneIdLabel'] ?? 'Zone ID',
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
                    child: TextFormField(
                      controller: _zoneIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: currentGameInfo['zoneIdHint'],
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
                ],
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
              Icons.sports_esports_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada produk ${widget.gameName} tersedia',
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
        if (_userIdController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silakan masukan ${currentGameInfo['userIdLabel']} terlebih dahulu'),
            ),
          );
          return;
        }
        
        if (requiresZoneId && _zoneIdController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silakan masukan ${currentGameInfo['zoneIdLabel']} terlebih dahulu'),
            ),
          );
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailPage(
              product: product,
              phoneNumber: _getCombinedUserId(),
              provider: widget.gameName,
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
                    child: Image.asset(
                      widget.logoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: gameColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.sports_esports,
                              size: 12,
                              color: gameColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    widget.gameName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: gameColor,
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
                    color: gameColor,
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
                          'Harga Agen ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatPrice(product['price'] ?? '0'),
                          style: const TextStyle(
                            fontSize: 11,
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