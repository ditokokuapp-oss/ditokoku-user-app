import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/new_tag.dart';
import 'package:sixam_mart/features/rental_module/common/widgets/taxi_add_favourite_view.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class VehicleDetailsBanner extends StatefulWidget {
  final TaxiHomeController taxiHomeController;
  final double discount;
  final String discountType;
  const VehicleDetailsBanner({super.key, required this.taxiHomeController, required this.discount, required this.discountType});

  @override
  State<VehicleDetailsBanner> createState() => _VehicleDetailsBannerState();
}

class _VehicleDetailsBannerState extends State<VehicleDetailsBanner> {
  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {

    return widget.taxiHomeController.vehicleDetailsModel != null && widget.taxiHomeController.vehicleDetailsModel!.imagesFullUrl != null && widget.taxiHomeController.vehicleDetailsModel!.imagesFullUrl!.isNotEmpty ? Column(children: [

      Stack(children: [

        CarouselSlider.builder(
          options: CarouselOptions(
            height: 180, autoPlay: true, viewportFraction: 1,
            aspectRatio: 16 / 5,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          itemCount: widget.taxiHomeController.vehicleDetailsModel!.imagesFullUrl!.length,
          itemBuilder: (context, index, _) {
            String image = (widget.taxiHomeController.vehicleDetailsModel != null && widget.taxiHomeController.vehicleDetailsModel?.imagesFullUrl != null) ? widget.taxiHomeController.vehicleDetailsModel!.imagesFullUrl![index] : '';
            return CustomImage(image: image, fit: BoxFit.cover, width: double.infinity,);
          },
        ),

        Positioned(
          right: 10, top: 10,
          child: TaxiAddFavouriteView(
            favIconSize: 28,
            vehicle: widget.taxiHomeController.vehicleDetailsModel!,
          ),
        ),

        DiscountTag(
          fromTop: 27,
          discount: widget.discount, discountType: widget.discountType,
          freeDelivery: false, isFloating: false,
        ),

        Positioned(
          left: 0, top: 0,
          child: NewTag(isNew: widget.taxiHomeController.vehicleDetailsModel!.newTag),
        ),

      ]),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      // Smooth Page Indicator
      Center(
        child: AnimatedSmoothIndicator(
          activeIndex: _currentCarouselIndex,
          count: widget.taxiHomeController.vehicleDetailsModel!.imagesFullUrl!.length,
          effect: ScrollingDotsEffect(dotHeight: 6, dotWidth: 6, activeDotColor: Theme.of(context).primaryColor, dotColor: Colors.black26, spacing: 8)
        )
      ),
    ]) : const SizedBox();
  }
}
