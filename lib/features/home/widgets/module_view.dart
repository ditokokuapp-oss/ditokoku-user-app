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
import 'package:sixam_mart/features/opayment/screens/PLNPage.dart';
import 'package:sixam_mart/features/opayment/screens/InternetTVPage.dart';
import 'package:sixam_mart/features/opayment/screens/DashboardOPayment.dart';
import 'package:sixam_mart/features/opayment/screens/PulsaDataPage.dart';
import 'package:sixam_mart/helper/route_helper.dart';

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
          // Banner Shimmer
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
              ),
            ),
          ),
          
          // Payment Menu Shimmer
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: const BoxDecoration(
              color: Color(0xFFcff7ec),
            ),
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

      GetBuilder<BannerController>(builder: (bannerController) {
        return const BannerView(isFeatured: true);
      }),

      Container(
        margin: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: const BoxDecoration(
          color: Color(0xFFcff7ec),
        ),
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
                  onTap: () => splashController.switchModule(index, true),
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

      GetBuilder<AddressController>(builder: (locationController) {
        List<AddressModel?> addressList = [];
        if(AuthHelper.isLoggedIn() && locationController.addressList != null) {
          addressList = [];
          bool contain = false;
          if(AddressHelper.getUserAddressFromSharedPref()!.id != null) {
            for(int index=0; index<locationController.addressList!.length; index++) {
              if(locationController.addressList![index].id == AddressHelper.getUserAddressFromSharedPref()!.id) {
                contain = true;
                break;
              }
            }
          }
          if(!contain) {
            addressList.add(AddressHelper.getUserAddressFromSharedPref());
          }
          addressList.addAll(locationController.addressList!);
        }
        return (!AuthHelper.isLoggedIn() || locationController.addressList != null) ? addressList.isNotEmpty ? Column(
          children: [

            const SizedBox(height: Dimensions.paddingSizeLarge),

            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: TitleWidget(title: 'deliver_to'.tr),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SizedBox(
              height: 80,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: addressList.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) {
                  return Container(
                    width: 300,
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: AddressWidget(
                      address: addressList[index],
                      fromAddress: false,
                      onTap: () {
                        if(AddressHelper.getUserAddressFromSharedPref()!.id != addressList[index]!.id) {
                          Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                          Get.find<LocationController>().saveAddressAndNavigate(
                            addressList[index], false, null, false, ResponsiveHelper.isDesktop(context),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ) : const SizedBox() : AddressShimmer(isEnabled: AuthHelper.isLoggedIn() && locationController.addressList == null);
      }),

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