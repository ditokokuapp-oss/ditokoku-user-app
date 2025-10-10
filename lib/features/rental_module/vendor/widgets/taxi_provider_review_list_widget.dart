
import 'package:flutter/material.dart';
import 'package:sixam_mart/features/rental_module/vendor/controllers/taxi_vendor_controller.dart';
import 'package:sixam_mart/features/rental_module/vendor/widgets/taxi_review_widget.dart';

class TaxiProviderReviewListWidget extends StatelessWidget {
  final TaxiVendorController taxiVendorController;
  final String? providerName;
  const TaxiProviderReviewListWidget({super.key, required this.taxiVendorController, this.providerName});

  @override
  Widget build(BuildContext context) {

    return taxiVendorController.providerReviewList != null ? ListView.builder(
      itemCount: taxiVendorController.providerReviewList!.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return TaxiReviewWidget(
          hasDivider: index != taxiVendorController.providerReviewList!.length - 1,
          storeName: providerName,
          review: taxiVendorController.providerReviewList![index],
        );
      },
    ) : const CircularProgressIndicator();
  }

}
