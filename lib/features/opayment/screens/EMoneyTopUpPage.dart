import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'DaftarAgenPage.dart';

import 'PaymentDetailPage.dart';

class EMoneyTopUpPage extends StatefulWidget {
  final String providerName;
  final String providerLogoPath;
  final String buyerSkuCode; // Tambahkan parameter ini

  const EMoneyTopUpPage({
    super.key,
    required this.providerName,
    required this.providerLogoPath,
    required this.buyerSkuCode, // Tambahkan di constructor
  });

  @override
  State<EMoneyTopUpPage> createState() => _EMoneyTopUpPageState();
}

class _ContactPickerDialog extends StatefulWidget {
  final List<Contact> contacts;

  const _ContactPickerDialog({required this.contacts});

  @override
  State<_ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<_ContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts = widget.contacts.where((contact) {
          final nameLower = contact.displayName.toLowerCase();
          final phoneNumber = contact.phones.isNotEmpty 
              ? contact.phones.first.number.replaceAll(RegExp(r'[^\d]'), '') 
              : '';
          final queryLower = query.toLowerCase();
          
          return nameLower.contains(queryLower) || phoneNumber.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Kontak'),
      contentPadding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau nomor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterContacts('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _filterContacts,
              ),
            ),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredContacts.length} kontak',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: _filteredContacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada kontak ditemukan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        final phoneNumber = contact.phones.isNotEmpty 
                            ? contact.phones.first.number 
                            : '';
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              contact.displayName.isNotEmpty 
                                  ? contact.displayName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          title: Text(
                            contact.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            phoneNumber,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(contact);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}


class _EMoneyTopUpPageState extends State<EMoneyTopUpPage> {
  final TextEditingController _phoneController = TextEditingController();
  List<dynamic> products = [];
  bool isLoading = false;
  bool sortByLowestPrice = false;
  
  bool isAgen = false;
  bool isLoadingAgen = true;

  final Map<String, Map<String, dynamic>> providerInfo = {
    'gopay': {
      'displayName': 'Go Pay',
      'color': Colors.green,
      'backgroundColor': Color(0xFF00AA5B),
    },
    'ovo': {
      'displayName': 'OVO',
      'color': Colors.purple,
      'backgroundColor': Color(0xFF4C3494),
    },
    'shopeepay': {
      'displayName': 'Shopee Pay',
      'color': Colors.orange,
      'backgroundColor': Color(0xFFEE4D2D),
    },
    'linkaja': {
      'displayName': 'LinkAja',
      'color': Colors.red,
      'backgroundColor': Color(0xFFE53E3E),
    },
    'dana': {
      'displayName': 'DANA',
      'color': Colors.blue,
      'backgroundColor': Color(0xFF118EEA),
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

  String get displayProviderName {
    String providerKey = widget.providerName.toLowerCase().replaceAll(' ', '');
    return providerInfo[providerKey]?['displayName'] ?? widget.providerName;
  }

  Color get providerColor {
    String providerKey = widget.providerName.toLowerCase().replaceAll(' ', '');
    return providerInfo[providerKey]?['color'] ?? Colors.blue;
  }

  Color get providerBackgroundColor {
    String providerKey = widget.providerName.toLowerCase().replaceAll(' ', '');
    return providerInfo[providerKey]?['backgroundColor'] ?? Colors.blue;
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
        
        // Get buyer_sku_code prefix from buyerSkuCode (tanpa angka di belakang)
        String skuPrefix = widget.buyerSkuCode.toLowerCase();
        // Remove trailing numbers if any (contoh: gopay_topup10 -> gopay_topup)
        skuPrefix = skuPrefix.replaceAll(RegExp(r'\d+$'), '');
        
        print('=== Filtering E-Money products with SKU prefix: $skuPrefix ===');
        
        setState(() {
          products = allProducts.where((product) {
            String buyerSkuCode = product['buyer_sku_code'].toString().toLowerCase();
            
            // Check if buyerSkuCode starts with the prefix
            bool matches = buyerSkuCode.startsWith(skuPrefix);
            
            if (matches) {
              print('Matched: $buyerSkuCode for prefix: $skuPrefix');
            }
            
            return matches;
          }).toList();
          
          if (sortByLowestPrice) {
            _sortProductsByPrice();
          }
          
          print('=== Found ${products.length} products for ${widget.providerName} (SKU: $skuPrefix) ===');
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

  Future<void> _pickContact() async {
    try {
      final PermissionStatus permissionStatus = await Permission.contacts.status;
      
      if (permissionStatus.isGranted) {
        final List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        if (contacts.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada kontak ditemukan')),
            );
          }
          return;
        }

        final Contact? selectedContact = await showDialog<Contact>(
          context: context,
          builder: (BuildContext context) {
            return _ContactPickerDialog(contacts: contacts);
          },
        );

        if (selectedContact != null && selectedContact.phones.isNotEmpty) {
          String phoneNumber = selectedContact.phones.first.number;
          
          phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
          
          if (phoneNumber.startsWith('+62')) {
            phoneNumber = '0${phoneNumber.substring(3)}';
          } else if (phoneNumber.startsWith('62')) {
            phoneNumber = '0${phoneNumber.substring(2)}';
          }
          
          setState(() {
            _phoneController.text = phoneNumber;
          });
        }
      } else {
        final PermissionStatus newStatus = await Permission.contacts.request();
        
        if (newStatus.isGranted) {
          _pickContact();
        } else if (newStatus.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Silakan berikan izin akses kontak di pengaturan aplikasi'),
                action: SnackBarAction(
                  label: 'Pengaturan',
                  onPressed: openAppSettings,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Izin akses kontak diperlukan untuk fitur ini'),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memilih kontak: $e')),
        );
      }
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
              'Top Up $displayProviderName',
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
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Masukan Nomor Telepon',
                    style: TextStyle(
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
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '08xxxxxx',
                                  hintStyle: TextStyle(
                                    color: Color(0xFFBAB0B0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0),
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
                                widget.providerLogoPath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: providerColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      size: 16,
                                      color: providerColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _pickContact,
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
                          child: Image.asset(
                            'assets/image/bookuser.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.contacts,
                                color: Colors.blue[600],
                                size: 24,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada produk $displayProviderName tersedia',
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailPage(
              product: product,
              phoneNumber: _phoneController.text,
              provider: displayProviderName,
              providerLogo: widget.providerLogoPath,
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
                      widget.providerLogoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: providerColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              displayProviderName.substring(0, 1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: providerColor,
                              ),
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
                  
                  // Harga Agen Platinum
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