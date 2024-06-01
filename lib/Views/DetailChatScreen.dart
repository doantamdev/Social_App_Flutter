import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_app/Views/widgets/imageAvatar.dart';
import '../Models/member.dart';
import '../Utils/const.dart';
import '../Utils/global.dart';
import '../services/userService.dart';
import 'CuocGoiDiScreen.dart';
import 'controllers/messageHub.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetailChatScreen extends StatefulWidget{
  final String userName;

  const DetailChatScreen({super.key, required this.userName});

  @override
  State<StatefulWidget> createState() {
    return DetailChatScreenState();
  }
}

class DetailChatScreenState extends State<DetailChatScreen>{
  final TextEditingController contentController = TextEditingController();
  final MessagesHubController messageHubCtr = Get.put(MessagesHubController());
  final ScrollController _controller = ScrollController();

  Member member = Member(
      unReadMessageCount: 0,
      userName: '',
      displayName: '',
      lastActive: DateTime.now(),
      photoUrl: null
  );

  void scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    Global.myStream!.scrollDownStream.listen((event) {
      final timer = Timer(const Duration(seconds: 1), () => scrollDown());
    });

    UserService().getMember(widget.userName).then((value) => {
      if(value.message == '200'){
        setState(() {
          member = value.data!;
        })
      }
    });
    messageHubCtr.createHubConnection(Global.user, widget.userName);
    //set timeout
    final timer = Timer(const Duration(seconds: 1), () => scrollDown());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // event exit chat screen with people, back button on app bar
                      messageHubCtr.stopHubConnection();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  ImageAvatar(maxRadius: 25, imageUrl: member.photoUrl,),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          member.displayName!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(timeago.format(member.lastActive!),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.video_call,
                      color: Colors.blue,
                      size: 30,
                    ),
                    onTap: (){
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CuocGoiDiScreen(username: widget.userName,)),
                      );*/
                    },
                  ),
                ],
              ),
            ),
          )
      ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height  - 220,
          child: Obx(()=>ListView.builder(
            controller: _controller,
            itemCount: messageHubCtr.messages.length,
            itemBuilder: (context, index){
              final leftOrRight = messageHubCtr.messages[index].senderUsername == Global.user?.username;
              return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Row(
                    mainAxisAlignment: leftOrRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leftOrRight ? Text(''): ImageAvatar(maxRadius: 15, imageUrl: member.photoUrl,),
                      const SizedBox(width: 5,),
                      Container(
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue[200],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          messageHubCtr.messages[index].content!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  )
              );
            },
          ),)
      ),
      bottomSheet: Container(
          padding: const EdgeInsets.all(5),
          height: 120,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          )
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      if(contentController.text.isNotEmpty){
                        messageHubCtr
                            .sendMessageToClient(widget.userName, contentController.text)
                            .then((val) => {
                          contentController.clear(),
                          scrollDown()
                        });
                      }
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: iconsCustom.length,
                      itemBuilder: (context, index) => buildIcons(index)
                  ),
                ),
              ),
              InkWell(
                child: const Icon(
                  Icons.video_call,
                  color: Colors.blue,
                  size: 30,
                ),
                onTap: (){
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CuocGoiDiScreen(username: widget.userName,)),
                      );
                },
              )
            ],
          )
      ),
    );
  }

  buildIcons(int index){
    return GestureDetector(
      onTap: (){
        contentController.text += iconsCustom[index];
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        child: Text(iconsCustom[index], style: const TextStyle(fontSize: 26),),
      ),
    );
  }
}