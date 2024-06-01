import 'package:flutter/material.dart';

class ImageAvatar extends StatelessWidget{
  final String? imageUrl;
  final double maxRadius;
  const ImageAvatar({super.key, this.imageUrl, required this.maxRadius});

  buildImageAvarta(){
    return imageUrl != null
        ? NetworkImage(imageUrl!)
        : const AssetImage('assets/images/user.png');
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: buildImageAvarta(),
      maxRadius: maxRadius,
    );
  }
}