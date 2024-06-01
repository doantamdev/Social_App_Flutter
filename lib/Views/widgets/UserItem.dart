import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get/get.dart';
import '../controllers/PresenceHub.dart';
import 'imageAvatar.dart';

class UserItem extends StatelessWidget{
  final String username;
  final String displayName;
  final String content;
  int unreadMessage = 0;
  String? imageUrl;
  final PresenceHubController presenceHub = Get.find();

  UserItem(
      {Key? key,
        required this.username,
        required this.displayName,
        required this.content,
        required this.imageUrl,
        required this.unreadMessage
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Stack(
                    children: [
                      ImageAvatar(imageUrl: imageUrl, maxRadius: 30,),
                      Obx(()=>presenceHub.users.firstWhereOrNull(
                              (element) => element.userName == username) !=
                          null ? const Positioned(
                          right: 0,
                          bottom: 1,
                          child: Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 20,
                          )): const Text('')),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            content,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            badges.Badge(
                badgeContent: getBadgeText()
            ),
          ],
        ));
  }

  Widget getBadgeText(){
    if(unreadMessage > 0){
      return Text(
          unreadMessage.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold));
    }
    return const Text("");
  }
}