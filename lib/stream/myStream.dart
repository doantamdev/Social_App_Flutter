import 'dart:async';
import '../Models/comment.dart';
import '../Models/member.dart';

class MyStream {
  //StreamController counterController = StreamController<bool>.broadcast();
  StreamController counterController = StreamController<bool>();
  Stream get counterStream => counterController.stream;

  StreamController scrollDownController = StreamController<bool>.broadcast();
  Stream get scrollDownStream => scrollDownController.stream;

  StreamController commentController = StreamController<Comment>.broadcast();
  Stream get commentStream => commentController.stream;

  StreamController navigateScreenController = StreamController<Member>.broadcast();
  Stream get navigateScreenStream => navigateScreenController.stream;

  void signOut() {
    counterController.sink.add(true);
  }

  void scrollDown() {
    scrollDownController.sink.add(true);
  }

  void sendComment(Comment comment){
    commentController.sink.add(comment);
  }

  void navigateToScreen(Member memberCalling){
    navigateScreenController.sink.add(memberCalling);
  }
}