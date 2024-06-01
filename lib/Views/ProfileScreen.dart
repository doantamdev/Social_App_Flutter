import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/global.dart';
import 'controllers/PresenceHub.dart';


class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>{
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final PresenceHubController presenceHub = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
              onPressed: ()async{
                final SharedPreferences prefs = await _prefs;
                // Remove data
                final success = await prefs.remove('user');
                //render login page
                Global.myStream!.signOut();
                Global.clearData();
                presenceHub.stopHubConnection();
              },
              icon: const Icon(Icons.logout)
          )
        ],
      ),
      body: Center(
        child: Row(
          children: [
            TextButton(
                onPressed: (){
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TraLoiCuocGoiDenScreen()),
                  );*/
                },
                child: const Text('Cuoc goi den')
            )
          ],
        ),
      ),
    );
  }
}