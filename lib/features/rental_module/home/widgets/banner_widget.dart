import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/vendor/screens/vendor_detail_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {

    return GetBuilder<TaxiHomeController>(
      builder: (taxiHomeController) {
        return taxiHomeController.taxiBannerModel != null ? taxiHomeController.taxiBannerModel!.banners!.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: Column(children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                disableCenter: true,
                viewportFraction: 0.95,
                aspectRatio: 16/6,
                autoPlayInterval: const Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
              itemCount: taxiHomeController.taxiBannerModel!.banners!.length,
              itemBuilder: (context, index, _) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                  child: CustomInkWell(
                    onTap: () async {
                      if(taxiHomeController.taxiBannerModel!.banners![index].type == 'default') {
                        String url = taxiHomeController.taxiBannerModel!.banners![index].link ?? '';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        } else {
                          showCustomSnackBar('unable_to_found_url'.tr);
                        }
                      } else {
                        Get.to(()=> VendorDetailScreen(vendorId: taxiHomeController.taxiBannerModel!.banners![index].providerId));
                      }
                    },
                    radius: Dimensions.radiusLarge,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      child: CustomImage(image: taxiHomeController.taxiBannerModel!.banners![index].imageFullUrl??'', fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentCarouselIndex,
                count: taxiHomeController.taxiBannerModel!.banners!.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 6, dotWidth: 6, activeDotColor: Theme.of(context).primaryColor,
                  dotColor: Theme.of(context).disabledColor, spacing: 5,
                ),
              ),
            ),

          ]),
        ) : const SizedBox() : Shimmer(
          duration: const Duration(seconds: 2),
          enabled: taxiHomeController.taxiBannerModel?.banners == null,
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            color: Colors.grey[300],
          )),
        );
      }
    );
  }
}

