import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class MyPhotoView extends StatelessWidget {

  final bool isFromFile;
  final String imagePath;

  const MyPhotoView({Key key, this.isFromFile = false,@required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
          imageProvider: isFromFile ? FileImage(File(imagePath)) : NetworkImage(imagePath),
        )
    );
  }
}
