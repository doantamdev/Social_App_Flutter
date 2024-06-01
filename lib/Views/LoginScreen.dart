import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_app/services/authAsp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/UserLogin.dart';
import '../Models/user_response.dart';
import '../Utils/global.dart';

enum FormType { login, register }

class LoginScreen extends StatefulWidget{
  final VoidCallback onSignedIn;

  const LoginScreen({super.key, required this.onSignedIn});

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>{
  static final formKey = GlobalKey<FormState>();
  String _authHint = '';
  FormType _formType = FormType.login;
  final UserLogin _user = UserLogin(userName: '', password: '');
  String title = 'Login';
  bool loading = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (_formType == FormType.login) {
        setState(() {
          loading = true;
        });
        UserResponse resp = await AuthASP().signIn(_user.userName, _user.password);
        if (resp.error == '200') {
          Global.user = resp.user;
          widget.onSignedIn();
          //save local storages
          final SharedPreferences prefs = await _prefs;
          final json = jsonEncode(resp.user!.toJson());
          final counter = prefs.setString('user', json).then((bool success) {
            return 0;
          });
          Fluttertoast.showToast(
              msg: "Login success!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
        } else {
          setState(() {
            _authHint = resp.error!;
            loading = false;
          });
        }
      } else {
        /*UserResponse resp = await widget.auth.register(_user);
        if (resp.error == '200') {
          moveToLogin();
        } else {
          setState(() {
            _authHint = resp.error;
          });
        }*/
      }
    }
  }

  void moveToRegister() {
    formKey.currentState!.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
      title = 'Register';
    });
  }

  void moveToLogin() {
    formKey.currentState!.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
      title = 'Login';
    });
  }

  List<Widget> usernameAndPassword() {
    switch (_formType) {
      case FormType.login:
        return [
          Padding(
              padding: const EdgeInsets.all(5),
              child: TextFormField(
                key: const Key('userName'),
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Username'),
                autocorrect: false,
                validator: (val) =>
                val!.isEmpty ? 'Username can\'t be empty.' : null,
                onSaved: (val) => _user.userName = val!,
              )),
          Padding(
              padding: const EdgeInsets.all(5),
              child: TextFormField(
                key: const Key('password'),
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                autocorrect: false,
                validator: (val) =>
                val!.isEmpty ? 'Password can\'t be empty.' : null,
                onSaved: (val) => _user.password = val!,
              )),
        ];
      case FormType.register:
        return [
          Padding(
              padding: const EdgeInsets.all(5),
              child: TextFormField(
                key: const Key('DisplayName'),
                decoration: const InputDecoration(labelText: 'DisplayName'),
                obscureText: true,
                autocorrect: false,
                validator: (val) =>
                val!.isEmpty ? 'DisplayName can\'t be empty.' : null,
                onSaved: (val) => _user.password = val!,
              )),
          Padding(
              padding: const EdgeInsets.all(5),
              child: TextFormField(
                key: const Key('userName'),
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Username'),
                autocorrect: false,
                validator: (val) =>
                val!.isEmpty ? 'Username can\'t be empty.' : null,
                onSaved: (val) => _user.userName = val!,
              )),
          Padding(
              padding: const EdgeInsets.all(5),
              child: TextFormField(
                key: const Key('password'),
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                autocorrect: false,
                validator: (val) =>
                val!.isEmpty ? 'Password can\'t be empty.' : null,
                onSaved: (val) => _user.password = val!,
              )),
        ];
    }
  }

  List<Widget> submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return [
          ElevatedButton(
            onPressed: loading ? null : validateAndSubmit,
            child: loading ? const Center(
              child: CircularProgressIndicator(color: Colors.green,),
            ): const Text('Login'),
          ),
          ElevatedButton(
              onPressed: moveToRegister,
              child: const Text("Need an account? Register")),
        ];
      case FormType.register:
        return [
          ElevatedButton(
            onPressed: validateAndSubmit,
            child: const Text('register'),
          ),
          ElevatedButton(
              onPressed: moveToLogin,
              child: const Text("Have an account? Login")),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: usernameAndPassword() + submitWidgets(),
            ),
          ),
          Text(_authHint, style: const TextStyle(fontSize: 25),)
        ],
      ),
    );
  }
}