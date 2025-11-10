import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/popular_store_view.dart';
import 'package:sixam_mart/features/wallet/screens/wallet_screen.dart';
import 'package:sixam_mart/features/loyalty/screens/loyalty_screen.dart';
import 'package:sixam_mart/features/opayment/screens/DaftarAgenPage.dart';
import 'package:sixam_mart/features/opayment/screens/PLNPage.dart';
import 'package:sixam_mart/features/opayment/screens/InternetTVPage.dart';
import 'package:sixam_mart/features/opayment/screens/DashboardOPayment.dart';
import 'package:sixam_mart/features/opayment/screens/PulsaDataPage.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModuleView extends StatelessWidget {
  final SplashController splashController;
  final bool isLoading;
  
  const ModuleView({
    super.key, 
    required this.splashController,
    this.isLoading = false,
  });

  // Method untuk cek login dan navigasi
  void _handleNavigation(BuildContext context, Widget destination) {
    if (AuthHelper.isLoggedIn()) {
      Get.to(() => destination);
    } else {
      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika masih loading, tampilkan shimmer untuk semua bagian
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Shimmer - Full Width tanpa border radius
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[300],
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                color: Colors.grey[300],
              ),
            ),
          ),
          
          // Info Cards Shimmer - BARU
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 153,
                  height: 60,
                  margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: Dimensions.paddingSizeSmall),
          
          // Payment Menu Shimmer
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => _buildMenuShimmer()),
            ),
          ),
          
          // Info Card Shimmer
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Service Title Shimmer
          Container(
            margin: const EdgeInsets.only(left: 20, bottom: 10, top: 10),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: 150,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
          
          // Module Grid Shimmer
          ModuleShimmer(isEnabled: true),
          
          const SizedBox(height: 120),
        ],
      );
    }

    // Tampilan normal ketika data sudah loaded
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner full width tanpa border radius
          ClipRect(
            child: SizedBox(
              width: double.infinity,
              child: GetBuilder<BannerController>(builder: (bannerController) {
                return const BannerView(isFeatured: true, noBorderRadius: true);
              }),
            ),
          ),
          
          // Search Bar yang numpang ke banner
          Positioned(
            bottom: -10,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cari Layanan ditokoku',
                      style: robotoRegular.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 10),

      Container(
        margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        // decoration: const BoxDecoration(
        //   color: Color(0xFFcff7ec),
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Pulsa & Data
            _buildMenuItem(
              context: context,
              icon: 'assets/image/pulsa_icon.png',
              title: 'Pulsa & Data',
              onTap: () {
                _handleNavigation(context, const PulsaDataPage());
              },
            ),
            
            // Listrik PLN
            _buildMenuItem(
              context: context,
              icon: 'assets/image/listrik_icon.png',
              title: 'Listrik PLN',
              onTap: () {
                _handleNavigation(context, PLNPage());
              },
            ),
            
            // Internet & TV
            _buildMenuItem(
              context: context,
              icon: 'assets/image/wifi_icon.png',
              title: 'Internet & TV',
              onTap: () {
                _handleNavigation(context, InternetTVPage());
              },
            ),
            
            // Lihat Semua
            _buildMenuItem(
              context: context,
              icon: 'assets/image/lainlain_icon.png',
              title: 'Lihat Semua',
              onTap: () {
                _handleNavigation(context, DashboardOPayment());
              },
            ),
          ],
        ),
      ),

      // Info Cards Horizontal - Dipindahkan ke bawah menu payment
      GetBuilder<ProfileController>(
        builder: (profileController) {
          return _InfoCardsWidget(profileController: profileController);
        },
      ),

      const SizedBox(height: Dimensions.paddingSizeSmall),
            // Info Card - difotoin
            CustomInkWell(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: Text(
                      'Informasi',
                      style: robotoBold.copyWith(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    content: Text(
                      'Fitur dalam pengembangan',
                      style: robotoRegular.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'OK',
                          style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              radius: 12,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Icon/Logo Container
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/image/difotoin_logo.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'difotoin ',
                                  style: robotoBold.copyWith(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: '"Temukan & Miliki Foto Terbaikmu"',
                                  style: robotoRegular.copyWith(
                                    fontSize: 8,
                                    color: Colors.black87,
                                    fontStyle: FontStyle.italic,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'difotoin memudahkan kamu menemukan dan membeli foto diri dari berbagai acara lewat AI Face Recognition, lalu menyimpannya tanpa watermark.',
                            style: robotoRegular.copyWith(
                              fontSize: 8,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(left: 20, bottom: 10, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'my_service'.tr,
                    style: poppins600.copyWith(fontSize: 15),
                  ),
                  Text(
                    'slogan_layanan'.tr,
                    style: robotoRegular.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),

      splashController.moduleList != null ? splashController.moduleList!.isNotEmpty ? 
      GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, 
          mainAxisSpacing: 12,
          crossAxisSpacing: 12, 
          childAspectRatio: (1/1.35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: Dimensions.paddingSizeSmall),
        itemCount: splashController.moduleList!.length,
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CustomInkWell(
             onTap: () {
              // Tampilkan dialog informasi
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Informasi',
                          style: robotoBold.copyWith(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fitur ini masih dalam tahap pengembangan.',
                        style: robotoRegular.copyWith(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Launching diperkirakan pada bulan Januari 2026',
                        style: robotoMedium.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Mengerti',
                        style: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
                  radius: Dimensions.radiusDefault,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        image: '${splashController.moduleList![index].iconFullUrl}',
                        height: 40, width: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text( 
                splashController.moduleList![index].moduleName!,
                textAlign: TextAlign.center, 
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
              ),
            ],
          );
        },
      ) : ModuleShimmer(isEnabled: true) : ModuleShimmer(isEnabled: splashController.moduleList == null),

      const Padding(
        padding: EdgeInsets.only(left: 16),
        child: PopularStoreView(isPopular: false, isFeatured: true),
      ),
      const SizedBox(height: 120),

    ]);
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: CustomInkWell(
        onTap: onTap,
        radius: Dimensions.radiusDefault,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                icon,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              title,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuShimmer() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              height: 10,
              width: 50,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget terpisah untuk Info Cards dengan state management
class _InfoCardsWidget extends StatefulWidget {
  final ProfileController profileController;
  
  const _InfoCardsWidget({required this.profileController});

  @override
  State<_InfoCardsWidget> createState() => _InfoCardsWidgetState();
}

class _InfoCardsWidgetState extends State<_InfoCardsWidget> {
  bool isLoadingAgen = true;
  String? namaKonter;
  bool isAgen = false;
  int loyaltyPoints = 0;
  bool isLoadingPoints = true;

  @override
  void initState() {
    super.initState();
    if (AuthHelper.isLoggedIn()) {
      _checkAgenStatus();
      _loadLoyaltyPoints();
    } else {
      setState(() {
        isLoadingAgen = false;
        isLoadingPoints = false;
      });
    }
  }

  Future<void> _checkAgenStatus() async {
    try {
      setState(() {
        isLoadingAgen = true;
      });

      final profileController = widget.profileController;
      
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
      
      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/users/agen/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && data['data'].isNotEmpty) {
          if (mounted) {
            setState(() {
              isAgen = true;
              namaKonter = data['data'][0]['nama_konter'];
              isLoadingAgen = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isAgen = false;
              isLoadingAgen = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isAgen = false;
            isLoadingAgen = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isAgen = false;
          isLoadingAgen = false;
        });
      }
    }
  }

  Future<void> _loadLoyaltyPoints() async {
    try {
      setState(() {
        isLoadingPoints = true;
      });

      final profileController = widget.profileController;
      
      if (profileController.userInfoModel == null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final userId = profileController.userInfoModel?.id;
      
      if (userId == null) {
        setState(() {
          isLoadingPoints = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.ditokoku.id/api/loyalty/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          if (mounted) {
            setState(() {
              loyaltyPoints = data['data']['total_points'] ?? 0;
              isLoadingPoints = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isLoadingPoints = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingPoints = false;
          });
        }
      }
    } catch (e) {
      print('Error loading loyalty points: $e');
      if (mounted) {
        setState(() {
          isLoadingPoints = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        children: [
          // Card 1: Status Agen
          _buildInfoCard(
            title: isLoggedIn 
                ? (isAgen && namaKonter != null 
                    ? namaKonter! 
                    : 'Daftar')
                : 'Anda Terdaftar',
            subtitle: isLoggedIn 
                ? (isAgen 
                    ? 'Agen Platinum' 
                    : 'Agen Platinum')
                : 'Belum Login',
            icon: Icons.verified,
            iconColor: isAgen ? Colors.blue : Colors.grey,
            backgroundColor: const Color(0xFFF9F9F9),
            isLoading: isLoadingAgen && isLoggedIn,
            onTap: () {
              if (!isLoggedIn) {
                Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DaftarAgenPage()),
                );
              }
            },
          ),
          
          const SizedBox(width: 12),
          
          // Card 2: Saldo
          _buildInfoCard(
            title: 'Saldo',
            subtitle: isLoggedIn && widget.profileController.userInfoModel != null
                ? PriceConverter.convertPrice(widget.profileController.userInfoModel!.walletBalance)
                : 'Rp 0',
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFF4CAF50),
            backgroundColor: const Color(0xFFF9F9F9),
            isLoading: isLoggedIn && widget.profileController.userInfoModel == null,
            onTap: () {
              if (!isLoggedIn) {
                Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletScreen(fromNotification: false)),
                );
              }
            },
          ),
          
          const SizedBox(width: 12),
          
          // Card 3: Poin
          _buildInfoCard(
            title: 'Poin',
            subtitle: isLoggedIn ? loyaltyPoints.toString() : '0',
            icon: Icons.star,
            iconColor: const Color(0xFFFFA726),
            backgroundColor: const Color(0xFFF9F9F9),
            isLoading: isLoadingPoints && isLoggedIn,
            onTap: () {
              if (!isLoggedIn) {
                Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoyaltyScreen(fromNotification: false)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    // Menentukan icon path berdasarkan icon type
    String iconPath = '';
    if (icon == Icons.verified) {
      iconPath = 'assets/image/verifiedblue.png';
    } else if (icon == Icons.account_balance_wallet) {
      iconPath = 'assets/image/saldoic.png';
    } else if (icon == Icons.star) {
      iconPath = 'assets/image/poinic.png';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
      width: 153,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Background #F9F9F9 untuk semua card
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading
          ? Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: robotoRegular.copyWith(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: robotoMedium.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Menggunakan Image.asset untuk icon custom
                Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ],
            ),
      ),
    );
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;
  const ModuleShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: Dimensions.paddingSizeExtraExtraSmall,
        crossAxisSpacing: Dimensions.paddingSizeExtraExtraSmall, 
        childAspectRatio: (1/1),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 8,
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Center(child: Container(height: 12, width: 40, color: Colors.grey[300])),

            ]),
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;
  const AddressShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        SizedBox(
          height: 70,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.location_on,
                      size: ResponsiveHelper.isDesktop(context) ? 50 : 40, color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: isEnabled,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(height: 15, width: 100, color: Colors.grey[300]),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Container(height: 10, width: 150, color: Colors.grey[300]),
                        ]),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}