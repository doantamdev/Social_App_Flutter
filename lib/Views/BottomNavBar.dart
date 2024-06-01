import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/member.dart';
import '../Utils/const.dart';
import '../Utils/global.dart';
import 'CuocGoiDenScreen‎.dart';
import 'controllers/PresenceHub.dart';

class BottomNavBar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return BottomNavBarState();
  }
}

class BottomNavBarState extends State<BottomNavBar>{
  final presenceHubController = Get.put(PresenceHubController());
  int pageIndex = 0;


  @override
  void initState() {
    presenceHubController.createHubConnection(Global.user);
    // call from presenceHub
    Global.myStream!.navigateScreenStream.listen((event) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CuocGoiDenScreen(member: event as Member,)),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: CupertinoTabBar(
        onTap: (index){
          setState(() {
            pageIndex = index;
          });
        },
        currentIndex: pageIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat, size: 35,), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.group, size: 35,), label: 'Group'),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed, size: 35,), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.account_box, size: 35,), label: 'Profile'),
        ],),
    );
  }
}