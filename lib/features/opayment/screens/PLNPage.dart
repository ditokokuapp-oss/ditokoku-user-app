import 'package:flutter/material.dart';
import 'PLNTopUpPage.dart';
import 'PascabayarTopUpPage.dart';

class PLNPage extends StatefulWidget {
  const PLNPage({super.key});

  @override
  State<PLNPage> createState() => _PLNPageState();
}

class _PLNPageState extends State<PLNPage> {
  // Data untuk produk PLN
  final List<Map<String, dynamic>> plnProducts = [
    {
      'name': 'PLN PascaBayar',
      'description': 'Bayar tagihan listrik bulanan',
      'logoPath': 'assets/image/pln_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.blue[700],
      'icon': Icons.receipt_long,
      'buyerSkuCode': 'pln', // Add buyer_sku_code for pascabayar
    },
    {
      'name': 'PLN Token',
      'description': 'Beli token listrik prabayar',
      'logoPath': 'assets/image/pln_logo.png',
      'backgroundColor': Colors.white,
      'iconColor': Colors.orange[700],
      'icon': Icons.flash_on,
      'buyerSkuCode': 'pln_token', // Add buyer_sku_code for token
    },
  ];

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
    width: 28,   // bisa sesuaikan
    height: 28,  // bisa sesuaikan
    fit: BoxFit.contain,
  ),
  onPressed: () => Navigator.pop(context),
),
        title: const Text(
          'Listrik PLN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: plnProducts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildPLNCard(plnProducts[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPLNCard(Map<String, dynamic> product) {
    return InkWell(
      onTap: () {
        // Check if it's PLN PascaBayar
        if (product['name'] == 'PLN PascaBayar') {
          // Navigate to PascabayarTopUpPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PascabayarTopUpPage(
                serviceName: product['name'],
                serviceDescription: product['description'],
                logoPath: product['logoPath'],
                buyerSkuCode: product['buyerSkuCode'] ?? 'pln',
                serviceColor: Colors.blue[700],
                serviceType: 'pln',
              ),
            ),
          );
        } else {
          // Navigate to PLNTopUpPage for PLN Token
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PLNTopUpPage(
                serviceName: product['name'],
                serviceDescription: product['description'],
                logoPath: product['logoPath'],
                serviceType: 'token',
              ),
            ),
          );
        }
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
                  // PLN Logo
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
                            Icons.flash_on,
                            color: Colors.blue[600],
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