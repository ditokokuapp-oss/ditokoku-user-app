import 'package:flutter/material.dart';
import 'PascabayarTopUpPage.dart';

class InternetTVPage extends StatefulWidget {
  const InternetTVPage({super.key});

  @override
  State<InternetTVPage> createState() => _InternetTVPageState();
}

class _InternetTVPageState extends State<InternetTVPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data untuk produk Internet & TV Kabel
  final List<Map<String, dynamic>> internetTVProducts = [
    {
      'name': 'IndiHome',
      'description': 'Speedy & IndiHome Internet',
      'logoPath': 'assets/image/indihome_logo.png',
      'buyerSkuCode': 'indihome',
    },
    {
      'name': 'Biznet Home',
      'description': 'Bayar tagihan Biznet Home',
      'logoPath': 'assets/image/biznethome_logo.png',
      'buyerSkuCode': 'biznethome',
    },
    {
      'name': 'First Media',
      'description': 'First Media Internet',
      'logoPath': 'assets/image/firstmedia_logo.png',
      'buyerSkuCode': 'firstmedia_internet',
    },
    {
      'name': 'CBN Fiber',
      'description': 'Bayar tagihan CBN Fiber',
      'logoPath': 'assets/image/cbn_logo.jpg',
      'buyerSkuCode': 'cbnfiber',
    },
    {
      'name': 'XL Home',
      'description': 'Bayar tagihan XL Home',
      'logoPath': 'assets/image/xlhome_logo.png',
      'buyerSkuCode': 'xlhome',
    },
    {
      'name': 'MyRepublic',
      'description': 'Bayar tagihan MyRepublic',
      'logoPath': 'assets/image/myrepublic_logo.png',
      'buyerSkuCode': 'myrepublic',
    },
    {
      'name': 'ICONNET',
      'description': 'PLN Icon Plus Internet',
      'logoPath': 'assets/image/iconnet_logo.png',
      'buyerSkuCode': 'iconnet',
    },
    {
      'name': 'K-Vision',
      'description': 'K-Vision & GOL TV',
      'logoPath': 'assets/image/kvision_logo.png',
      'buyerSkuCode': 'kvision',
    },
    {
      'name': 'Nex Parabola',
      'description': 'Bayar tagihan Nex Parabola',
      'logoPath': 'assets/image/nexparabola_logo.png',
      'buyerSkuCode': 'nexparabola',
    },
    {
      'name': 'Matrix',
      'description': 'Matrix TV Voucher',
      'logoPath': 'assets/image/matrix_logo.png',
      'buyerSkuCode': 'matrix',
    },
    {
      'name': 'Tanaka',
      'description': 'Tanaka TV Voucher',
      'logoPath': 'assets/image/tanaka_logo.png',
      'buyerSkuCode': 'tanaka',
    },
    {
      'name': 'TransVision',
      'description': 'TransVision Voucher',
      'logoPath': 'assets/image/transvision_logo.png',
      'buyerSkuCode': 'transvision_voucher',
    },
    {
      'name': 'Kawan K-Vision',
      'description': 'Kawan K-Vision TV',
      'logoPath': 'assets/image/kawankvision_logo.jpeg',
      'buyerSkuCode': 'kawankvision',
    },
    {
      'name': 'Jawara Vision',
      'description': 'Bayar tagihan Jawara Vision',
      'logoPath': 'assets/image/jawaravision_logo.jpeg',
      'buyerSkuCode': 'jawaravision',
    },
    {
      'name': 'First Media TV',
      'description': 'First Media TV Kabel',
      'logoPath': 'assets/image/firstmedia_logo.png',
      'buyerSkuCode': 'firstmedia_tv',
    },
    {
      'name': 'Telkomvision',
      'description': 'Telkomvision / Transvision',
      'logoPath': 'assets/image/telkomvision_logo.png',
      'buyerSkuCode': 'telkomvision',
    },
    {
      'name': 'K-Vision Pascabayar',
      'description': 'K-Vision Pascabayar',
      'logoPath': 'assets/image/jawaravision_logo.jpeg',
      'buyerSkuCode': 'kvision_pascabayar',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return internetTVProducts;
    }
    return internetTVProducts.where((product) {
      final name = product['name'].toString().toLowerCase();
      final description = product['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/image/goback.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Internet & TV Kabel',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari provider internet atau TV...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Product List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Provider tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView.separated(
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildInternetTVCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternetTVCard(Map<String, dynamic> product) {
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
              serviceType: 'internet',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo container
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product['logoPath'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.wifi,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  );
                },
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