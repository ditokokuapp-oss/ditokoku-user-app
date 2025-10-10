import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {

  const CustomSlider({super.key});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  RangeValues _currentRangeValues = const RangeValues(40, 80);

  @override
  Widget build(BuildContext context) {

    return RangeSlider(
      values: _currentRangeValues,
      max: 100,
      divisions: 5,
      activeColor: Theme.of(context).primaryColor,
      labels: RangeLabels(
        _currentRangeValues.start.round().toString(),
        _currentRangeValues.end.round().toString(),
      ),
      onChanged: (RangeValues values) {
        setState(() {
          _currentRangeValues = values;
        });
      },
    );
  }
}
