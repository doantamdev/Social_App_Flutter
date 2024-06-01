import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../Models/pagination.dart';
import '../../Utils/const.dart';
import '../../Models/comment.dart';
import '../../Utils/global.dart';
import 'imageAvatar.dart';

class ModalListComment extends StatefulWidget{
  final int postId;
  final int totalComments;

  const ModalListComment({super.key, required this.postId, required this.totalComments});

  @override
  State<StatefulWidget> createState() {
    return ModalListCommentState();
  }
}


class ModalListCommentState extends State<ModalListComment>{
  final TextEditingController contentController = TextEditingController();
  Pagination<Comment> paginationComment = Pagination(
      totalPages: 1,
      pageNumber: 1,
      pageSize: 5,
      count: 1,
      items: []
  );

  int pageNumber = 1;
  List<Comment> comments = [];//display data
  double opacity  = 0.0;

  Future<String> fetchComments(int pageNumber) async{
    String messageRes = '';
    try {
      setState(() {
        opacity = 1.0;
      });
      await Future.delayed(const Duration(seconds: 2));
      final uri = Uri.parse('$urlBase/api/comment?pageNumber=$pageNumber&pageSize=10&postId=${widget.postId}');

      var response = await http.get(uri, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user!.token}',
        HttpHeaders.contentTypeHeader: 'application/json',
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        final data = Pagination<Comment>.fromJson(json, Comment.fromJsonModel);
        paginationComment = data;
        setState(() {
          opacity  = 0.0;
          comments.addAll(data.items);
        });
        messageRes = '200';
      } else {
        messageRes = '${response.statusCode} ${response.body}';
        setState(() {
          opacity  = 0.0;
        });
      }
    } catch (e) {
      messageRes = e.toString();
      setState(() {
        opacity  = 0.0;
      });
    }
    return messageRes;
  }

  @override
  void initState() {
    fetchComments(pageNumber).then((value) => debugPrint(value));
    Global.myStream!.commentStream.listen((event) {
      final comment = event as Comment;
      if(comment.postId == widget.postId){
        setState(() {
          comments.add(comment);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Text('${widget.totalComments} comments',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
        ),
        child: Scaffold(
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
                        onPressed: () {
                          sendComment(contentController.text, widget.postId)
                              .then((value) => {
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
                            },
                            contentController.clear(),
                          });
                        },
                        backgroundColor: Colors.blue,
                        elevation: 0,
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
                  )
                ],
              )
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height - 170,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  if(pageNumber < paginationComment.totalPages){
                    pageNumber += 1;
                    fetchComments(pageNumber).then((value) => debugPrint(value));
                  }
                }
                return true;
              },
              child: ListView.builder(
                  itemCount: comments.length + 1,
                  itemBuilder: (context, index){
                    if(index == comments.length){
                      return Opacity(
                        opacity: opacity,
                        child: const Center(child: CircularProgressIndicator(color: Colors.deepOrange,),),
                      );
                    }
                    return buildUserAndComment(context, index);
                  }
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> sendComment(String noiDung, int postId) async{
    String messageRes = '';
    try {
      final uri = Uri.parse('$urlBase/api/comment?noidung=$noiDung&postId=$postId');

      var response = await http.post(uri, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user!.token}',
        HttpHeaders.contentTypeHeader: 'application/json',
      });

      if (response.statusCode == 200) {
        messageRes = '200';
      } else {
        messageRes = '${response.statusCode} ${response.body}';
      }
    } catch (e) {
      messageRes = e.toString();
    }
    return messageRes;
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

  buildUserAndComment(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        children: [
          ImageAvatar(maxRadius: 20, imageUrl: comments[index].userImageUrl,),
          const SizedBox(
            width: 4,
          ),
          Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comments[index].displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RichText(
                      text: TextSpan(
                        text: comments[index].noiDung,
                        style: DefaultTextStyle.of(context).style,
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}