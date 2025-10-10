import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/rental_module/vendor/controllers/taxi_vendor_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProviderBannerWidget extends StatelessWidget {
  final TaxiVendorController taxiVendorController;
  const ProviderBannerWidget({super.key, required this.taxiVendorController});

  @override
  Widget build(BuildContext context) {
    return (taxiVendorController.vendorBannerList != null && taxiVendorController.vendorBannerList!.isNotEmpty) ? Container(
      height: context.width * 0.3, width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
      child: CarouselSlider.builder(
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          disableCenter: true,
          viewportFraction: 1,
          autoPlayInterval: const Duration(seconds: 4),
        ),
        itemCount: taxiVendorController.vendorBannerList!.length,
        itemBuilder: (context, index, _) {
          return InkWell(
            onTap: () async {
              if(taxiVendorController.vendorBannerList![index].type == 'default') {
                String url = taxiVendorController.vendorBannerList![index].link ?? '';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(url, mode: LaunchMode.externalApplication);
                } else {
                  showCustomSnackBar('unable_to_found_url'.tr);
                }
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(
                image: '${taxiVendorController.vendorBannerList![index].imageFullUrl}',
              ),
            ),
          );
        },
      ),
    ) : const SizedBox();
  }
}