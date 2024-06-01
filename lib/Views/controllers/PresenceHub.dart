import 'package:signalr_netcore/signalr_client.dart';
import 'package:get/get.dart';

import '../../Models/LastMessageChat.dart';
import '../../Models/member.dart';
import '../../Models/user.dart';
import '../../Utils/const.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../Utils/global.dart';
import '../../Models/comment.dart';

class PresenceHubController extends GetxController {
  var users = <Member>[].obs;
  var isLoading = false.obs;
  var lastMessages = <LastMessageChat>[].obs;
  HubConnection? _hubConnection;

  void createHubConnection(User? user) {
    if (_hubConnection == null) {
      _hubConnection = HubConnectionBuilder()
          .withUrl("${hubUrl}presence",
          options: HttpConnectionOptions(
              accessTokenFactory: () async => user!.token))
          .build();

      _hubConnection!.onclose(({Exception? error}) => _myFunction(error));

      if (_hubConnection!.state != HubConnectionState.Connected) {
        _hubConnection!.start()?.catchError(
                (e) => {print("PresenceService at Start: $e")});
      }

      _hubConnection!.on("UserIsOnline", _userIsOnline);
      _hubConnection!.on("UserIsOffline", _userIsOffline);
      _hubConnection!.on("GetOnlineUsers", _getOnlineUsers);
      _hubConnection!.on("NewMessageReceived", _newMessageReceived);
      _hubConnection!.on("BroadcastComment", _broadcastCommentReceived);
      _hubConnection!.on("DisplayInformationCaller", _displayInformationCallerReceived);
    }
  }

  _myFunction(Exception? error) => print(error.toString());

  void _userIsOnline(List<Object?>? parameters) {
    final memberServer = parameters![0] as Map<String, dynamic>;
    final member = Member.fromJson(memberServer);
    users.add(member);
  }

  void _userIsOffline(List<Object?>? parameters) {
    final String username = parameters![0].toString();
    for (var user in users) {
      if (user.userName == username) {
        users.remove(user);
        break;
      }
    }
  }

  void _getOnlineUsers(List<Object?>? parameters) {
    final memberServer = parameters![0] as List<dynamic>;
    final listMember = memberServer.map<Member>((json) => Member.fromJson(json)).toList();
    users.value = listMember;
  }

  void _newMessageReceived(List<Object?>? parameters) {
    final memberServer = parameters![0] as Map<String, dynamic>;
    final member = Member.fromJson(memberServer);

    int index = lastMessages.indexWhere((f) => f.senderUsername == member.userName!); //message['senderUsername']
    if (index != -1) {
      lastMessages[index].unreadCount++;
      lastMessages[index] = lastMessages[index];
    }
  }

  void _broadcastCommentReceived(List<Object?>? parameters) {
    final json = parameters![0] as Map<String, dynamic>;
    final comment = Comment.fromJson(json);
    Global.myStream!.sendComment(comment);
  }

  void _displayInformationCallerReceived(List<Object?>? parameters) {
    final memberCallingJson = parameters![0] as Map<String, dynamic>;
    final channelName = parameters[1] as String;
    final memberCalling = Member.fromJson(memberCallingJson);
    Global.channelName = channelName;
    // show man hinh cuoc goi den
    Global.myStream!.navigateToScreen(memberCalling);// listen at bottom_navbar
  }

  void stopHubConnection() {
    _hubConnection!
        .stop()
        .catchError((e) => {print("Presence hub at Stop: $e")});
    _hubConnection = null;
  }

  Future<void> callToUser(String ortherUsername, String channelName) async{
    await _hubConnection!.invoke("CallToUsername", args: <Object>[
      ortherUsername, channelName
    ]);
  }

  void clearUnreadMessage(String userName) {
    final int index = lastMessages.indexWhere((f) => f.senderUsername == userName);
    if (index != -1) {
      lastMessages[index].unreadCount = 0;
      lastMessages[index] = lastMessages[index];
    }
  }

  Future<String> fetchLastMessages() async{
    String messageRes = '';
    try {
      isLoading.value = true;
      final uri = Uri.parse('$urlBase/api/LastMessageChats?pageNumber=1&pageSize=5');

      var response = await http.get(uri, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Global.user!.token}',
        HttpHeaders.contentTypeHeader: 'application/json',
      });

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        lastMessages.value = list.map<LastMessageChat>((json) => LastMessageChat.fromJson(json)).toList();
        messageRes = '200';
        isLoading.value = false;
      } else {
        messageRes = '${response.statusCode} ${response.body}';
        isLoading.value = false;
      }
    } catch (e) {
      messageRes = e.toString();
      isLoading.value = false;
    }
    return messageRes;
  }
}