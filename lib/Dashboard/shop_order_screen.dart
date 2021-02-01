import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/BuyEvent/order_model.dart';
import 'package:myapp/Dashboard/OrderType/active_order.dart';
import 'package:myapp/Dashboard/OrderType/cancle_order.dart';
import 'package:myapp/Dashboard/OrderType/complete_order.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;

class ShopOrder extends StatefulWidget {
  @override
  _ShopOrderState createState() => _ShopOrderState();
}

class _ShopOrderState extends State<ShopOrder> {
  SystemInstance systemInstance = SystemInstance();
  List<Order> order1 = List<Order>();
  List<Order> order2 = List<Order>();
  List<Order> order3 = List<Order>();


  @override
  void initState() {
    getOrder();
    super.initState();
  }

  Future<Response> getOrder() async {
    var data = await http.post('${Config.API_URL}/order/user?userId=${systemInstance.userId}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    for (var i in jsonData){
      if(i['orderStatus'] == 1){
        Order orders = Order(
          i['idOrderList'],
          i['idUserProfile'],
          i['userName'],
          i['idUserShop'],
          i['shopName'],
          i['timeReceive'],
          i['totalPrice'],
          i['productList'],
          i['orderStatus'],
        );
        order1.add(orders);
      }
      if(i['orderStatus'] == 2){
        Order orders = Order(
          i['idOrderList'],
          i['idUserProfile'],
          i['userName'],
          i['idUserShop'],
          i['shopName'],
          i['timeReceive'],
          i['totalPrice'],
          i['productList'],
          i['orderStatus'],
        );
        order2.add(orders);
      }
      if(i['orderStatus'] == 3){
        Order orders = Order(
          i['idOrderList'],
          i['idUserProfile'],
          i['userName'],
          i['idUserShop'],
          i['shopName'],
          i['timeReceive'],
          i['totalPrice'],
          i['productList'],
          i['orderStatus'],
        );
        order3.add(orders);
      }
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Itim',primaryColor: Colors.teal,),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text('กำลังดำเนินการ'),
                ),
                Tab(
                  child: Text('เสร็จสิ้น'),
                ),
                Tab(
                  child: Text('ยกเลิก/ล้มเหลว'),
                ),
              ],
              indicatorColor: Colors.white,
            ),
            title: Text('ออเดอร์',style: TextStyle(fontSize: 25.0) ,),
            leading: Icon(Icons.all_inbox),
          ),
          body: TabBarView(
            children: [
              Container(
                child: ListView.builder(
                  itemCount: order1.length,
                  itemBuilder: (context, index){
                    var item = order1[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0,vertical: 1.0),
                      child: Card(
                        elevation: 1.0,
                        child: ListTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                child: Icon(
                                    Icons.shopping_bag,
                                    color: Colors.orange,
                                    size: 30.0,
                                ),
                                backgroundColor: Colors.grey[100],
                              ),
                              SizedBox(width: 20.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('ระหว่างดำเนินการ',style: TextStyle(color: Colors.orange),),
                                      SizedBox(width: 50.0,),
                                      Text(item.timeReceive.substring(0,10),style: TextStyle(fontSize: 14.0),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin, color: Colors.red, size: 15.0,),
                                      Text(item.shopName),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin, color: Colors.green, size: 15.0,),
                                      Text(item.userName),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => ActiveOrder(item.idOrderList, item.shopName)));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                child: ListView.builder(
                  itemCount: order2.length,
                  itemBuilder: (context, index){
                    var item = order2[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0,vertical: 1.0),
                      child: Card(
                        elevation: 1.0,
                        child: ListTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                child: Icon(
                                  Icons.shopping_bag,
                                  color: Colors.green,
                                  size: 30.0,
                                ),
                                backgroundColor: Colors.grey[100],
                              ),
                              SizedBox(width: 20.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('เสร็จสมบูรณ์',style: TextStyle(color: Colors.green),),
                                      SizedBox(width: 70.0,),
                                      Text(item.timeReceive.substring(0,10),style: TextStyle(fontSize: 14.0),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin, color: Colors.red, size: 15.0,),
                                      Text(item.shopName),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin, color: Colors.green, size: 15.0,),
                                      Text(item.userName),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => CompleteOrder(item.idOrderList, item.shopName)));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                child: ListView.builder(
                  itemCount: order3.length,
                  itemBuilder: (context, index){
                    var item = order3[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0,vertical: 1.0),
                      child: Card(
                        elevation: 1.0,
                        child: ListTile(
                          title: Row(
                            children: [
                              CircleAvatar(
                                child: Icon(
                                  Icons.shopping_bag,
                                  color: Colors.red,
                                  size: 30.0,
                                ),
                                backgroundColor: Colors.grey[100],
                              ),
                              SizedBox(width: 20.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('ยกเลิก/ล้มเหลว',style: TextStyle(color: Colors.red),),
                                      SizedBox(width: 50.0,),
                                      Text(item.timeReceive.substring(0,10),style: TextStyle(fontSize: 14.0),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin, color: Colors.red, size: 15.0,),
                                      Text(item.shopName),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin, color: Colors.green, size: 15.0,),
                                      Text(item.userName),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => CancleOrder(item.idOrderList, item.shopName)));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
