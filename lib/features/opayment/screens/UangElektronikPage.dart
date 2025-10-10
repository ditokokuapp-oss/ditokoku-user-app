import 'package:flutter/material.dart';
import 'EMoneyTopUpPage.dart';

class UangElektronikPage extends StatefulWidget {
  const UangElektronikPage({super.key});

  @override
  State<UangElektronikPage> createState() => _UangElektronikPageState();
}

class _UangElektronikPageState extends State<UangElektronikPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data untuk produk uang elektronik
  final List<Map<String, dynamic>> eMoneyProducts = [
    {
      'name': 'OVO',
      'logoPath': 'assets/image/ovo_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'DANA',
      'logoPath': 'assets/image/dana_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'GoPay',
      'logoPath': 'assets/image/gopay_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'ShopeePay',
      'logoPath': 'assets/image/shopeepay_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'LinkAja',
      'logoPath': 'assets/image/linkaja_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'i.Saku',
      'logoPath': 'assets/image/isaku_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'DOKU',
      'logoPath': 'assets/image/doku_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'KasPro',
      'logoPath': 'assets/image/kaspro_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'Sakuku',
      'logoPath': 'assets/image/sakuku_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'AstraPay',
      'logoPath': 'assets/image/astrapay_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'Gojek Driver',
      'logoPath': 'assets/image/gojek_driver_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'Grab Driver',
      'logoPath': 'assets/image/grab_customer_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'ShopeeFood Driver',
      'logoPath': 'assets/image/shopeefood_driver_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'Maxim',
      'logoPath': 'assets/image/maxim_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'Grab Customer',
      'logoPath': 'assets/image/grab_customer_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'M-Tix',
      'logoPath': 'assets/image/mtix_logo.png',
      'backgroundColor': Colors.white,
    },
    {
      'name': 'Mitra Tokopedia',
      'logoPath': 'assets/image/mitra_tokopedia_logo.jpeg',
      'backgroundColor': Colors.white,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return eMoneyProducts;
    }
    return eMoneyProducts.where((product) {
      final name = product['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
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
          'Uang Elektronik',
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
                hintText: 'Cari uang elektronik...',
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
                          'Uang elektronik tidak ditemukan',
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
                        return _buildEMoneyCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEMoneyCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EMoneyTopUpPage(
              providerName: product['name'],
              providerLogoPath: product['logoPath'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: product['backgroundColor'],
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
                    // Fallback if image is not found
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Product name
            Expanded(
              child: Text(
                product['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
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