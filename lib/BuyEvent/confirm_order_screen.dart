import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:myapp/BuyEvent/product_model.dart';
import 'package:myapp/BuyEvent/shop_product_list.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;

class ConfirmOrder extends StatefulWidget {
  final List<Product> cart;
  final int totalPrice;
  final String dateTime;
  final int shopId;
  ConfirmOrder(this.cart,this.totalPrice,this.dateTime,this.shopId);


  @override
  _ConfirmOrderState createState() => _ConfirmOrderState(this.cart,this.totalPrice,this.dateTime,this.shopId);
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  _ConfirmOrderState(this.cart,this.totalPrice,this.dateTime,this.shopId);
  SystemInstance systemInstance = SystemInstance();
  List<Product> cart;
  List orders = List();
  int totalPrice;
  String dateTime;
  int shopId;

  postOrder(){
    Map<String, String> params = Map();
    params['userId'] = systemInstance.userId;
    params['shopId'] = widget.shopId.toString();
    params['timeReceive'] = dateTime.toString();
    params['totalPrice']  = totalPrice.toString();
    params['product'] = orders.toString();
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    http.post('${Config.API_URL}/order/makeorder', body: params, headers: header).then((response){
      Map retMap = jsonDecode(response.body);
      int status = retMap['status'];
      if(status == 0){
        Navigator.pop(context);
        Navigator.pop(context);
        CoolAlert.show(context: context, type: CoolAlertType.success,text: "ทำรายการสำเร็จ");
      }else{
        CoolAlert.show(context: context, type: CoolAlertType.error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    for (Product p in cart){
      Order order = Order(p.idProduct,p.productName,p.productPrice,p.numberOfItem);
      String jsonOrder = jsonEncode(order);
      orders.add(jsonOrder);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ยืนยันออเดอร์หรือไม่ ?',style: TextStyle(fontSize: 25.0),),
      ),
      body: Container(
        child: ListView.builder(
          itemCount:cart.length,
          itemBuilder: (context, index){
            var item = cart[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Row(
                children: [
                  SizedBox(width: 10.0,),
                  Text((index + 1).toString() + ' . ' + item.productName, style: TextStyle(fontSize: 18.0),),
                  SizedBox(width: 40.0,),
                  Spacer(),
                  Text('x ' + item.numberOfItem.toString() + '    ราคา  '
                      + (item.productPrice * item.numberOfItem).toString(),
                    style: TextStyle(fontSize: 18.0),
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
                        "ยกเลิก",
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
                        Navigator.pop(context);
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
                        "ยืนยัน",
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
                        postOrder();

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
