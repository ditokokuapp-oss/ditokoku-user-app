import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/screens/vendor_detail_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class FavouriteVendorCard extends StatelessWidget {
  // final Provider? provider;
  final TaxiVendorModel? provider;
  const FavouriteVendorCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {

    return Container(
        //margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: CustomInkWell(
          radius: Dimensions.radiusDefault,
          onTap: ()=> Get.to(() => VendorDetailScreen(vendorId: provider!.id)),
          child: Column(children: [
            SizedBox(
              height: 180,
              width: double.infinity, // Ensures the width takes up all available space
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusDefault),
                  topRight: Radius.circular(Dimensions.radiusDefault),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(image: provider!.coverPhotoFullUrl ?? '', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),


            Container(
              height: 80, padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Row(children: [

                  Container(height: 65, width: 65,
                    decoration: const BoxDecoration(shape: BoxShape.circle,),
                    child: ClipOval(child: CustomImage(image: provider!.logoFullUrl ?? '', fit: BoxFit.cover)),
                  ),

                  const SizedBox(width: 10),

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Padding(padding: const EdgeInsets.only(top:18),
                      child: Text(provider?.name ?? '', style: robotoBold.copyWith(fontSize: 13, color: Colors.grey.shade700)),
                    ),

                    Padding(padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(provider?.address ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey.shade700)),
                    )
                  ])
                ]),

                Icon(Icons.favorite, color: Theme.of(context).primaryColor, size: 24),
              ]),
            ),
          ]),
        )
    );
  }
}
