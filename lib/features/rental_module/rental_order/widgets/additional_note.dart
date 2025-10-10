import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/styles.dart';
class AdditionalNote extends StatelessWidget {
  final String? note;
  const AdditionalNote({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    return note != null ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text('additional_note'.tr, style: robotoBold.copyWith(fontSize: 14)),
        const SizedBox(height: 10),

        Text(note!, style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade700))

      ]),
    ) : const SizedBox();
  }
}
