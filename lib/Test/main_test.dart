import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/Test/Cart.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/Test/model.dart';
import '../config.dart';

class MyTest extends StatefulWidget {
  @override
  _MyTestState createState() => _MyTestState();
}

class _MyTestState extends State<MyTest> {

  List<Product> products = List<Product>();
  List<Product> productList = List<Product>();

  Future<List<Product>> _getProduct() async {
    var data =
    await http.get('${Config.API_URL}/product/findbyiduser?userId=1');
    var da = utf8.decode(data.bodyBytes);
    var js = jsonDecode(da);
    for (var u in js) {
      Product product = Product(
        u["idProduct"],
        u["productName"],
        u["productPrice"],
        u["productAmount"],
        u["productType"],
        u["productSubType"],
        u["productImg"],
        0,
      );
      products.add(product);
    }
    print(products);
    return products;
  }

  @override
  void initState() {
    super.initState();
    _getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST Cart"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: GestureDetector(
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    size: 36.0,
                  ),
                  if (productList.length > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: CircleAvatar(
                        radius: 8.0,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        child: Text(
                          productList.length.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                if (productList.isNotEmpty)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Cart(productList),
                    ),
                  );
              },
            ),
          )
        ],
      ),
      body: buildListView(),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        var item = products[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 2.0,
          ),
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
              subtitle: Text(item.productPrice.toString()+" THB"),
              trailing: GestureDetector(
                child: (!productList.contains(item))
                    ? Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 40.0,
                )
                    : Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 40.0,
                ),
                onTap: () {
                  setState(() {
                    if (!productList.contains(item)){
                      productList.add(item);
                      item.numberOfItem = 1;
                    }
                    else{
                      productList.remove(item);
                    }
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

