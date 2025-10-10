import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/rental_module/vendor/controllers/taxi_vendor_controller.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_provider_review_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/widgets/taxi_provider_rating_widget.dart';
import 'package:sixam_mart/features/rental_module/vendor/widgets/taxi_provider_review_list_widget.dart';
import 'package:sixam_mart/util/dimensions.dart';

class ReviewDetailsScreen extends StatefulWidget {
  final String? providerName;
  final int? providerID;
  const ReviewDetailsScreen({super.key, this.providerName, this.providerID});

  @override
  State<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends State<ReviewDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();

    Get.find<TaxiVendorController>().getTaxiProviderReviewDetails(widget.providerID!);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '${widget.providerName}'),
      body: GetBuilder<TaxiVendorController>(builder: (taxiVendorController){
        TaxiProviderReviewModel? review = taxiVendorController.providerReviewDetails;

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [

            //Overall Rating Progress bar
            Container(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
              margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
              ),
              child: TaxiProviderRatingWidget(averageRating: review?.provider!.avgRating ?? 0, ratingCount: review?.provider!.ratingCount ?? 0, ratings: review?.provider!.ratings),

            ),

            //Reviews
            TaxiProviderReviewListWidget(taxiVendorController: taxiVendorController, providerName: widget.providerName,),

          ]),
        );
      })
    );
  }
}
