import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'TopUpService.dart';
import 'TopUpWebViewPage.dart';
import 'AgentTopUpWebViewPage.dart';

class TopUpAmountPage extends StatefulWidget {
  final String paymentMethod;
  final String paymentCode;
  final String logoPath;
  final bool isFromAgentRegistration;
  final int? minTopupAmount;
  final Map<String, dynamic>? agentData;

  const TopUpAmountPage({
    super.key,
    required this.paymentMethod,
    required this.paymentCode,
    required this.logoPath,
    this.isFromAgentRegistration = false,
    this.minTopupAmount,
    this.agentData,
  });

  @override
  State<TopUpAmountPage> createState() => _TopUpAmountPageState();
}

class _TopUpAmountPageState extends State<TopUpAmountPage> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  bool _isLoading = false;
  
  final List<int> predefinedAmounts = [
    10000, 20000, 50000, 100000, 200000, 500000
  ];

  @override
  void initState() {
    super.initState();
    // Jika dari pendaftaran agen, set otomatis sesuai minTopupAmount
    if (widget.isFromAgentRegistration && widget.minTopupAmount != null) {
      _amountController.text = widget.minTopupAmount.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  String _getUserName() {
    try {
      final profileController = Get.find<ProfileController>();
      final userInfo = profileController.userInfoModel;
      if (userInfo != null) {
        final fName = userInfo.fName ?? '';
        final lName = userInfo.lName ?? '';
        return '$fName $lName'.trim();
      }
      return 'User';
    } catch (e) {
      return 'User';
    }
  }

  String _getUserEmail() {
    try {
      final profileController = Get.find<ProfileController>();
      final userInfo = profileController.userInfoModel;
      return userInfo?.email ?? 'user@example.com';
    } catch (e) {
      return 'user@example.com';
    }
  }

  String _getUserPhone() {
    try {
      final profileController = Get.find<ProfileController>();
      final userInfo = profileController.userInfoModel;
      return userInfo?.phone ?? '08123456789';
    } catch (e) {
      return '08123456789';
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
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
          widget.isFromAgentRegistration 
            ? 'Isi Saldo & Daftar Agen Platinum'
            : 'Masukkan Nominal',
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
              // Info Banner untuk Agent Registration
              if (widget.isFromAgentRegistration && widget.minTopupAmount != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Anda akan Mengisi saldo Rp. ${_formatCurrency(widget.minTopupAmount!)} untuk pendaftaran agen platinum',
                          style: robotoRegular.copyWith(
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Payment Method List (hanya tampil jika dari agent registration)
              if (widget.isFromAgentRegistration)
                _buildPaymentMethodsList()
              else
                _buildSelectedPaymentMethod(),
              
              const SizedBox(height: 24),

              // Amount Display/Input
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
                    Text(
                      'Nominal Top Up',
                      style: robotoBold.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount Input Field (readonly jika dari agent registration)
                    TextField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      keyboardType: TextInputType.number,
                      enabled: !widget.isFromAgentRegistration, // Disable jika dari agent
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: robotoBold.copyWith(
                        fontSize: 24,
                        color: widget.isFromAgentRegistration 
                          ? Colors.grey[600] 
                          : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nominal',
                        hintStyle: robotoRegular.copyWith(
                          fontSize: 18,
                          color: Colors.grey[400],
                        ),
                        prefixText: 'Rp ',
                        prefixStyle: robotoBold.copyWith(
                          fontSize: 24,
                          color: widget.isFromAgentRegistration 
                            ? Colors.grey[600] 
                            : Colors.black,
                        ),
                        filled: widget.isFromAgentRegistration,
                        fillColor: widget.isFromAgentRegistration 
                          ? Colors.grey[100] 
                          : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue[600]!),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      widget.isFromAgentRegistration && widget.minTopupAmount != null
                        ? 'Nominal tetap Rp ${_formatCurrency(widget.minTopupAmount!)} untuk pendaftaran agen platinum'
                        : 'Minimal top up Rp 10.000',
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Predefined amounts (hanya tampil jika bukan dari agent registration)
              if (!widget.isFromAgentRegistration) ...[
                const SizedBox(height: 24),
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
                      Text(
                        'Nominal Cepat',
                        style: robotoBold.copyWith(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3,
                        ),
                        itemCount: predefinedAmounts.length,
                        itemBuilder: (context, index) {
                          final amount = predefinedAmounts[index];
                          return _buildAmountButton(amount);
                        },
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isValidAmount() && !_isLoading ? _processTopUp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.isFromAgentRegistration
                        ? 'Isi Saldo & Daftar Agen Platinum'
                        : 'Lanjutkan Pembayaran',
                      style: robotoBold.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPaymentMethod() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
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
                widget.logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.account_balance,
                    color: Colors.grey[600],
                    size: 24,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.paymentMethod,
                  style: robotoBold.copyWith(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Metode pembayaran dipilih',
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    // Data metode pembayaran dengan QRIS di paling atas
    final List<Map<String, dynamic>> allPaymentMethods = [
      // E-Wallet (QRIS di paling atas)
      {
        'category': 'E-Wallet',
        'methods': [
          {'name': 'QRIS', 'code': 'QRIS', 'logo': 'assets/image/qris_logo.png'},
        ]
      },
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
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            'Pilih Metode Pembayaran',
            style: robotoBold.copyWith(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // Tambahkan pemisahan kategori seperti di TopUpPage untuk tampilan yang lebih terstruktur
          ...allPaymentMethods.map((category) {
            final methods = category['methods'] as List<Map<String, dynamic>>;
            if (methods.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Title
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    category['category']!,
                    style: robotoBold.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Methods List
                ...methods.map((method) => _buildPaymentMethodItem(
                  method['name']!,
                  method['code']!,
                  method['logo']!,
                )).toList(),
                const SizedBox(height: 8), // Spasi antar kategori
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(String name, String code, String logo) {
    final isSelected = widget.paymentCode == code;
    
    return InkWell(
      onTap: () {
        // Update payment method
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TopUpAmountPage(
              paymentMethod: name,
              paymentCode: code,
              logoPath: logo,
              isFromAgentRegistration: true,
              minTopupAmount: widget.minTopupAmount,
              agentData: widget.agentData,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8), 
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: Row(
          children: [
            // Logo (Disamakan dengan desain TopUpPage)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  logo,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Desain error disamakan dengan TopUpPage
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.grey[600],
                        size: 20, 
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: robotoBold.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue[600], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(int amount) {
    return InkWell(
      onTap: () {
        _amountController.text = amount.toString();
        setState(() {});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            PriceConverter.convertPrice(amount.toDouble()),
            style: robotoRegular.copyWith(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isValidAmount() {
    if (_amountController.text.isEmpty) return false;
    final amount = int.tryParse(_amountController.text);
    
    if (widget.isFromAgentRegistration && widget.minTopupAmount != null) {
      return amount == widget.minTopupAmount; // Harus tepat sesuai minTopupAmount untuk agent
    }
    
    return amount != null && amount >= 10000;
  }

  Future<void> _processTopUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final amount = int.parse(_amountController.text);
      
      final userName = _getUserName();
      final userEmail = _getUserEmail();
      final userPhone = _getUserPhone();
      
      final response = await TopUpService.createTopUpTransaction(
        method: widget.paymentCode,
        amount: amount,
        name: userName,
        email: userEmail,
        phone: userPhone,
      );

      if (response.success == true && response.checkoutUrl != null) {
        // Navigate ke WebView yang sesuai
        if (widget.isFromAgentRegistration && widget.agentData != null) {
          // Untuk agent registration
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgentTopUpWebViewPage(
                checkoutUrl: response.checkoutUrl!,
                paymentMethod: widget.paymentMethod,
                amount: amount,
                agentData: widget.agentData!,
              ),
            ),
          );
        } else {
          // Untuk top-up biasa
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopUpWebViewPage(
                checkoutUrl: response.checkoutUrl!,
                paymentMethod: widget.paymentMethod,
                amount: amount,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal membuat transaksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}