import 'package:get/get.dart';
import 'package:sixam_mart/features/review/widgets/rating_progress_widget.dart';
import 'package:sixam_mart/features/rental_module/vendor/widgets/taxi_rating_bar.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiProviderRatingWidget extends StatelessWidget {
  final double? averageRating;
  final int? ratingCount;
  final int? reviewCommentCount;
  final List<int>? ratings;
  const TaxiProviderRatingWidget({super.key, this.averageRating, this.ratingCount, this.reviewCommentCount, this.ratings});

  @override
  Widget build(BuildContext context) {
    // Add null check and default values
    List<double> percentages = [];
    List<double> progressForEach = [];

    if (ratings != null && ratings!.isNotEmpty) {
      int total = ratings!.reduce((value, element) => value + element);
      if (total > 0) {
        percentages = ratings!.map((rating) {
          return (rating / total) * 100;
        }).toList();
        progressForEach = calculateProgressForEach(percentages);
      }
    }

    // If no ratings, initialize with zeros
    if (percentages.isEmpty) {
      percentages = List.filled(5, 0.0);
      progressForEach = List.filled(5, 0.0);
    }

    return Row(children: [
      Expanded(
        flex: 2,
        child: Column(children: [
          Text('overall_rating'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),

          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeSmall),
            child: Text(
              averageRating?.toStringAsFixed(1) ?? '0.0',
              style: robotoBold.copyWith(fontSize: 30, color: Theme.of(context).primaryColor),
            ),
          ),

          TaxiRatingBar(rating: averageRating ?? 0, ratingCount: null, size: 18),
          const SizedBox(height: 6),

          RichText(text: TextSpan(children: <TextSpan>[
            TextSpan(
                text: '${ratingCount ?? 0} ',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey.shade900)
            ),
            TextSpan(
                text: 'ratings'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey.shade700)
            )
          ])),
        ]),
      ),

      Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        width: 1, height: 100,
        color: Theme.of(context).hintColor.withValues(alpha: 0.5),
      ),

      Expanded(
        flex: 3,
        child: Column(children: [
          RatingProgressWidget(ratingNumber: '5', ratingPercent: percentages[0], progressValue: progressForEach[0]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          RatingProgressWidget(ratingNumber: '4', ratingPercent: percentages[1], progressValue: progressForEach[1]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          RatingProgressWidget(ratingNumber: '3', ratingPercent: percentages[2], progressValue: progressForEach[2]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          RatingProgressWidget(ratingNumber: '2', ratingPercent: percentages[3], progressValue: progressForEach[3]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          RatingProgressWidget(ratingNumber: '1', ratingPercent: percentages[4], progressValue: progressForEach[4]),
        ]),
      ),
    ]);
  }

  List<double> calculateProgressForEach(List<double> percentages) {
    List<double> progressList = [];
    for (double percent in percentages) {
      double progress = percent / 100;
      progressList.add(progress);
    }
    return progressList;
  }
}

