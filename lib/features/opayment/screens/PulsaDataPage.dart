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

import 'PaymentDetailPage.dart';

class PulsaDataPage extends StatefulWidget {
  const PulsaDataPage({super.key});

  @override
  State<PulsaDataPage> createState() => _PulsaDataPageState();
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
            // Search bar
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
            
            // Contact count
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
            
            // Contact list
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


class _PulsaDataPageState extends State<PulsaDataPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController();
  String selectedProvider = '';
  List<dynamic> products = [];
  List<dynamic> pulsaProducts = [];
  List<dynamic> dataProducts = [];
  bool isLoading = false;
  
  // Variabel untuk status agen
  bool isAgen = false;
  bool isLoadingAgen = true;

  // Provider detection mapping
  final Map<String, List<String>> providerPrefixes = {
    'TELKOMSEL': ['0811', '0812', '0813', '0821', '0822', '0823', '0851', '0852', '0853'],
    'INDOSAT': ['0814', '0815', '0816', '0855', '0856', '0857', '0858', '0895', '0896', '0897', '0898', '0899'],
    'XL': ['0817', '0818', '0819', '0859', '0877', '0878', '0831', '0832', '0833', '0838'],
    'SMARTFREN': ['0881', '0882', '0883', '0884', '0885', '0886', '0887', '0888', '0889'],
    'TRI': ['0895', '0896', '0897', '0898', '0899'],
  };

