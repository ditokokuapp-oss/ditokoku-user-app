import 'package:flutter/material.dart';
import 'PascabayarTopUpPage.dart';

class MultifinancePage extends StatefulWidget {
  const MultifinancePage({super.key});

  @override
  State<MultifinancePage> createState() => _MultifinancePageState();
}

class _MultifinancePageState extends State<MultifinancePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data untuk produk Multifinance
final List<Map<String, dynamic>> multifinanceProducts = [
    {
      'name': 'ACC Finance',
      'description': 'Astra Credit Companies',
      'logoPath': 'assets/image/accfinance_logo.jpg',
      'buyerSkuCode': 'acc_finance',
    },
    {
      'name': 'Adira Finance',
      'description': 'Pembayaran cicilan Adira',
      'logoPath': 'assets/image/adirafinance_logo.jpg',
      'buyerSkuCode': 'adira_finance',
    },
    {
      'name': 'AEON Finance',
      'description': 'AEON Credit Service',
      'logoPath': 'assets/image/aeonfinance_logo.png',
      'buyerSkuCode': 'aeon_finance',
    },
    {
      'name': 'ASTRA Kredit',
      'description': 'Pembayaran cicilan Astra',
      'logoPath': 'assets/image/astrafinancial_logo.png',
      'buyerSkuCode': 'astra_kredit',
    },
    {
      'name': 'BAF',
      'description': 'Bussan Auto Finance',
      'logoPath': 'assets/image/baf_logo.png',
      'buyerSkuCode': 'baf',
    },
    {
      'name': 'BCA Finance',
      'description': 'Pembayaran cicilan BCA Finance',
      'logoPath': 'assets/image/bcafinance_logo.jpg',
      'buyerSkuCode': 'bca_finance',
    },
    {
      'name': 'BFI Finance',
      'description': 'Pembayaran cicilan BFI',
      'logoPath': 'assets/image/bfi_logo.png',
      'buyerSkuCode': 'bfi_finance',
    },
    {
      'name': 'Bima Finance',
      'description': 'Pembayaran cicilan Bima',
      'logoPath': 'assets/image/bimafinance_logo.jpeg',
      'buyerSkuCode': 'bima_finance',
    },
    {
      'name': 'Buana Finance',
      'description': 'Pembayaran cicilan Buana',
      'logoPath': 'assets/image/buanafinance_logo.png',
      'buyerSkuCode': 'buana_finance',
    },
    {
      'name': 'Cappella Multidana Finance',
      'description': 'Pembayaran cicilan Cappella',
      'logoPath': 'assets/image/cpl_logo.png',
      'buyerSkuCode': 'cappella_finance',
    },
    {
      'name': 'Central Sentosa Finance',
      'description': 'CSF - Pembayaran cicilan',
      'logoPath': 'assets/image/csfinance_logo.png',
      'buyerSkuCode': 'csf',
    },
    {
      'name': 'CIMB Niaga Auto Kredit',
      'description': 'Pembayaran cicilan CIMB Niaga',
      'logoPath': 'assets/image/cimbfinance_logo.jpeg',
      'buyerSkuCode': 'cimb_auto',
    },
    {
      'name': 'Clipan Finance',
      'description': 'Pembayaran cicilan Clipan',
      'logoPath': 'assets/image/clipanfinance_logo.jpeg',
      'buyerSkuCode': 'clipan_finance',
    },
    {
      'name': 'Columbia Finance',
      'description': 'Pembayaran cicilan Columbia',
      'logoPath': 'assets/image/columbiafinance_logo.png',
      'buyerSkuCode': 'columbia_finance',
    },
    {
      'name': 'FIF',
      'description': 'FIFGROUP - Federal International Finance',
      'logoPath': 'assets/image/fifgroup_finance.png',
      'buyerSkuCode': 'fif',
    },
    {
      'name': 'Indomobil Finance',
      'description': 'IFI - Indomobil Finance Indonesia',
      'logoPath': 'assets/image/indomobil_logo.png',
      'buyerSkuCode': 'ifi',
    },
    {
      'name': 'ITC Finance',
      'description': 'Pembayaran cicilan ITC',
      'logoPath': 'assets/image/itcfinance_logo.png',
      'buyerSkuCode': 'itc_finance',
    },
    {
      'name': 'KreditPlus',
      'description': 'Pembayaran cicilan KreditPlus',
      'logoPath': 'assets/image/kreditplus_logo.png',
      'buyerSkuCode': 'kreditplus',
    },
    {
      'name': 'Mandala Finance',
      'description': 'Pembayaran cicilan Mandala',
      'logoPath': 'assets/image/mandalafinance_logo.jpg',
      'buyerSkuCode': 'mandala_finance',
    },
    {
      'name': 'Mandiri Tunas Finance',
      'description': 'MTF - Pembayaran cicilan',
      'logoPath': 'assets/image/mandiritunas_logo.jpg',
      'buyerSkuCode': 'mtf',
    },
    {
      'name': 'Mandiri Utama Finance',
      'description': 'MUF - Pembayaran cicilan',
      'logoPath': 'assets/image/mandiriutama_logo.jpeg',
      'buyerSkuCode': 'muf',
    },
    {
      'name': 'Mega Auto Finance',
      'description': 'MAF - Pembayaran cicilan',
      'logoPath': 'assets/image/megaauto_logo.jpg',
      'buyerSkuCode': 'maf',
    },
    {
      'name': 'Mega Central Finance',
      'description': 'MCF - Pembayaran cicilan',
      'logoPath': 'assets/image/megacentral_logo.jpg',
      'buyerSkuCode': 'mcf',
    },
    {
      'name': 'Mega Finance',
      'description': 'Pembayaran cicilan Mega',
      'logoPath': 'assets/image/megafinance_logo.png',
      'buyerSkuCode': 'mega_finance',
    },
    {
      'name': 'MNC Finance',
      'description': 'Pembayaran cicilan MNC',
      'logoPath': 'assets/image/mncfinance_logo.png',
      'buyerSkuCode': 'mnc_finance',
    },
    {
      'name': 'MPM Finance',
      'description': 'Pembayaran cicilan MPM',
      'logoPath': 'assets/image/mpmfinance_logo.png',
      'buyerSkuCode': 'mpm_finance',
    },
    {
      'name': 'NSC Finance',
      'description': 'Pembayaran cicilan NSC',
      'logoPath': 'assets/image/nscfinance.png',
      'buyerSkuCode': 'nsc_finance',
    },
    {
      'name': 'OTO Finance',
      'description': 'Pembayaran cicilan OTO',
      'logoPath': 'assets/image/otofinance_logo.jpg',
      'buyerSkuCode': 'oto_finance',
    },
    {
      'name': 'Permata Finance',
      'description': 'Pembayaran cicilan Permata',
      'logoPath': 'assets/image/permatafinance_logo.jpeg',
      'buyerSkuCode': 'permata_finance',
    },
    {
      'name': 'Pro Mitra Finance',
      'description': 'Pembayaran cicilan Pro Mitra',
      'logoPath': 'assets/image/promitra_logo.jpg',
      'buyerSkuCode': 'pro_mitra',
    },
    {
      'name': 'Radana Finance',
      'description': 'HD Finance - Pembayaran cicilan',
      'logoPath': 'assets/image/radanafinance_logo.png',
      'buyerSkuCode': 'radana_finance',
    },
    {
      'name': 'Smart Finance',
      'description': 'Pembayaran cicilan Smart',
      'logoPath': 'assets/image/smartfinance_logo.png',
      'buyerSkuCode': 'smart_finance',
    },
    {
      'name': 'Suzuki Finance',
      'description': 'Pembayaran cicilan Suzuki',
      'logoPath': 'assets/image/suzukifinance_logo.jpg',
      'buyerSkuCode': 'suzuki_finance',
    },
    {
      'name': 'Toyota Astra Finance',
      'description': 'TAF - Pembayaran cicilan',
      'logoPath': 'assets/image/toyotaastrafinance_logo.jpeg',
      'buyerSkuCode': 'taf',
    },
    {
      'name': 'True Trihama Finance',
      'description': 'Pembayaran cicilan True Trihama',
      'logoPath': 'assets/image/truetrihamas_logo.png',
      'buyerSkuCode': 'true_trihama',
    },
    {
      'name': 'Varia Intra Finance',
      'description': 'Pembayaran cicilan Varia Intra',
      'logoPath': 'assets/image/variaintra_logo.jpg',
      'buyerSkuCode': 'varia_intra',
    },
    {
      'name': 'Woka Finance',
      'description': 'Pembayaran cicilan Woka',
      'logoPath': 'assets/image/wokafinance_logo.png',
      'buyerSkuCode': 'woka_finance',
    },
    {
      'name': 'Wom Finance',
      'description': 'Pembayaran cicilan Wom',
      'logoPath': 'assets/image/womfinance_logo.png',
      'buyerSkuCode': 'wom_finance',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return multifinanceProducts;
    }
    return multifinanceProducts.where((product) {
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
          'Multifinance',
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
                hintText: 'Cari multifinance...',
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
                          'Multifinance tidak ditemukan',
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
                        return _buildMultifinanceCard(filteredProducts[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultifinanceCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        // Navigate to PascabayarTopUpPage for all multifinance products
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PascabayarTopUpPage(
              serviceName: product['name'],
              serviceDescription: product['description'],
              logoPath: product['logoPath'],
              buyerSkuCode: product['buyerSkuCode'],
              serviceColor: Colors.blue[700],
              serviceType: 'multifinance',
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
                        Icons.account_balance,
                        color: Colors.blue[600],
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