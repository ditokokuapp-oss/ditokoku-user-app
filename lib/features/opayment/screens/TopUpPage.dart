import 'package:flutter/material.dart';
import 'package:sixam_mart/util/styles.dart';
import 'TopUpAmountPage.dart';

class TopUpPage extends StatelessWidget {
  const TopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data metode pembayaran
    final List<Map<String, dynamic>> paymentMethods = [
      // Virtual Account
      {
        'category': 'Virtual Account',
        'methods': [
          {'name': 'BCA Virtual Account', 'code': 'BCAVA', 'logo': 'assets/image/bca_logo.png'},
          {'name': 'BRI Virtual Account', 'code': 'BRIVA', 'logo': 'assets/image/bri_logo.png'},
          {'name': 'BNI Virtual Account', 'code': 'BNIVA', 'logo': 'assets/image/bni_logo.png'},
          {'name': 'Mandiri Virtual Account', 'code': 'MANDIRIVA', 'logo': 'assets/image/mandiri_logo.png'},
          {'name': 'Permata Virtual Account', 'code': 'PERMATAVA', 'logo': 'assets/image/permata_logo.jpg'},
          {'name': 'BSI Virtual Account', 'code': 'BSIVA', 'logo': 'assets/image/bsi_logo.png'},
          {'name': 'CIMB Virtual Account', 'code': 'CIMBVA', 'logo': 'assets/image/cimb_logo.png'},
          {'name': 'Muamalat Virtual Account', 'code': 'MUAMALATVA', 'logo': 'assets/image/muamalat_logo.jpg'},
          {'name': 'Danamon Virtual Account', 'code': 'DANAMONVA', 'logo': 'assets/image/danamon_logo.png'},
          {'name': 'OCBC NISP Virtual Account', 'code': 'OCBCVA', 'logo': 'assets/image/ocbc_logo.png'},
          {'name': 'Bank Lain', 'code': 'BANKLAIN', 'logo': 'assets/image/banklain_logo.png'},
        ]
      },
      // Convenience Store
      {
        'category': 'Convenience Store',
        'methods': [
          {'name': 'Alfamart', 'code': 'ALFAMART', 'logo': 'assets/image/alfamart_logo.png'},
          {'name': 'Indomaret', 'code': 'INDOMARET', 'logo': 'assets/image/indomaret_logo.png'},
          {'name': 'Alfamidi', 'code': 'ALFAMIDI', 'logo': 'assets/image/alfamidi_logo.png'},
        ]
      },
      // E-Wallet
      {
        'category': 'E-Wallet',
        'methods': [
          {'name': 'QRIS', 'code': 'QRIS', 'logo': 'assets/image/qris_logo.png'},
        ]
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/image/goback.png',
              width: 31,
              height: 31,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          'Isi Saldo',
          style: robotoBold.copyWith(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blue[600],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih Metode Pembayaran',
                                style: robotoBold.copyWith(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pilih metode pembayaran untuk mengisi saldo',
                                style: robotoRegular.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Methods List
              ...paymentMethods.map((category) => _buildPaymentCategory(
                context,
                category['category'],
                category['methods'],
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCategory(BuildContext context, String categoryName, List<Map<String, dynamic>> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            categoryName,
            style: robotoBold.copyWith(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),

        // Methods Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: methods.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> method = entry.value;
              bool isLast = index == methods.length - 1;
              
              return _buildPaymentMethodItem(
                context,
                method['name'],
                method['code'],
                method['logo'],
                isLast,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPaymentMethodItem(
    BuildContext context,
    String name,
    String code,
    String logoPath,
    bool isLast,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopUpAmountPage(
              paymentMethod: name,
              paymentCode: code,
              logoPath: logoPath,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: !isLast ? Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  logoPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Name
            Expanded(
              child: Text(
                name,
                style: robotoRegular.copyWith(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}