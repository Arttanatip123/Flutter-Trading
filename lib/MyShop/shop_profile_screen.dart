import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:myapp/MyShop/create_shop_screen.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;

class ShopProfileScreen extends StatefulWidget {
  @override
  _ShopProfileScreenState createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  SystemInstance systemInstance = SystemInstance();
  bool isSwitched = false;
  String userId, shopStatus;


  @override
  void initState() {
    super.initState();
    userId = systemInstance.userId;
    getData();
  }

  getData() async {
    var data = await http.post('${Config.API_URL}/shop/detail?idUserShop=${int.parse(userId)}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    print(jsonData);
    shopStatus = jsonData['shopStatus'];
    setState(() {
      shopStatus == "0" ? isSwitched = false : isSwitched = true;
    });
  }

  statusUpdate(bool status) async {
    String _status;
    status == false ? _status = 0.toString() : _status = 1.toString();
    Map params = Map();
    params['idUserShop'] = userId;
    params['shopStatus'] = _status;
    var data = await http.post('${Config.API_URL}/shop/status', body: params);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    if(jsonData['status'] == 0) {
      isSwitched = status;
    }else{
      CoolAlert.show(context: context, type: CoolAlertType.error, text: 'กรุณาตั้งค่าร้านค้าให้สมบูรณ์');
      setState(() {
        isSwitched = !isSwitched;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ร้านของฉํน'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(isSwitched == false ? 'ปิด' : 'เปิด'),
          ),
          Transform.scale(
            scale: 1.0,
            child: Switch(
              value: isSwitched,
              onChanged: (value){
                setState(() {
                  isSwitched = value;
                  statusUpdate(value);
                });
              },
              activeColor: Colors.teal[900],
              activeTrackColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            Divider(
              height: 12.0,
            ),
            ListTile(
              title: Text('ตั้งค่าร้านค้า', style: TextStyle(fontSize: 18.0),),
              subtitle: Text('กำหนดค่าต่าง ๆ ชื่อร้าน , ตำแหน่ง, รายละเอียด ฯลฯ'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.teal,
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CreateShop()));
              },
            ),
            Divider(
              height: 12.0,
            ),
          ],
        ),
      ),
    );
  }
}
