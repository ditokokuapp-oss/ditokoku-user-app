import 'package:flutter/material.dart';
import 'PascabayarTopUpPage.dart';

class PDAMPage extends StatefulWidget {
  const PDAMPage({super.key});

  @override
  State<PDAMPage> createState() => _PDAMPageState();
}

class _PDAMPageState extends State<PDAMPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data untuk produk PDAM
  final List<Map<String, dynamic>> pdamProducts = [
    {
      'name': 'PDAM DKI Jakarta',
      'description': 'Bayar tagihan air PDAM Jakarta',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_jakarta',
    },
    {
      'name': 'PDAM Banten',
      'description': 'Bayar tagihan air PDAM Banten',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_banten',
    },
    {
      'name': 'PDAM Jawa Barat',
      'description': 'Bayar tagihan air PDAM Jawa Barat',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_jabar',
    },
    {
      'name': 'PDAM Jawa Tengah',
      'description': 'Bayar tagihan air PDAM Jawa Tengah',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_jateng',
    },
    {
      'name': 'PDAM DI Yogyakarta',
      'description': 'Bayar tagihan air PDAM Yogyakarta',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_yogyakarta',
    },
    {
      'name': 'PDAM Jawa Timur',
      'description': 'Bayar tagihan air PDAM Jawa Timur',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_jatim',
    },
    {
      'name': 'PDAM Bali',
      'description': 'Bayar tagihan air PDAM Bali',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_bali',
    },
    {
      'name': 'PDAM Nusa Tenggara Barat',
      'description': 'Bayar tagihan air PDAM NTB',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_ntb',
    },
    {
      'name': 'PDAM Nusa Tenggara Timur',
      'description': 'Bayar tagihan air PDAM NTT',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_ntt',
    },
    {
      'name': 'PDAM Aceh',
      'description': 'Bayar tagihan air PDAM Aceh',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_aceh',
    },
    {
      'name': 'PDAM Sumatera Utara',
      'description': 'Bayar tagihan air PDAM Sumut',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sumut',
    },
    {
      'name': 'PDAM Sumatera Barat',
      'description': 'Bayar tagihan air PDAM Sumbar',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sumbar',
    },
    {
      'name': 'PDAM Riau',
      'description': 'Bayar tagihan air PDAM Riau',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_riau',
    },
    {
      'name': 'PDAM Kepulauan Riau',
      'description': 'Bayar tagihan air PDAM Kepri',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_kepri',
    },
    {
      'name': 'PDAM Jambi',
      'description': 'Bayar tagihan air PDAM Jambi',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_jambi',
    },
    {
      'name': 'PDAM Bengkulu',
      'description': 'Bayar tagihan air PDAM Bengkulu',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_bengkulu',
    },
    {
      'name': 'PDAM Sumatera Selatan',
      'description': 'Bayar tagihan air PDAM Sumsel',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sumsel',
    },
    {
      'name': 'PDAM Bangka Belitung',
      'description': 'Bayar tagihan air PDAM Babel',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_babel',
    },
    {
      'name': 'PDAM Lampung',
      'description': 'Bayar tagihan air PDAM Lampung',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_lampung',
    },
    {
      'name': 'PDAM Kalimantan Barat',
      'description': 'Bayar tagihan air PDAM Kalbar',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_kalbar',
    },
    {
      'name': 'PDAM Kalimantan Tengah',
      'description': 'Bayar tagihan air PDAM Kalteng',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_kalteng',
    },
    {
      'name': 'PDAM Kalimantan Selatan',
      'description': 'Bayar tagihan air PDAM Kalsel',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_kalsel',
    },
    {
      'name': 'PDAM Kalimantan Timur',
      'description': 'Bayar tagihan air PDAM Kaltim',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_kaltim',
    },
    {
      'name': 'PDAM Kalimantan Utara',
      'description': 'Bayar tagihan air PDAM Kaltara',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_kaltara',
    },
    {
      'name': 'PDAM Sulawesi Utara',
      'description': 'Bayar tagihan air PDAM Sulut',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sulut',
    },
    {
      'name': 'PDAM Sulawesi Tengah',
      'description': 'Bayar tagihan air PDAM Sulteng',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sulteng',
    },
    {
      'name': 'PDAM Sulawesi Selatan',
      'description': 'Bayar tagihan air PDAM Sulsel',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sulsel',
    },
    {
      'name': 'PDAM Sulawesi Tenggara',
      'description': 'Bayar tagihan air PDAM Sultra',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sultra',
    },
    {
      'name': 'PDAM Gorontalo',
      'description': 'Bayar tagihan air PDAM Gorontalo',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_gorontalo',
    },
    {
      'name': 'PDAM Sulawesi Barat',
      'description': 'Bayar tagihan air PDAM Sulbar',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_sulbar',
    },
    {
      'name': 'PDAM Maluku',
      'description': 'Bayar tagihan air PDAM Maluku',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_maluku',
    },
    {
      'name': 'PDAM Maluku Utara',
      'description': 'Bayar tagihan air PDAM Malut',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_malut',
    },
    {
      'name': 'PDAM Papua',
      'description': 'Bayar tagihan air PDAM Papua',
      'logoPath': 'assets/image/pdam_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[600],
      'icon': Icons.water_drop,
      'buyerSkuCode': 'pdam_papua',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return pdamProducts;
    }
    return pdamProducts.where((product) {
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
          'PDAM',
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
                hintText: 'Cari PDAM daerah...',
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
                          'PDAM tidak ditemukan',
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
                        return _buildPDAMCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDAMCard(Map<String, dynamic> product) {
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
              serviceType: 'pdam',
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
                  // PDAM Logo
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
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.water_drop,
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