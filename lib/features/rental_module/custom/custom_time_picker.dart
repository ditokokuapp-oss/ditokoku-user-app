import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/rental_location_screen/controller/taxi_location_controller.dart';

import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../helper/time_picker_spinner.dart';

class CustomTimePicker extends StatefulWidget {
  final DateTime? selectTripTime;
  final Function(DateTime) callback;
  final Function(bool) scrollOff;
  const CustomTimePicker({super.key, this.selectTripTime, required this.callback, required this.scrollOff}) ;

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {

  @override
  void initState() {
    super.initState();

    Get.find<TaxiLocationController>().setTripDate(widget.selectTripTime??DateTime.now(), willUpdate: false);
    Get.find<TaxiLocationController>().setTripTime(widget.selectTripTime??DateTime.now(), willUpdate: false);

  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault ),
      child: TimePickerSpinner(
        time: widget.selectTripTime,
        is24HourMode: false,
        normalTextStyle: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5), fontSize: Dimensions.fontSizeSmall),
        highlightedTextStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge*1, color: Theme.of(context).textTheme.bodyLarge!.color),
        spacing: Dimensions.paddingSizeDefault,
        itemHeight: Dimensions.fontSizeLarge + 2,
        itemWidth: 50,
        alignment: Alignment.topCenter,
        isForce2Digits: true,
        onTimeChange: widget.callback,
        scrollOff: widget.scrollOff,

      ),
    );
  }
}