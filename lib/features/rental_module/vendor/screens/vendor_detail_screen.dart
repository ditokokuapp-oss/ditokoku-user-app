import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/rant_cart_widget.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/taxi_add_favourite_view.dart';
import 'package:sixam_mart/features/rental_module/vendor/controllers/taxi_vendor_controller.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/models/taxi_vendor_model.dart';
import 'package:sixam_mart/features/rental_module/vendor/screens/review_details_screen.dart';
import 'package:sixam_mart/features/rental_module/vendor/widgets/search_and_filter_widget.dart';
import 'package:sixam_mart/features/rental_module/vendor/widgets/taxi_rating_bar.dart';
import 'package:sixam_mart/features/rental_module/vendor/widgets/vendor_vehicle_card.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

import '../widgets/provider_banner_widget.dart';

class VendorDetailScreen extends StatefulWidget {
  final int? vendorId;
  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  String searchName = '';

  @override
  void initState() {
    super.initState();

    Get.find<TaxiVendorController>().setCategoryId(null, canUpdate: false);
    Get.find<TaxiVendorController>().getTaxiVendorDetails(widget.vendorId!);
    Get.find<TaxiVendorController>().getVendorBannerList(widget.vendorId!);
    Get.find<TaxiVendorController>().getVendorVehicleList(offset: 1, vendorId: widget.vendorId!, searchName: '', canUpdate: false);
    Get.find<TaxiVendorController>().getVendorVehicleCategoryList();
    Get.find<TaxiVendorController>().initFilterSetup(maxPrice: 0, willUpdate: false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        title: Text('provider_details'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        centerTitle: true,
        actions: const [RantCartWidget(), SizedBox(width: Dimensions.paddingSizeSmall)],
      ),
      body: GetBuilder <TaxiVendorController>(builder: (vendorController){
        TaxiVendorModel? vendor = vendorController.taxiVendor;

        if (vendor == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              child: Column(children: [
                SizedBox(height: 180, child: CustomImage(image: vendor.coverPhotoFullUrl ?? '', width: double.infinity, fit: BoxFit.cover)),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        height: 70, width: 70,
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Stack(children: [

                          SizedBox(
                            height: 70, width: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CustomImage(image: vendor.logoFullUrl ?? '', fit: BoxFit.cover),
                            ),
                          ),

                          vendorController.isProviderOpenNow(vendor.status == 1, vendor.schedules) ? const SizedBox() : Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(60)),
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              child: Text(
                                'close'.tr, textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                              ),
                            ),
                          ),

                        ]),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [

                        Text(vendor.name ?? '', maxLines: 1, style: robotoBold, overflow: TextOverflow.ellipsis),
                        Text(vendor.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        Text('${'approx_pickup_time'.tr}: ${vendor.deliveryTime??''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                      ]),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: TaxiAddFavouriteView(
                        favIconSize: 25,
                        providerId: vendor.id,
                      ),
                    ),

                  ]),
                ),

                Container(height: 1, width: double.infinity, color: Colors.grey.shade200, padding: const EdgeInsets.symmetric(horizontal: 20)),

                //Rating
                Padding(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [

                        Text('${vendor.avgRating}', style: robotoBold.copyWith(fontSize: 35, color: Theme.of(context).primaryColor)),
                        const SizedBox(width: 5),

                        RichText(text: TextSpan(children: <TextSpan>[

                          TextSpan(text: '${'based_on'.tr}\n', style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade600)),

                          TextSpan(text: '${vendor.ratingCount} ', style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),

                          TextSpan(text: 'ratings'.tr, style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade600))
                        ])),
                      ]),

                      TaxiRatingBar(rating: vendor.avgRating?.toDouble(), ratingCount: vendor.ratingCount),
                    ]),

                    CustomInkWell(
                      onTap: () {
                        Get.to(()=> ReviewDetailsScreen(providerID: vendor.id, providerName: vendor.name,));
                      },
                      radius: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.7), width: 1),
                        ),
                        child: Text('view'.tr, style: robotoMedium.copyWith(fontSize: 14)),
                      ),
                    )
                  ])
                ),


                vendor.announcement == 1 ? Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange.withValues(alpha: 0.06),
                    border: Border.all(color: Colors.orange, width: 0.1)
                  ),
                  child: Row(children: [

                    Image.asset(Images.announcement, height: 20, width: 20, color: Colors.orange),
                    const SizedBox(width: 10),

                    Expanded(child: Text(vendor.announcementMessage ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), softWrap: true)),

                  ]),
                ) : const SizedBox(),

                vendor.discount != null ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
                  child: Text('${vendor.discount!.discountType == 'percent' ? '${vendor.discount!.discount}% '
                      : '${PriceConverter.convertPrice(vendor.discount!.discount)} ${'off'.tr}'} '
                      '${'discount_will_be_applicable_when_booking_amount_is_more_then'.tr} ${PriceConverter.convertPrice(vendor.discount!.minPurchase)},'
                      ' ${'Max'.tr} ${PriceConverter.convertPrice(vendor.discount!.maxDiscount)} ${'discount_is_applicable'.tr}.',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Colors.white,
                    ),
                  ),
                ) : const SizedBox(),

                ProviderBannerWidget(taxiVendorController: vendorController),

                searchName.isNotEmpty ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    RichText(text: TextSpan(children: <TextSpan>[

                      TextSpan(text: '${vendorController.taxiVendorVehicleList?.totalSize??0} ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),

                      TextSpan(text: 'result_found_for'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),

                      TextSpan(text: ' $searchName', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color))

                    ])),

                    InkWell(
                      onTap: () async {
                        setState(() {
                          searchName = '';
                        });
                        await vendorController.getVendorVehicleList(offset: 1, vendorId: widget.vendorId!, searchName: searchName, canUpdate: false);
                      },
                      child: Icon(Icons.close, size: Dimensions.fontSizeExtraLarge, color: Colors.grey),
                    ),
                  ]),
                ) : const SizedBox(),
              ]),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: SliverDelegate(
              height: 100,
              child: SearchAndFilterWidget(
                taxiVendorController: vendorController,
                vendorId: widget.vendorId,
                searchName: searchName,
                searchCallback: (name) async {
                if(name != null) {
                  searchName = name;
                  await vendorController.getVendorVehicleList(offset: 1, vendorId: widget.vendorId!, searchName: name, canUpdate: false);
                }
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: vendorController.taxiVendorVehicleList != null ? vendorController.taxiVendorVehicleList!.vehicles!.isNotEmpty ? PaginatedListView(
              scrollController: _scrollController,
              onPaginate: (int? offset) async => vendorController.getVendorVehicleList(offset: offset!, vendorId: widget.vendorId!),
              totalSize: vendorController.taxiVendorVehicleList?.totalSize,
              offset: vendorController.taxiVendorVehicleList?.offset,
              itemView:  ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: vendorController.taxiVendorVehicleList!.vehicles!.length,
                padding: const EdgeInsets.only(bottom: 50),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return VendorVehicleCard(vehicle: vendorController.taxiVendorVehicleList!.vehicles![index]);
                },
              ),
            ) : NoDataScreen(text: 'no_vehicle_available'.tr) : const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: CircularProgressIndicator(),
            )),
          ),
        ]);
      }),
    );

  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