  // Provider info with images and initials
  final Map<String, Map<String, String>> providerInfo = {
    'TELKOMSEL': {
      'image': 'assets/image/telkomsel_logo.png',
      'initial': 'T-SEL',
      'color': 'red'
    },
    'INDOSAT': {
      'image': 'assets/image/indosat_logo.png', 
      'initial': 'ISAT',
      'color': 'yellow'
    },
    'XL': {
      'image': 'assets/image/xl_logo.png',
      'initial': 'XL',
      'color': 'blue'
    },
    'SMARTFREN': {
      'image': 'assets/image/smartfren_logo.png',
      'initial': 'SMART',
      'color': 'pink'
    },
    'TRI': {
      'image': 'assets/image/tri_logo.png',
      'initial': 'TRI',
      'color': 'purple'
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _phoneController.text = '';
    _checkAgenStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  String _detectProvider() {
    String phone = _phoneController.text;
    if (phone.length >= 4) {
      String prefix = phone.substring(0, 4);
      for (String provider in providerPrefixes.keys) {
        if (providerPrefixes[provider]!.contains(prefix)) {
          setState(() {
            selectedProvider = provider;
          });
          return provider;
        }
      }
    }
    setState(() {
      selectedProvider = '';
    });
    return '';
  }

  Future<void> _fetchProducts() async {
    if (_phoneController.text.trim().isEmpty || _phoneController.text.trim().length < 10) {
      setState(() {
        products = [];
        pulsaProducts = [];
        dataProducts = [];
        isLoading = false;
      });
      return;
    }

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
          products = allProducts.where((product) => 
            selectedProvider.isEmpty || 
            product['brand_name'].toString().toUpperCase() == selectedProvider
          ).toList();
          
          pulsaProducts = products.where((product) => 
            product['category_name'].toString().toLowerCase().contains('pulsa')
          ).toList();
          
          dataProducts = products.where((product) => 
            product['category_name'].toString().toLowerCase().contains('data')
          ).toList();
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
        
        _detectProvider();
        _fetchProducts();
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

  Color _getProviderColor(String provider) {
    switch (provider) {
      case 'TELKOMSEL':
        return Colors.red;
      case 'INDOSAT':
        return Colors.orange;
      case 'XL':
        return Colors.blue;
      case 'SMARTFREN':
        return Colors.pink;
      case 'TRI':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  bool _isPhoneNumberValid() {
    return _phoneController.text.trim().length >= 10;
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
            const Text(
              'Pulsa & Data',
              style: TextStyle(
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
                      'assets/image/mobiledatanew.png',
                      width: 101,
                      height: 101,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.smartphone,
                          size: 60,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
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
                                  hintText: '08xxxxxxx',
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
                                onChanged: (value) {
                                  _detectProvider();
                                  _fetchProducts();
                                },
                              ),
                            ),

                            if (selectedProvider.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Image.asset(
                                  providerInfo[selectedProvider]!['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: _getProviderColor(selectedProvider).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.signal_cellular_alt,
                                        size: 16,
                                        color: _getProviderColor(selectedProvider),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
          
          if (_isPhoneNumberValid()) ...[
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue[600],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[600],
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'Pulsa'),
                  Tab(text: 'Data'),
                ],
              ),
            ),
          ],
          
          Expanded(
            child: !_isPhoneNumberValid()
              ? _buildEmptyState()
              : isLoading 
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductGrid(pulsaProducts),
                      _buildProductGrid(dataProducts),
                    ],
                  ),
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
          Icon(
            Icons.smartphone_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Silakan Masukan Nomor Telepon untuk\nmelihat produk pulsa dan data',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<dynamic> productList) {
    if (productList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              selectedProvider.isNotEmpty 
                ? 'Tidak ada produk tersedia untuk $selectedProvider'
                : 'Tidak ada produk tersedia',
              textAlign: TextAlign.center,
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
      itemCount: productList.length,
      itemBuilder: (context, index) {
        final product = productList[index];
        return _buildProductCard(product);
      },
    );
  }

Widget _buildProductCard(dynamic product) {
  String productName = product['product_name'] ?? '';
  String categoryName = product['category_name']?.toString().toLowerCase() ?? '';
  String mainValue = '';
  String unit = '';
  bool isDataProduct = categoryName.contains('data');
  
  // Jika produk Data, tampilkan semua product_name
  if (isDataProduct) {
    mainValue = productName;
    unit = '';
  } else {
    // Untuk Pulsa, lakukan parsing seperti biasa
    RegExp regExp = RegExp(r'(\d+(?:\.\d+)?)\s*(GB|MB|Poin|Point)?', caseSensitive: false);
    Match? match = regExp.firstMatch(productName);
    
    if (match != null) {
      mainValue = match.group(1) ?? '';
      unit = match.group(2)?.toUpperCase() ?? '';
      
      // Handle conversion for MB to GB if needed
      if (mainValue.isNotEmpty && unit == 'MB') {
        double? numValue = double.tryParse(mainValue);
        if (numValue != null && numValue >= 1000) {
          mainValue = (numValue / 1000).toString().replaceAll('.0', '');
          unit = 'GB';
        }
      }
    } else {
      mainValue = productName;
    }
  }
  
  String nominalPoint = '';
  if (product['nominal_point'] != null) {
    double? pointValue = double.tryParse(product['nominal_point'].toString());
    if (pointValue != null) {
      nominalPoint = '${pointValue.toInt()} Poin';
    } else {
      nominalPoint = '${product['nominal_point']} Poin';
    }
  }
  
  Color unitColor = Colors.orange;
  String unitText = unit;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetailPage(
            product: product,
            phoneNumber: _phoneController.text,
            provider: selectedProvider,
            providerLogo: providerInfo[selectedProvider]!['image'],
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
            if (selectedProvider.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      providerInfo[selectedProvider]!['image']!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getProviderColor(selectedProvider)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              providerInfo[selectedProvider]!['initial']!
                                  .substring(0, 1),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getProviderColor(selectedProvider),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    selectedProvider,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _getProviderColor(selectedProvider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // Display product name/value
            if (isDataProduct) ...[
              // Untuk Data: tampilkan full product name dengan font lebih kecil
              Text(
                mainValue,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              // Untuk Pulsa: tampilkan nilai dengan unit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    mainValue,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (unitText.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unitText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: unitColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            
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
            
            const SizedBox(height: 12),
            
            // Price section based on agent status
            if (isAgen) ...[
              Text(
                _formatPrice(product['price'] ?? '0'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedProvider.isNotEmpty
                      ? _getProviderColor(selectedProvider)
                      : Colors.red,
                ),
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
                  const SizedBox(height: 4),
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