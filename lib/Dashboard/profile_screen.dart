import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;

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
  @override
  void initState() {
    getData();
    super.initState();
  }
  getData() async {
    Map params = Map();
    params['idUserProfile'] = systemInstance.userId;
    http.post('${Config.API_URL}/user/user_detail', body: params).then((response){
      Map retMap = jsonDecode(response.body);
      _userName.text = retMap['userName'];
      _passWord.text = retMap['passWord'];
      _firstName.text = retMap['firstName'];
      _lastName.text = retMap['lastName'];
      _phoneNumber.text = retMap['phoneNumber'];
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
    var data = await http.post('${Config.API_URL}/user/user_update', body: params);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
      if(jsonData['status'] == 0){
        CoolAlert.show(context: context, type: CoolAlertType.success, text: 'ทำรายการสำเร็จ');
      }else{
        CoolAlert.show(context: context, type: CoolAlertType.error, text: 'ทำรายการไม่สำเร็จ');
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อมูลของฉัน'),
      ),
      body: SingleChildScrollView(
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
            Container(
              height: 45.0,
              child: ListTile(
                leading: Icon(Icons.lock, color: Colors.teal,),
                title: TextField(
                  enabled: isEdit,
                  controller: _passWord,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      border: OutlineInputBorder(),
                      labelText: 'Password',
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
                      labelText: 'Phone',
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
