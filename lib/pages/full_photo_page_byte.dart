import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oilstock/constants/app_constants.dart';
import 'package:oilstock/constants/color_constants.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoBytePage extends StatelessWidget {
  final String byte;

  FullPhotoBytePage({Key? key, required this.byte}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppConstants.fullPhotoTitle,
            style: TextStyle(color: ColorConstants.primaryColor),
          ),
          centerTitle: true,
        ),
        body: Container(
            child: Image.memory(
          Base64Decoder().convert(byte),
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        )));
  }
}
