import 'package:flutter/material.dart';

import 'imageAvatar.dart';

class UserInfor extends StatelessWidget{
  final String? imageUrl;
  final String displayName;

  const UserInfor({super.key, required this.imageUrl, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width*0.2,
      child: Column(
        children: [
          Stack(
            children: [
              ImageAvatar(imageUrl: imageUrl, maxRadius: 30,),
              Positioned(
                  right: 0,
                  bottom: 1,
                  child: const Icon(Icons.circle, color: Colors.green, size: 20,)
              )
            ],
          ),
          Text(displayName, overflow: TextOverflow.ellipsis,)
        ],
      ),
    );
  }
}