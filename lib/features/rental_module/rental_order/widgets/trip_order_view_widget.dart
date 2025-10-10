import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_model.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_order/screens/taxi_order_details_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_order/widgets/taxi_order_shimmer_widget.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class TripOrderViewWidget extends StatelessWidget {
  final bool isRunning;
  const TripOrderViewWidget({super.key, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<TaxiOrderController>(builder: (taxiOrderController) {
        TripModel? tripModel;
        if(taxiOrderController.tripModel != null && taxiOrderController.tripHistoryModel != null) {
          tripModel = isRunning ? taxiOrderController.tripModel : taxiOrderController.tripHistoryModel;
        }

        return tripModel != null ? tripModel.trips!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isRunning) {
              await taxiOrderController.getTripList(1, isUpdate: true, isRunning: true);
            }else {
              await taxiOrderController.getTripList(1, isUpdate: true, isRunning: false);
            }
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 60),
            child: PaginatedListView(
              scrollController: scrollController,
              onPaginate: (int? offset) {
                if(isRunning) {
                  taxiOrderController.getTripList(offset!, isUpdate: true);
                }else {
                  taxiOrderController.getTripList(offset!, isUpdate: true, isRunning: false);
                }
              },
              totalSize: isRunning ? taxiOrderController.tripModel!.totalSize : taxiOrderController.tripHistoryModel!.totalSize,
              offset: isRunning ? taxiOrderController.tripModel!.offset : taxiOrderController.tripHistoryModel!.offset,
              itemView: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: Dimensions.paddingSizeLarge,
                  mainAxisSpacing: 0,
                  // childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.5,
                  mainAxisExtent: 100,
                  crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                itemCount: tripModel.trips!.length,
                itemBuilder: (context, index) {

                  return CustomInkWell(
                    onTap: () {
                      Get.to(()=> TaxiOrderDetailsScreen(tripId: tripModel!.trips![index].id!));
                    },
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                      Row(children: [

                        Container(
                          height: 60, width: 60, alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: tripModel!.trips![index].provider?.logoFullUrl??'',
                              height: 60, width: 60, fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(
                                '${'trip_id'.tr}:',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text('#${tripModel.trips![index].id}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Text(
                              // 'date',
                              DateConverter.dateTimeStringToUTCTime(tripModel.trips![index].createdAt!),
                              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                            ),
                          ]),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          !ResponsiveHelper.isDesktop(context) ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ),
                            child: Text(tripModel.trips![index].tripStatus!.tr, style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                            )),
                          ) : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          /*isRunning ? InkWell(
                            // onTap: () => Get.toNamed(RouteHelper.getOrderTrackingRoute(tripModel!.orders![index].id, null)),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.paddingSizeExtraSmall),
                              decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Theme.of(context).primaryColor,
                              ) : BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                              ),
                              child: Row(children: [
                                Image.asset(Images.tracking, height: 15, width: 15, color: ResponsiveHelper.isDesktop(context) ? Colors.white : Theme.of(context).primaryColor),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text('track_trip'.tr, style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall, color: ResponsiveHelper.isDesktop(context) ? Colors.white : Theme.of(context).primaryColor,
                                )),
                              ]),
                            ),
                          ) :*/ Text(
                            '${tripModel.trips![index].quantity} ${tripModel.trips![index].quantity! > 1 ? 'vehicles'.tr : 'vehicle'.tr}',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                          ),
                        ]),

                      ]),

                      (index == tripModel.trips!.length-1) ? const SizedBox() : Padding(
                        padding: const EdgeInsets.only(left: 70),
                        child: Divider(
                          color: Theme.of(context).disabledColor, height: Dimensions.paddingSizeLarge,
                        ),
                      ),

                    ]),
                  );
                },),
            ),
          ),
        ) : NoDataScreen(text: 'no_order_found'.tr, showFooter: true) : TaxiOrderShimmerWidget(taxiOrderController: taxiOrderController);
      }),
    );
  }
}
