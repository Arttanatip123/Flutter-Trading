
import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';

class ShopActiveOrder extends StatefulWidget {
  ShopActiveOrder(this.idOrderList, this.userName);
  final int idOrderList;
  final String userName;
  @override
  _ShopActiveOrderState createState() => _ShopActiveOrderState(this.idOrderList, this.userName);
}

class _ShopActiveOrderState extends State<ShopActiveOrder> {
  _ShopActiveOrderState(this.idOrderList, this.userName);
  int idOrderList,totalPrice,idUserProfile;
  String userName,dateTime="..........",shopPhone="";
  List lstProducts = List();
  Future<void> _launched;

  @override
  void initState() {
    getOrder();
    super.initState();
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Response> getOrder() async{
    var data = await http.post('${Config.API_URL}/order/productbyid?idOrderList=${idOrderList}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    var jsonP = jsonData['productList'];
    setState(() {
      idUserProfile = jsonData['idUserProfile'];
      lstProducts = jsonDecode(jsonP);
      totalPrice = jsonData['totalPrice'];
      dateTime = jsonData['timeReceive'];
    });
    getData();
  }
  
  getData() async{
    var data = await  http.post('${Config.API_URL}/user/user_detail?idUserProfile=${idUserProfile}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    setState(() {
      shopPhone = jsonData['phoneNumber'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        actions: [
          Row(
            children: [
              InkWell(
                child: shopPhone.isEmpty ? Text('') : Text('ติดต่อ', style: TextStyle(fontSize: 18.0),),
                onTap: (){
                  _launched = _makePhoneCall('tel:$shopPhone');
                }
              ),
            ],
          ),
          SizedBox(width: 20.0,)
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemCount: lstProducts.length,
          itemBuilder: (Context, index){
            var item = lstProducts[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0 ,vertical: 2.0),
              child: Row(
                children: [
                  SizedBox(width: 10.0,),
                  Text((index + 1).toString() + ' . ' + item['productName'],style: TextStyle(fontSize: 14.0),),
                  Spacer(),
                  Text('    x ' + item['numberOfItem'].toString() + '     ราคา  ' + item['productPrice'].toString() + 'บาท', style: TextStyle(fontSize: 14.0),),
                  SizedBox(width: 10.0,)
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 140.0,
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  height: 30.0,
                  child: ListTile(
                    leading: Icon(Icons.monetization_on_outlined),
                    title: Text("ราคารวม   ${totalPrice.toString()}  บาท",style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ),
                Container(
                  height: 40.0,
                  child: ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text("วันที่รับสินค้า(ป/ด/ว) ${dateTime.substring(0,10)}",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),)),
                ),
              ],
            ),
            SizedBox(height: 10.0,),
            Row(
              children: [
                SizedBox(width: 10.0,),
                Expanded(
                  child: Container(
                    height: 50,
                    child: RaisedButton(
                      child: Text(
                        "ยกเลิกคำสั่งซื้อ",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: (){
                        Map params = Map();
                        params['idOrderList'] = idOrderList.toString();
                        params['status'] = 3.toString();
                        http.post('${Config.API_URL}/order/update_status/',body: params).then((response){
                          Map retMap = jsonDecode(response.body);
                          int status = retMap['status'];
                          if(status == 0){
                            CoolAlert.show(context: context, type: CoolAlertType.success, text: "ยกเลิกคำสั่งซื้อแล้ว");
                            Navigator.pop(context);
                            setState(() {

                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10.0,),
                Expanded(
                  child: Container(
                    height: 50.0,
                    child: RaisedButton(
                      child: Text(
                        "ส่ง"
                            "สินค้าแล้ว",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: (){
                        Map params = Map();
                        params['idOrderList'] = idOrderList.toString();
                        params['status'] = 2.toString();
                        http.post('${Config.API_URL}/order/update_status/',body: params).then((response){
                          Map retMap = jsonDecode(response.body);
                          int status = retMap['status'];
                          if(status == 0){
                            Navigator.pop(context);
                            setState(() {

                            });
                            CoolAlert.show(context: context, type: CoolAlertType.success,text: "ทำรายการสำเร็จ");

                          }
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10.0,),
              ],
            )
          ],
        ),
      ),
    );
  }
}
