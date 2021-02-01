import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:myapp/user/login_screen.dart';


class RegistorScreen extends StatefulWidget {
  @override
  _RegistorScreenState createState() => _RegistorScreenState();
}

class _RegistorScreenState extends State<RegistorScreen> {
  TextEditingController _userName = TextEditingController();
  TextEditingController _passWord1 = TextEditingController();
  TextEditingController _passWord2 = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  void onClickRegistor() {
    CoolAlert.show(context: context, type: CoolAlertType.loading);
    Map<String, String> params = Map();
    params['userName'] = _userName.text;
    params['passWord'] = _passWord1.text;
    params['firstName'] = _firstName.text;
    params['lastName'] = _lastName.text;
    params['phoneNumber'] = _phoneNumber.text;
    // ignore: missing_return
    http.post('${Config.API_URL}/user/register', body: params).then((response) {
      Map retMap = jsonDecode(response.body);
      int status = retMap['status'];
      print(status);
      if (status == 0) {
        Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
      }else{
        CoolAlert.show(context: context, type: CoolAlertType.error, text: 'ทำรายการไม่สำเร็จ');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลงทะเบียน',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(icon: Icon(Icons.check),
              onPressed: (){
                if(_userName.text == '' || _passWord1.text == '' || _passWord2.text == '' || _firstName.text == '' || _lastName.text == '' || _phoneNumber.text == '' || _passWord1.text != _passWord2.text){
                  print('กรุณากรอกข้อมูลให้ถูกต้อง');
                  CoolAlert.show(context: context, type: CoolAlertType.warning, text: 'กรุณากรอกข้อมูลให้ครบถ้วน');
                }else{
                  onClickRegistor();
                }
              }
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        children: <Widget>[

          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.teal,),
            title: TextFormField(
              controller: _userName,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Username is required';
                }
              },
            ),
          ),

          ListTile(
            leading: Icon(Icons.lock, color: Colors.teal,),
            title: TextFormField(
              controller: _passWord1,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Password is required';
                }
              },
            ),
          ),

          ListTile(
            leading: Icon(Icons.lock, color: Colors.teal,),
            title: TextFormField(
              controller: _passWord2,
              decoration: const InputDecoration(
                labelText: 'Re-Password',
              ),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Re-Password is required';
                }
              },
            ),
          ),

          ListTile(
            leading: Icon(Icons.label, color: Colors.teal),
            title: TextField(
              controller: _firstName,
              decoration: InputDecoration(labelText: ' ชื่อจริง'),
            ),
          ),

          ListTile(
            leading: Icon(Icons.label, color: Colors.teal),
            title: TextField(
              controller: _lastName,
              decoration: InputDecoration(labelText: ' นามสกุล'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.teal),
            title: TextField(
              controller: _phoneNumber,
              decoration: InputDecoration(labelText: ' หมายเลขโทรศัพท์'),
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 20.0,),
          Container(
            height: 45.0,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.teal),
              ),
                color: Colors.teal,
                child: Text('ลงทะเบียน',style: TextStyle(fontSize: 20.0, color: Colors.white),),
                onPressed: (){
                  if(_userName.text == '' || _passWord1.text == '' || _passWord2.text == '' || _firstName.text == '' || _lastName.text == '' || _phoneNumber.text == '' || _passWord1.text != _passWord2.text){
                    print('กรุณากรอกข้อมูลให้ถูกต้อง');
                    CoolAlert.show(context: context, type: CoolAlertType.warning, text: 'กรุณากรอกข้อมูลให้ครบถ้วน');
                  }else{
                    onClickRegistor();
                  }
                },
            ),
          ),
          
          SizedBox(height: 100.0,),
          Center(
            child: InkWell(
              child: Text('กลับสู่หน้าล็อกอิน', style: TextStyle(fontSize: 18.0, color: Colors.teal),),
              onTap: (){
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
