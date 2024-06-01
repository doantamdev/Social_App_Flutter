import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:social_app/Views/widgets/UserItem.dart';

import '../Utils/global.dart';
import 'DetailChatScreen.dart';
import 'controllers/PresenceHub.dart';
import 'widgets/UserInfor.dart';



class ChatScreen extends StatefulWidget{
  const ChatScreen({super.key});

  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
{
  final PresenceHubController presenceHub = Get.find();

  @override
  void initState() {
    presenceHub.fetchLastMessages().then((value) => {
      if(value != '200'){
        Fluttertoast.showToast(
            msg: value,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        )
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Global.user!.displayName),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Obx(()=>Text('${presenceHub.users.length} online', style: const TextStyle(fontWeight: FontWeight.bold),),),
              SizedBox(
                  height: 110,
                  child: Obx(()=>ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: presenceHub.users.length,
                      itemBuilder: (context, index)=> UserInfor(
                        imageUrl: presenceHub.users[index].photoUrl,
                        displayName: presenceHub.users[index].displayName!,
                      )
                  ),)
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 90,
                child: Obx(()=>presenceHub.isLoading.value == true ? const Center(
                  child: CircularProgressIndicator(),
                ): ListView.builder(
                    itemCount: presenceHub.lastMessages.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: (){
                        presenceHub.clearUnreadMessage(presenceHub.lastMessages[index].senderUsername);
                        Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => DetailChatScreen(userName: presenceHub.lastMessages[index].senderUsername,)),
                        );
                      },
                      child: UserItem(username: presenceHub.lastMessages[index].senderUsername,
                        displayName: presenceHub.lastMessages[index].senderDisplayName,
                        content: presenceHub.lastMessages[index].content,
                        imageUrl: presenceHub.lastMessages[index].senderImgUrl,
                        unreadMessage: presenceHub.lastMessages[index].unreadCount,
                      ),
                    )
                )),
              )
            ],
          ),
        )
    );
  }
}