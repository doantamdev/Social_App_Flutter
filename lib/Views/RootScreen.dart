import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/user.dart';
import '../Utils/global.dart';
import 'BottomNavBar.dart';
import 'LoginScreen.dart';



enum AuthStatus {
  notSignedIn,
  signedIn,
}

class RootScreen extends StatefulWidget{
  const RootScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return RootScreenState();
  }
}

class RootScreenState extends State<RootScreen>
{
  AuthStatus authStatus = AuthStatus.notSignedIn;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const platform = MethodChannel('agu.chat/signalR');

  Future<void> startService(String token, String currentUsername) async {
    try {
      // comment dong nay neu app chay len bi crash, vi token bi het han
      await platform.invokeMethod('startSignalrService', {"token":token, "currentUsername": currentUsername});
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    Global.myStream!.counterStream.listen((event) {
      if(event){//print(event);
        _updateAuthStatus(AuthStatus.notSignedIn);
      }
    });

    //read from local storages
    final user = _prefs.then((SharedPreferences prefs) {
      var json = prefs.getString('user');
      if(json == null){
        _updateAuthStatus(AuthStatus.notSignedIn);
        return null;
      }
      Map<String, dynamic> userJson = jsonDecode(json);
      final tempUser = User.fromJson(userJson);
      Global.user = tempUser;
      //call to native android
      startService(Global.user!.token, Global.user!.username);
      _updateAuthStatus(AuthStatus.signedIn);
      return tempUser;
    });
    super.initState();
  }

  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return LoginScreen(onSignedIn: (){
          _updateAuthStatus(AuthStatus.signedIn);
        },);
      case AuthStatus.signedIn:
        return  BottomNavBar();
    }
  }

}



