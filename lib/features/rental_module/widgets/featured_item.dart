import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class FeatureItem extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final String text;
  final Color iconColor;

  const FeatureItem({super.key, this.icon, this.image, required this.text, required this.iconColor,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 5, spreadRadius: 0.5, offset: const Offset(0, 0))],
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: Padding(padding: const EdgeInsets.all(4),
          child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [

            icon != null ? Icon(icon, size: 16, color: iconColor) : Image.asset(image??'', height: 10, width: 10, color: Theme.of(context).textTheme.bodyLarge!.color!),
            SizedBox(width: icon != null ? 0 : 2),

            Text(' $text', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),

          ]),
        ),
      ),
    );
  }
}