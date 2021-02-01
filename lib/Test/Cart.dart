import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/Test/model.dart';
import '../config.dart';

class Cart extends StatefulWidget {
  final List<Product> _cart;
  Cart(this._cart);

  @override
  _CartState createState() => _CartState(this._cart);
}

class _CartState extends State<Cart> {
  _CartState(this._cart);
  List<Product> _cart;

  @override
  Widget build(BuildContext context) {
    print(_cart);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
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
                    height: 100.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              "${Config.API_URL}/product/image?imageName=${item.productImg}")),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  title: Text(item.productName),
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
                                  setState(() {
                                    if (_cart[index].numberOfItem > 1)
                                      _cart[index].numberOfItem =
                                          --_cart[index].numberOfItem;
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
                        _cart[index].numberOfItem = 0;
                        _cart.remove(item);
                      });
                    },
                  ),
                ),
              ),
            );
          }),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
                child: ListTile(
              title: Text(
                "0.00",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("ยอดรวม"),
            )),
            Expanded(
              child: MaterialButton(
                onPressed: () {},
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
      ),
    );
  }
}

