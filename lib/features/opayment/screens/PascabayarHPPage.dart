import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'PascabayarTopUpPage.dart';

class PascabayarHPPage extends StatefulWidget {
  const PascabayarHPPage({super.key});

  @override
  State<PascabayarHPPage> createState() => _PascabayarHPPageState();
}

class _PascabayarHPPageState extends State<PascabayarHPPage> {
  List<dynamic> hpPascabayarProducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHPPascabayarProducts();
  }

  Future<void> _fetchHPPascabayarProducts() async {
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
          // Filter products based on brand_name HP Pascabayar
          hpPascabayarProducts = allProducts.where((product) {
            String brandName = product['brand_name'].toString().toUpperCase();
            return brandName == 'HP PASCABAYAR';
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching HP Pascabayar products: $e');
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

  Map<String, dynamic> _getProviderInfo(String productName) {
    String productNameUpper = productName.toUpperCase();
    
    if (productNameUpper.contains('HALO') || productNameUpper.contains('TELKOMSEL')) {
      return {
        'name': 'Kartu Halo Postpaid',
        'description': 'Bayar tagihan Kartu Halo bulanan',
        'logoPath': 'assets/image/telkomsel_logo.png',
        'backgroundColor': Colors.white,
        'iconColor': Colors.red[600],
        'icon': Icons.phone,
        'buyerSkuCode': 'postgdrrrz',
      };
    } else if (productNameUpper.contains('INDOSAT') || productNameUpper.contains('IM3')) {
      return {
        'name': 'Indosat Postpaid',
        'description': 'Bayar tagihan Indosat bulanan',
        'logoPath': 'assets/image/indosat_logo.png',
        'backgroundColor': Colors.white,
        'iconColor': Colors.yellow[700],
        'icon': Icons.phone,
        'buyerSkuCode': 'indosat_pascabayar',
      };
    } else if (productNameUpper.contains('XL')) {
      return {
        'name': 'XL Postpaid',
        'description': 'Bayar tagihan XL bulanan',
        'logoPath': 'assets/image/xl_logo.png',
        'backgroundColor': Colors.white,
        'iconColor': Colors.blue[700],
        'icon': Icons.phone,
        'buyerSkuCode': 'postdaaaax',
      };
    } else if (productNameUpper.contains('THREE') || productNameUpper.contains('TRI')) {
      return {
        'name': 'Three Postpaid',
        'description': 'Bayar tagihan Three bulanan',
        'logoPath': 'assets/image/three_logo.png',
        'backgroundColor': Colors.white,
        'iconColor': Colors.purple[600],
        'icon': Icons.phone,
        'buyerSkuCode': 'three_pascabayar',
      };
    }
    
    // Default untuk provider lain
    return {
      'name': 'Kartu Halo Postpaid',
      'description': 'Bayar tagihan HP bulanan',
      'logoPath': 'assets/image/telkomsel_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.red[600],
      'icon': Icons.phone,
      'buyerSkuCode': 'hp_pascabayar',
    };
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
              'Pasca Bayar HP',
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
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (hpPascabayarProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_disabled_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada produk HP Pascabayar tersedia',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group products by provider untuk menghindari duplikasi
    Map<String, Map<String, dynamic>> uniqueProviders = {};
    for (var product in hpPascabayarProducts) {
      var providerInfo = _getProviderInfo(product['product_name'] ?? '');
      String providerKey = providerInfo['name'];
      if (!uniqueProviders.containsKey(providerKey)) {
        uniqueProviders[providerKey] = providerInfo;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.separated(
        itemCount: uniqueProviders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final providerInfo = uniqueProviders.values.elementAt(index);
          return _buildHPPascabayarCard(providerInfo);
        },
      ),
    );
  }

  Widget _buildHPPascabayarCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PascabayarTopUpPage(
              serviceName: product['name'],
              serviceDescription: product['description'],
              logoPath: product['logoPath'],
              buyerSkuCode: product['buyerSkuCode'],
              serviceColor: product['iconColor'],
              serviceType: 'hp_pascabayar',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            // Logo container with icon overlay
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Provider Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      product['logoPath'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.phone,
                            color: product['iconColor'],
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}