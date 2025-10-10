import 'package:flutter/material.dart';
import 'package:sixam_mart/util/styles.dart';

class EstimateTimeInput extends StatelessWidget {

  const EstimateTimeInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Ex: 5',
              hintStyle: robotoRegular.copyWith (color: Colors.grey[400], fontSize: 14,),
              labelText: 'Estimate Time',
              labelStyle: robotoRegular.copyWith(color: Colors.grey[600], fontSize: 12,),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey.shade50, width: 1,),
              ),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1,),
              ),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5,),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 13,),
            ),
          ),
        ),
      ],
    );
  }
}
