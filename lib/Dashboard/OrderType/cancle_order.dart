import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/config.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/system/SystemInstance.dart';

class CancleOrder extends StatefulWidget {
  final int idOrderList;
  final String shopName;

  CancleOrder(this.idOrderList, this.shopName);

  @override
  _CancleOrderState createState() => _CancleOrderState(this.idOrderList, this.shopName);
}

class _CancleOrderState extends State<CancleOrder> {
  _CancleOrderState(this.idOrderList, this.shopName);
  SystemInstance systemInstance = SystemInstance();
  int idOrderList, totalPrice;
  String shopName, dateTime;
  List lstProducts = List();

  @override
  void initState() {
    getOrder();
    super.initState();
  }

  Future<Response> getOrder() async{
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.post('${Config.API_URL}/order/productbyid?idOrderList=${idOrderList}',headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    var jsonP = jsonData['productList'];

    setState(() {
      lstProducts = jsonDecode(jsonP);
      totalPrice = jsonData['totalPrice'];
      dateTime = jsonData['timeReceive'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shopName),
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
                    Text('x    ' + item['numberOfItem'].toString() + '    ราคา  '
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
        color: Colors.grey,
        height: 50.0,
        child: Row(
          children: [
            SizedBox(width: 20.0,),
            Text('ราม ' + totalPrice.toString() + ' บาท', style: TextStyle(fontSize: 18.0),),
          ],
        ),
      ),
    );
  }
}
