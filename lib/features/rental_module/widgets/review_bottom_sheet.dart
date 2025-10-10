import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/rental_module/common/models/trip_details_model.dart';
import 'package:sixam_mart/features/rental_module/rental_order/controllers/taxi_order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ReviewBottomSheet extends StatefulWidget {
  final List<VehicleIdentity> vehicleList;
  const ReviewBottomSheet({super.key, required this.vehicleList});

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  PageController pageController = PageController(initialPage: 0);
  List<int> ratingList = [];
  List<TextEditingController> commentList = [];
  int _currentCarouselIndex = 0;

  List<VehicleIdentity> formatedVehicleList = [];
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    for (int i=0; i<widget.vehicleList.length; i++) {
      if(widget.vehicleList[i].rating == null) {
        formatedVehicleList.add(widget.vehicleList[i]);
        ratingList.add(0);
        commentList.add(TextEditingController());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, minHeight: 100),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          width: 33, height: 5,
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(23.0)),
        ),

        Container(alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.close, size: 24, color: Colors.grey[300]),
          ),
        ),

        Expanded(child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('how_was_your_trip'.tr, style: robotoMedium),

              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 42),
                child: Text('give_us_your_valuable_review'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),
              ),

              SizedBox(
                height: 360,
                child: PageView.builder(
                  itemCount: formatedVehicleList.length, // Number of pages
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int pageIndex) {
                    setState(() {
                      _currentCarouselIndex = pageIndex;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Column(children: [

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImage(
                            height: 100, width: 200, fit: BoxFit.cover,
                            image: formatedVehicleList[index].vehicleThumbnail ??'',
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          formatedVehicleList[index].vehicleName??'',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                        ),

                        Text('${'license_no'.tr}: ${formatedVehicleList[index].licensePlateNumber}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5))),


                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        SizedBox(
                          height: 30,
                          child: ListView.builder(
                            itemCount: 5,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return InkWell(
                                child: Icon(
                                  ratingList[index] < (i + 1) ? Icons.star_border : Icons.star,
                                  size: 25,
                                  color: ratingList[index] < (i + 1) ? Theme.of(context).disabledColor
                                      : Theme.of(context).primaryColor,
                                ),
                                onTap: () {
                                  setState(() {
                                    ratingList[index] = i + 1;
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        Text(
                          ratingList[index] == 1 ? 'bad'.tr :
                          ratingList[index] == 2 ? 'average'.tr :
                          ratingList[index] == 3 ? 'good'.tr :
                          ratingList[index] == 4 ? 'best'.tr :
                          ratingList[index] == 5 ? 'excellent'.tr
                              : '',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          // child: CustomTextField(
                          //   maxLines: 3,
                          //   capitalization: TextCapitalization.sentences,
                          //   controller: commentList[index],
                          //   labelText: '${'review'.tr}...',
                          // ),
                          child: CustomTextField(
                            controller: commentList[index],
                            titleText: 'type_here'.tr,
                            showLabelText: false,
                            maxLines: 3,
                            inputType: TextInputType.multiline,
                            inputAction: TextInputAction.done,
                            capitalization: TextCapitalization.sentences,
                          ),
                        ),

                      ]),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _currentCarouselIndex,
                    count: formatedVehicleList.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 6, dotWidth: 6, activeDotColor: Theme.of(context).primaryColor,
                      dotColor: Theme.of(context).disabledColor, spacing: 5,
                    ),
                  ),
                ),
              ),

            ])
          ]),
        )),

        if(View.of(context).viewInsets.bottom == 0.0)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(children: [

              GetBuilder<TaxiOrderController>(
                builder: (taxiOrderController) {
                  return CustomButton(
                    buttonText: _currentCarouselIndex < formatedVehicleList.length-1 ? 'submit_and_next'.tr : 'submit'.tr,
                    isLoading: taxiOrderController.isLoading,
                    onPressed: (){
                      int rating = ratingList[_currentCarouselIndex];
                      String comment = commentList[_currentCarouselIndex].text;
                      if(rating == 0) {
                        showCustomSnackBar('please_select_your_rating'.tr, getXSnackBar: true);
                      } else if(comment.isEmpty) {
                        showCustomSnackBar('please_write_your_comment'.tr, getXSnackBar: true);
                      } else {
                        submitOrSkip(taxiOrderController, rating, comment);
                      }
                    },
                  );
                }
              ),

              TextButton(
                  onPressed: (){
                    if(_currentCarouselIndex < formatedVehicleList.length-1) {
                      pageController.jumpToPage(_currentCarouselIndex + 1);
                    } else {
                      Get.back();
                    }
                  },
                  child: Text(
                    _currentCarouselIndex < formatedVehicleList.length-1 ? 'skip_for_now'.tr : 'cancel'.tr,
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                  ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  void submitOrSkip(TaxiOrderController taxiOrderController, int rating, String comment) {
    taxiOrderController.addVehicleReview(
      tripId: formatedVehicleList[_currentCarouselIndex].tripId!,
      vehicleId: formatedVehicleList[_currentCarouselIndex].vehicleId!,
      vehicleIdentityId: formatedVehicleList[_currentCarouselIndex].vehicleIdentityId!,
      rating: rating, comment: comment,
    ).then((success) {
      if(success) {
        taxiOrderController.getTripDetails(formatedVehicleList[_currentCarouselIndex].tripId!);
        if(_currentCarouselIndex < formatedVehicleList.length-1) {
          pageController.jumpToPage(_currentCarouselIndex + 1);
        } else {
          Get.back();
        }
      }
    });
  }
}
