import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveOrder extends StatefulWidget {
  final int idOrderList;
  final String shopName;
  ActiveOrder(this.idOrderList, this.shopName);

  @override
  _ActiveOrderState createState() => _ActiveOrderState(this.idOrderList, this.shopName);
}

class _ActiveOrderState extends State<ActiveOrder> {
  _ActiveOrderState(this.idOrderList,this.shopName);
  SystemInstance systemInstance = SystemInstance();
  int idOrderList, totalPrice, idUserShop;
  String shopName, dateTime="..........", shopPhone, latitude, longtitude;
  List lstProducts = List();
  Future<void> _launched;

  @override
  void initState() {
    getDetail();
    super.initState();
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _openOnGoogleMapApp(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      // Could not open the map.
    }
  }
  
  Future<Response> getDetail() async {
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.post('${Config.API_URL}/order/productbyid?idOrderList=${idOrderList}',headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    var jsonP = jsonData['productList'];
    setState(() {
      idUserShop = jsonData['idUserShop'];
      lstProducts = jsonDecode(jsonP);
      idOrderList = jsonData['idOrderList'];
      totalPrice = jsonData['totalPrice'];
      dateTime = jsonData['timeReceive'];
    });
    getData();
  }

  getData() async{
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.post('${Config.API_URL}/shop/detail?idUserShop=${idUserShop}',headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    shopPhone = jsonData['shopPhone'];
    latitude = jsonData['latitude'];
    longtitude = jsonData['longtitude'];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopName),
        actions: [
          Row(
            children: [
              InkWell(
                child: Text('ติดต่อ', style: TextStyle(fontSize: 18.0),),
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          content: Container(
                            height: 130.0,
                            width: 200.0,
                            child: Column(
                              children: [
                                Text('เลือกช่องทาง'),
                                SizedBox(height: 15.0,),
                                Container(
                                  child: RaisedButton(
                                    child: Row(
                                      children: [
                                        Icon(Icons.phone, color: Colors.white,),
                                        SizedBox(width: 40.0,),
                                        Text('โทรศัพท์', style: TextStyle(fontSize: 18.0, color: Colors.white),),
                                      ],
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _launched = _makePhoneCall('tel:$shopPhone');
                                      });
                                    },
                                    color: Colors.teal,
                                  ),
                                  width: 200.0,
                                ),
                                Container(
                                  child: RaisedButton(
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_pin, color: Colors.white,),
                                        SizedBox(width: 40.0,),
                                        Text('ตำแหน่งร้าน', style: TextStyle(fontSize: 18.0, color: Colors.white),),
                                      ],
                                    ),
                                    onPressed: (){
                                      _openOnGoogleMapApp(double.parse(latitude), double.parse(longtitude));
                                    },
                                    color: Colors.teal,
                                  ),
                                  width: 200.0,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  );
                },
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
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  child: Row(
                    children: [
                      SizedBox(width: 10.0,),
                      Text((index + 1).toString() + ' . ' + item['productName'], style: TextStyle(fontSize: 14.0),),
                      SizedBox(width: 40.0,),
                      Spacer(),
                      Text('x  ' + item['numberOfItem'].toString() + '    ราคา  '
                          + (item['productPrice'] * item['numberOfItem']).toString(),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(width: 10.0,),
                    ],
                  )
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
                      title: Text("วันที่รับสินค้า(ป/ด/ว) ${dateTime.toString().substring(0,10)}",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),)),
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
                        Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
                        http.post('${Config.API_URL}/order/update_status/',body: params, headers:header ).then((response){
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
                        "รับสินค้าแล้ว",
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
                        Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
                        http.post('${Config.API_URL}/order/update_status/',body: params,headers: header).then((response){
                            Map retMap = jsonDecode(response.body);
                            int status = retMap['status'];
                            if(status == 0){
                              CoolAlert.show(context: context, type: CoolAlertType.success,text: "ทำรายการสำเร็จ");
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
              ],
            )
          ],
        ),
      ),
    );
  }
}
