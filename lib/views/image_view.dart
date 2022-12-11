import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageView extends StatefulWidget {
  final String imageurl;

  const ImageView(this.imageurl, {Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    String url = widget.imageurl;
    print("=========>" + url);
    return Stack(
      children: <Widget>[
        PhotoView(imageProvider: CachedNetworkImageProvider(url)),
        Positioned(
          top: 100,
          right: 20,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 5)),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
      ],
    );

    GestureDetector(
        onLongPress: () {
          Navigator.pop(context);
        },
        child: PhotoView(imageProvider: CachedNetworkImageProvider(url)));
  }
}
