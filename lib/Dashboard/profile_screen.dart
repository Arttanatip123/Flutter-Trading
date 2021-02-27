import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/user/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEdit = false;
  SystemInstance systemInstance = SystemInstance();
  TextEditingController _userName= TextEditingController();
  TextEditingController _passWord= TextEditingController();
  TextEditingController _firstName= TextEditingController();
  TextEditingController _lastName= TextEditingController();
  TextEditingController _phoneNumber= TextEditingController();
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController _newPassword = TextEditingController();
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    getData();
    super.initState();
  }
  Future getData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map params = Map();
    params['idUserProfile'] = systemInstance.userId;
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    http.post('${Config.API_URL}/user/user_detail', body: params, headers: header).then((response){
      Map retMap = jsonDecode(response.body);
      _userName.text = retMap['userName'];
      _passWord.text = retMap['passWord'];
      _firstName.text = retMap['firstName'];
      _lastName.text = retMap['lastName'];
      _phoneNumber.text = retMap['phoneNumber'];
      setState(() {

      });
    });
  }

  updateProfile() async {
    Map params = Map();
    params['idUserProfile'] = systemInstance.userId;
    params['userName'] = _userName.text;
    params['passWord'] = _passWord.text;
    params['firstName'] = _firstName.text;
    params['lastName'] = _lastName.text;
    params['phoneNumber'] = _phoneNumber.text;
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.post('${Config.API_URL}/user/user_update', body: params, headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
      if(jsonData['status'] == 0){
        CoolAlert.show(context: context, type: CoolAlertType.success, text: 'ทำรายการสำเร็จ');
      }else{
        CoolAlert.show(context: context, type: CoolAlertType.error, text: 'ทำรายการไม่สำเร็จ');
      }
  }

  Future passwordUpdate() async {
    Map params = Map();
    params['idUserProfile'] = systemInstance.userId;
    params['oldPassword'] = oldPassword.text;
    params['newPassword'] = newPassword.text;
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.post('${Config.API_URL}/user/update_password', headers: header, body: params);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    if(jsonData['status'] == 0){
      systemInstance.token = jsonData['token'];
      sharedPreferences.setString('token', jsonData['token']);

      Navigator.pop(context);
      oldPassword.text = '';
      newPassword.text = '';
      _newPassword.text = '';
      CoolAlert.show(context: context, type: CoolAlertType.success, text: 'ทำรายการสำเร็จ');

    }else{
      CoolAlert.show(context: context, type: CoolAlertType.error, text: 'ทำรายการไม่สำเร็จ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: Icon(Icons.lock_rounded),
              onPressed: (){
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        content: Container(
                          height: 270.0,
                          width: 200.0,
                          child: Column(
                            children: [
                              Text('เปลี่ยนรหัสผ่าน'),
                              SizedBox(height: 20.0,),
                              Container(
                                height: 50.0,
                                child: TextField(
                                  controller: oldPassword,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'รหัสผ่านเดิม',
                                    labelStyle: TextStyle(color: Colors.teal),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Container(
                                height: 50.0,
                                child: TextField(
                                  controller: newPassword,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'รหัสผ่านใหม่',
                                    labelStyle: TextStyle(color: Colors.teal),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Container(
                                height: 50.0,
                                child: TextField(
                                  controller: _newPassword,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'รหัสผ่านใหม่อีกครั้ง',
                                    labelStyle: TextStyle(color: Colors.teal),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RaisedButton(
                                    color: Colors.teal,
                                    child: Text('ยกเลิก', style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      Navigator.pop(context);
                                      oldPassword.text = '';
                                      newPassword.text = '';
                                      _newPassword.text = '';
                                    },
                                  ),
                                  SizedBox(width: 20.0,),
                                  RaisedButton(
                                    color: Colors.teal,
                                    child: Text('ยืนยัน', style: TextStyle(color: Colors.white),),
                                    onPressed: (){
                                      if(newPassword.text != _newPassword.text || oldPassword.text == '' || newPassword.text == ''){
                                        CoolAlert.show(context: context, type: CoolAlertType.warning, text: 'กรุณากรอกข้อมูลให้ถูกต้อง');
                                      }else{
                                        passwordUpdate();
                                      }
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                );
          }),
        ],
        title: Text('ข้อมูลของฉัน'),
      ),
      body: _userName.text.isEmpty ? Container(child: Center(child: Text('กำลังดาวน์โหลดข้อมูล...'),),) : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0,),
            Container(
              height: 45.0,
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Colors.teal,),
                title: TextField(
                  enabled: false,
                  readOnly: true,
                  controller: _userName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'UserName'
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0,),
            // Container(
            //   height: 45.0,
            //   child: ListTile(
            //     leading: Icon(Icons.lock, color: Colors.teal,),
            //     title: TextField(
            //       enabled: isEdit,
            //       controller: _passWord,
            //       decoration: InputDecoration(
            //         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
            //           border: OutlineInputBorder(),
            //           labelText: 'Password',
            //         labelStyle: TextStyle(color: Colors.teal),
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(height: 10.0,),
            Container(
              height: 45.0,
              child: ListTile(
                leading: Icon(Icons.label, color: Colors.teal,),
                title: TextField(
                  enabled: isEdit,
                  controller: _firstName,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      border: OutlineInputBorder(),
                      labelText: 'Firstname',
                    labelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0,),
            Container(
              height: 45.0,
              child: ListTile(
                leading: Icon(Icons.label, color: Colors.teal,),
                title: TextField(
                  enabled: isEdit,
                  controller: _lastName,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      border: OutlineInputBorder(),
                      labelText: 'Lastname',
                    labelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0,),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.teal,),
              title: Container(
                height: 45.0,
                child: TextField(
                  enabled: isEdit,
                  controller: _phoneNumber,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      border: OutlineInputBorder(),
                      labelText: 'Phone number',
                    labelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                isEdit == false ?
                InkWell(
                  child: Text('แก้ไข' , style: TextStyle(fontSize: 18.0, color: Colors.teal),),
                    onTap: (){
                    setState(() {
                      isEdit = !isEdit;
                    });

                },
                ):InkWell(
                  child: Text('อัพเดท', style: TextStyle(fontSize: 18.0, color: Colors.teal),),
                  onTap: (){
                    if(_passWord.text.isEmpty | _firstName.text.isEmpty | _lastName.text.isEmpty | _phoneNumber.text.isEmpty ){
                      CoolAlert.show(context: context, type: CoolAlertType.error, text: 'กรุณากรอกข้อมูลให้ครบถ้วน');
                    }else{
                      updateProfile();
                      setState(() {
                        isEdit = !isEdit;
                      });
                    }
                  },
                ),
                SizedBox(width: 20.0,),
              ],
            )
          ],
        ),
      ),
    );
  }
}

