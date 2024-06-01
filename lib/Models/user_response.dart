import 'package:social_app/Models/user.dart';

class UserResponse {
  User? user;
  String? error;

  UserResponse();
  UserResponse.mock(this.user): error = "";
}