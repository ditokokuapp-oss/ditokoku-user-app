import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class SearchTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final Function() onIconPressed;
  final Function(String value) onSubmit;
  final Function(String value) onChange;
  const SearchTextField({super.key, required this.textEditingController, required this.hintText, required this.onIconPressed, required this.onSubmit, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorHeight: Dimensions.paddingSizeLarge,
      autofocus: false,
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey.shade500),
        suffixIcon: IconButton(
          onPressed: onIconPressed,
          // onPressed: () {
          //   Get.back(result: searchController.text);
          // },
          icon: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: Dimensions.fontSizeExtraLarge),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: Dimensions.paddingSizeSmall),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: const BorderSide(color: Colors.grey, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: const BorderSide(color: Colors.grey, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: BorderSide(color: Colors.grey.shade400, width: 1)),
      ),
      onChanged: onChange,
      onSubmitted: onSubmit,
    );
  }
}
