import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/widgets/taxi_shimmer_view.dart';
import 'package:sixam_mart/util/dimensions.dart';

import '../common/widgets/headers_title_widget.dart';
import 'trip_history_card.dart';

class TripHistoryWidget extends StatelessWidget {
  const TripHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<TaxiOrderController>(
      builder: (taxiOrderController) {
        return taxiOrderController.tripHistoryModel != null && taxiOrderController.tripHistoryModel!.trips != null ? taxiOrderController.tripHistoryModel!.trips!.isNotEmpty ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: HeadersTitleWidget(
                title: 'trip_history'.tr,
                // onSeeAllPressed: (){},
              ),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: taxiOrderController.tripHistoryModel!.trips!.length > 5 ? 5 : taxiOrderController.tripHistoryModel!.trips!.length,
              itemBuilder: (context, index) {
                return TripHistoryCard(trip: taxiOrderController.tripHistoryModel!.trips![index]);
              },
            )]
        ) : const SizedBox() : const TopHistoryWidgetShimmerView();
      }
    );
  }
}
