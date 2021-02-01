import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/MyShop/home_shop_screen.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class selectServices extends StatefulWidget {
  final String userName;

  const selectServices({Key key, this.userName}) : super(key: key);

  @override
  _selectServicesState createState() => _selectServicesState();
}

class _selectServicesState extends State<selectServices> {
  var userId;

  @override
  void initState() {
    super.initState();
    SystemInstance instance = SystemInstance();
    userId = instance.userId.toString();
    print('userid is ' + userId);
    print('username is '+widget.userName);
  }

  void onClickSell() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeShopScreen()));
  }

  void onClickBuy() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text('สวัสดีคุณ',
              style: TextStyle(fontSize: 32.0,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(widget.userName, style: TextStyle(fontSize: 28.0),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text('เลือกบริการของคุณ',style: TextStyle(fontSize: 24),),
          ),
          Container(height: 100.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          Icon(Icons.add_shopping_cart, size: 50.0, color: Colors.blue,),
                          Text('ซื้อสินค้า',style: TextStyle(fontSize: 20.0),),
                        ],
                      ),
                      onPressed: onClickBuy,
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          Icon(Icons.monetization_on, size: 50.0, color: Colors.blue,),
                          Text('ขายสินค้า', style: TextStyle(fontSize: 20.0),),
                        ],
                      ),
                      onPressed: onClickSell,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
