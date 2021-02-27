import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/BuyEvent/confirm_order_screen.dart';
import 'package:myapp/BuyEvent/product_model.dart';
import 'package:myapp/system/SystemInstance.dart';
import '../config.dart';
import 'package:http/http.dart' as http;

class Cart extends StatefulWidget {
  final List<Product> _cart;
  final int shopId;
  Cart(this._cart, this.shopId);

  @override
  _CartState createState() => _CartState(this._cart, this.shopId);
}

class _CartState extends State<Cart> {
  SystemInstance systemInstance = SystemInstance();
  _CartState(this._cart, int shopId);
  List<Product> _cart;
  List orders = List();
  int totalPrice = 0;
  var dateTime;

  @override
  void initState() {
    dateTime = DateTime.now();
    for(Product p in this._cart){
      totalPrice = totalPrice + (p.productPrice * p.numberOfItem);
    }
    super.initState();
  }

  Future<void> chooseDate() async {
    DateTime chooseDateTime = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 5),
    );
    if(chooseDateTime != null){
      setState(() {
        dateTime = chooseDateTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตะกร้าสินค้า',style: TextStyle(fontSize: 25.0),),
      ),
      body: ListView.builder(
          itemCount: _cart.length,
          itemBuilder: (context, index) {
            var item = _cart[index];
            return Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Card(
                elevation: 1.0,
                child: ListTile(
                  leading: Container(
                    height: 50.0,
                    width: 50.0,
                    child:FadeInImage(
                      placeholder: AssetImage("images/Loading.gif"),
                      image: NetworkImage(
                        "${Config.API_URL}/product/image?imageName=${item.productImg}",
                        headers: {"Authorization": "Bearer ${systemInstance.token}"},
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item.productName,style: TextStyle(fontSize: 20.0),),
                  subtitle: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productPrice.toString() + " THB"),
                        Row(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: 30.0,
                                  color: Colors.red[500],
                                ),
                                onPressed: () {
                                  if (_cart[index].numberOfItem > 1){
                                    _cart[index].numberOfItem =
                                    --_cart[index].numberOfItem;

                                    totalPrice = totalPrice - _cart[index].productPrice;
                                  }
                                  setState(() {
                                  });
                                }),
                            // Text(" $_n "),
                            Text(item.numberOfItem.toString()),
                            IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 30.0,
                                  color: Colors.blue[500],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _cart[index].numberOfItem =
                                    ++_cart[index].numberOfItem;
                                    totalPrice = totalPrice + _cart[index].productPrice;
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: GestureDetector(
                    child: Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                      size: 40.0,
                    ),
                    onTap: () {
                      setState(() {
                       // _cart[index].numberOfItem = 0;
                        _cart.remove(item);
                        totalPrice = totalPrice - (item.numberOfItem * item.productPrice);
                      });
                    },
                  ),
                ),
              ),
            );
          }),
      bottomNavigationBar: Container(
        height: 150.0,
        color: Colors.white,
        child: Column(
          children: [
            Text('* กรุณาเลือกวันที่เดินทางไปรับสินค้า *',style: TextStyle(color: Colors.red),),
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text('${dateTime.day} - ${dateTime.month} - ${dateTime.year}'),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: (){
                chooseDate();
              },
            ),
            Row(
              children: [
                Expanded(
                    child: ListTile(
                      title: Text(
                        "${totalPrice}.00 บาท",
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("ยอดรวม"),
                    ),
                ),
                Expanded(
                  child: MaterialButton(
                    onPressed: () {
                      //onClickOrder(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) => ConfirmOrder(_cart,totalPrice,dateTime.toString(),widget.shopId)));

                    },
                    child: Text(
                      "สั่งจอง",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

