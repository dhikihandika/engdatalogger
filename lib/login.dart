import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:engdatalogger/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            parametrikSection(),
            headerSection(),
            textSection(),
            buttonSection(),

          ],
        ),
      ),
    );
  }

  signIn(String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'email': email,
      'password': password
    };
    var jsonResponse = null;
    var apiKey = "http://192.168.1.28:8081/";
    var response = await http.post(Uri.parse(apiKey), body: data);
    if(response.statusCode == 200) {
      print(response.body); print(response.statusCode);
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
          print(jsonResponse);
          sharedPreferences.setString("token", jsonResponse['token']);      // Json fromat {"token":"...."}
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
        });
      }
    }
    else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("engdatalogger",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  Container parametrikSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0, bottom: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      alignment: Alignment.center,
      child: Text("parametrik",
          style: TextStyle(
            color: Colors.lightGreen,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,)),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Email",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: emailController.text == "" || passwordController.text == "" ? null : () {
          setState(() {
            _isLoading = true;
          });
          signIn(emailController.text, passwordController.text);
        },
        elevation: 0.0,
        color: Colors.lightGreen,
        child: Text("Sign In", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }
}