import 'package:flutter/material.dart';

class PopularDestinationsModel{
  final IconData? logo;
  final String? place;
  final String? address;

  const PopularDestinationsModel({
    required this.logo,
    required this.place,
    required this.address
  });
}