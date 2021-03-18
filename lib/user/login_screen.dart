import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/main_screen.dart';
import 'package:myapp/system/MyStorage.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:myapp/user/registor_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  SystemInstance systemInstance = SystemInstance();
  TextEditingController _userName = TextEditingController();
  TextEditingController _passWord = TextEditingController();
  bool _isLoading = false;
  bool _passWordVisible = false;
  var userId;
  MyStorage myStorage;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();


  @override
  void initState() {
    super.initState();
    myStorage = new MyStorage();
    myStorage.readCounter().then((value){
      setState(() {
        userId = value;
        systemInstance.userId = userId.toString();
        print(userId);
      });
    });
  }

  signIn(String userName, passWord) async {
    Map params = {
      'username': userName,
      'password': passWord,
    };
    var jsonData = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post('${Config.API_URL}/authorize', body: params);
    if (response.statusCode == 200) {
      _isLoading = false;
      jsonData = jsonDecode(response.body);
      print(jsonData);
      systemInstance.token = jsonData['token'];
      sharedPreferences.setString('token', jsonData['token']);
      if(jsonData['status'] == 0){
        userId = jsonData['userId'];
        myStorage.writeCounter(userId);
        systemInstance.userId = userId.toString();
        
        String fcmToken = await firebaseMessaging.getToken();
        print("fcmToken=======>>>>>> ${fcmToken}");
        add_FCMToken(fcmToken); 

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainScreen()), (
            Route<dynamic> route) => false);
      }else{
        print('Login Faild');
        _isLoading = false;
        setState(() {

        });
        CoolAlert.show(context: context, type: CoolAlertType.warning,text: 'ชื่อหรือรหัสผ่านไม่ถูกต้อง');
      }
    } else {
      _isLoading = false;
      setState(() {
      });
      CoolAlert.show(context: context, type: CoolAlertType.warning,text: 'ไม่สามารถเชื่อมต่อกับระบบได้');
      print(response.body);
    }
  }
  
  add_FCMToken(String fcmToken) async{
    Map params = Map();
    params['idUserProfile'] = systemInstance.userId;
    params['fcmToken'] = fcmToken;
    var data = await http.post("${Config.API_URL}/user/add_FCMToken",body: params);
    var jsonData = jsonDecode(data.body);
    if(jsonData['status'] == 0){
      print('Add the FCMToken success');
    }else{
      print('Add the FCMToken fa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal,
                Colors.tealAccent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Text('กรุณาเข้าสู่ระบบ', style: TextStyle(color: Colors.white, fontSize: 25.0),),
            ),

            Icon(Icons.account_circle, size: 100, color: Colors.white),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              margin: EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.account_circle, color: Colors.white,),
                    title: TextField(
                      controller: _userName,
                    ),
                  ),

                  SizedBox(height: 1.0,),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.white,),
                    title: TextField(
                      controller: _passWord,
                      obscureText: !_passWordVisible,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passWordVisible ? Icons.visibility : Icons.visibility_off
                          ),
                          onPressed: (){
                            setState(() {
                              _passWordVisible = !_passWordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30.0),
              height: 40.0,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: RaisedButton(
                onPressed: () {
                  if(_userName.text.isNotEmpty & _passWord.text.isNotEmpty ){
                    signIn(_userName.text, _passWord.text);
                    setState(() {
                      _isLoading = true;
                    });
                  }else{
                    CoolAlert.show(context: context, type: CoolAlertType.warning,text: 'กรุณากรอกข้อมูลให้ครบถ้วน');
                  }

                },
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text("เข้าสู่ระบบ", style: TextStyle(fontSize: 18.0, color: Colors.white),),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15.0),
              height: 40.0,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RegistorScreen()));
                },
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text("ลงทะเบียน", style: TextStyle(fontSize: 18.0, color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


