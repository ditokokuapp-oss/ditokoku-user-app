import 'package:flutter/material.dart';
import 'ETollPageTopUpPage.dart'; // Ganti import ini

class ETollPage extends StatefulWidget {
  const ETollPage({super.key});

  @override
  State<ETollPage> createState() => _ETollPageState();
}

class _ETollPageState extends State<ETollPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data untuk produk E-Money
  final List<Map<String, dynamic>> emoneyProducts = [
    {
      'name': 'MANDIRI E-TOLL',
      'description': 'Top up saldo e-Toll Mandiri',
      'logoPath': 'assets/image/mandiri_etoll_logo.png',
      'buyerSkuCode': 'mandiri_etoll',
      'iconColor': Colors.blue[700],
      'icon': Icons.toll,
    },
    {
      'name': 'BRIZZI',
      'description': 'Top up saldo Brizzi BRI',
      'logoPath': 'assets/image/brizzi_logo.png',
      'buyerSkuCode': 'brizzi',
      'iconColor': Colors.blue[900],
      'icon': Icons.credit_card,
    },
    {
      'name': 'BNI TapCash',
      'description': 'Top up saldo TapCash BNI',
      'logoPath': 'assets/image/bni_tapcash_logo.png',
      'buyerSkuCode': 'bni_tapcash',
      'iconColor': Colors.orange[700],
      'icon': Icons.contactless,
    },
    {
      'name': 'BCA Flazz',
      'description': 'Top up saldo Flazz BCA',
      'logoPath': 'assets/image/bca_flazz_logo.png',
      'buyerSkuCode': 'bca_flazz',
      'iconColor': Colors.blue[800],
      'icon': Icons.nfc,
    },
    {
      'name': 'Bank DKI JakCard',
      'description': 'Top up saldo JakCard Bank DKI',
      'logoPath': 'assets/image/jakcard_logo.jpg',
      'buyerSkuCode': 'jakcard',
      'iconColor': Colors.red[700],
      'icon': Icons.credit_card_outlined,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return emoneyProducts;
    }
    return emoneyProducts.where((product) {
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
          'E-Money',
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
                hintText: 'Cari e-money...',
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
                          'E-Money tidak ditemukan',
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
                        return _buildEmoneyCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmoneyCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        // Navigate to ETollPageTopUpPage - FIXED
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ETollPageTopUpPage(
              serviceName: product['name'],
              serviceDescription: product['description'],
              logoPath: product['logoPath'],
              buyerSkuCode: product['buyerSkuCode'],
              serviceColor: product['iconColor'],
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
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
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        product['icon'],
                        color: product['iconColor'],
                        size: 24,
                      ),
                    );
                  },
                ),
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