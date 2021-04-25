import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/BuyEvent/cart_screen.dart';
import 'package:myapp/BuyEvent/map_navigator_creen.dart';
import 'package:myapp/BuyEvent/product_model.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopProductList extends StatefulWidget {
  final int shopId;
  final String shopName;
  final double shopLat;
  final double shopLng;

  const ShopProductList(
      {Key key, this.shopId, this.shopName, this.shopLat, this.shopLng})
      : super(key: key);

  @override
  _ShopProductListState createState() => _ShopProductListState(
      this.shopId, this.shopName, this.shopLat, this.shopLng);
}

class _ShopProductListState extends State<ShopProductList> {
  _ShopProductListState(this.shopId, this.shopName, this.shopLat, this.shopLng);

  SystemInstance systemInstance = SystemInstance();
  Future<void> _launched;
  List<Product> products = List<Product>();
  List<Product> productList = List<Product>();
  int shopId;
  String shopName;
  String shopPhone = '';
  double shopLat;
  double shopLng;

  Future<List<Product>> _getProduct() async {
    Map<String, String> header = {
      "Authorization": "Bearer ${systemInstance.token}"
    };
    var data = await http.get(
        '${Config.API_URL}/product/findbyiduser?userId=${shopId}',
        headers: header);
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
    setState(() {

    });
    return products;
  }

  getShopPhone() async {
    Map<String, String> header = {
      "Authorization": "Bearer ${systemInstance.token}"
    };
    var data = await http.post(
        '${Config.API_URL}/shop/detail?idUserShop=${shopId}',
        headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    shopPhone = jsonData['shopPhone'];
  }

  getUserPhone() async {
    Map<String, String> header = {
      "Authorization": "Bearer ${systemInstance.token}"
    };
    var data = await http.post(
        '${Config.API_URL}/user/user_detail?idUserProfile=${shopId}',
        headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    shopPhone = jsonData['phoneNumber'];
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

  @override
  void initState() {
    this.shopId = widget.shopId;
    //TODO เช็ค parameter ส่งมาเป็นร้าน หรือว่า user
    if (shopLng == 0.0000000) {
      //TODO ถ้าเป็น user ไปดึงเบอร์ user มา
      getUserPhone();
    } else {
      //TODO ถ้าเป็นร้านไปดึงเบอร์โทรร้านมา
      getShopPhone();
    }

    _getProduct();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.shopName,
          style: TextStyle(fontSize: 20.0),
        ),
        actions: <Widget>[
          Row(
            children: [
              InkWell(
                child: Text(
                  'ติดต่อ',
                  style: TextStyle(fontSize: 18.0),
                ),
                onTap: () {
                  shopLat != null
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                height: 130.0,
                                width: 200.0,
                                child: Column(
                                  children: [
                                    Text('เลือกช่องทาง'),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Container(
                                      child: RaisedButton(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 40.0,
                                            ),
                                            Text(
                                              'โทรศัพท์',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            print(shopPhone);
                                            _launched = _makePhoneCall(
                                                'tel:$shopPhone');
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
                                            Icon(
                                              Icons.location_pin,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 40.0,
                                            ),
                                            Text(
                                              'ตำแหน่งร้าน',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          _openOnGoogleMapApp(shopLat, shopLng);
                                        },
                                        color: Colors.teal,
                                      ),
                                      width: 200.0,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                      : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                height: 130.0,
                                width: 200.0,
                                child: Column(
                                  children: [
                                    Text('เลือกช่องทาง'),
                                    Text(
                                      '*สินค้าไม่ระบุตำแหน่ง กรุณาติดต่อผู้ขายโดยตรง',
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Container(
                                      child: RaisedButton(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 40.0,
                                            ),
                                            Text(
                                              'โทรศัพท์',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            print(shopPhone);
                                            _launched = _makePhoneCall(
                                                'tel:$shopPhone');
                                          });
                                        },
                                        color: Colors.teal,
                                      ),
                                      width: 200.0,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                },
              ),
              SizedBox(
                width: 15.0,
              ),
              Container(
                //padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: GestureDetector(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Icon(
                        Icons.shopping_cart,
                        size: 30.0,
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
                          builder: (context) =>
                              Cart(productList, widget.shopId),
                        ),
                      ).then((value) => {

                      });
                  },
                ),
              ),
              Container(
                width: 20.0,
              )
            ],
          )
        ],
      ),
      body: products.isEmpty
          ? Container(
              child: Center(
                child: Text('กำลังดาวน์โหลดข้อมูล...'),
              ),
            )
          : buildListView(),
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
            margin: EdgeInsets.all(1.0),
            elevation: 5.0,
            child: ListTile(
              title: Container(
                height: 150.0,
                child: InkWell(
                  onTap: () {
                    //TODO Show dialog รูปภาพ
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 500,
                                child: FadeInImage(
                                  placeholder: AssetImage("images/Loading.gif"),
                                  image: NetworkImage(
                                    "${Config.API_URL}/product/image?imageName=${item.productImg}",
                                    headers: {
                                      "Authorization":
                                          "Bearer ${systemInstance.token}"
                                    },
                                  ),
                                  fit: BoxFit.cover,
                                )),
                          );
                        });
                  },
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    child: item.productAmount != 0
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: FadeInImage(
                              placeholder: AssetImage("images/Loading.gif"),
                              image: NetworkImage(
                                "${Config.API_URL}/product/image?imageName=${item.productImg}",
                                headers: {
                                  "Authorization":
                                      "Bearer ${systemInstance.token}"
                                },
                              ),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: FadeInImage(
                                  placeholder: AssetImage("images/Loading.gif"),
                                  image: NetworkImage(
                                    "${Config.API_URL}/product/image?imageName=${item.productImg}",
                                    headers: {
                                      "Authorization":
                                          "Bearer ${systemInstance.token}"
                                    },
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                color: Colors.grey.withOpacity(0.75),
                              ),
                              Center(
                                child: Text(
                                  'หมด',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
              ),
              subtitle: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(fontSize: 22.0, color: Colors.black),
                      ),
                      Text(item.productPrice.toString() + " บาท"),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    child: (!productList.contains(item))
                        ? SizedBox(
                          height: 30.0,
                          width: 70.0,
                          child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.teal,
                              child: Text("เพิ่ม"),
                              onPressed: () {
                                setState(() {
                                  if (!productList.contains(item)) {
                                    productList.add(item);
                                    item.numberOfItem = 1;
                                  } else {
                                    productList.remove(item);
                                  }
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                        )
                        : SizedBox(
                          height: 30.0,
                          width: 70.0,
                          child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.red,
                              child: Text("ลบ"),
                              onPressed: () {
                                setState(() {
                                  if (!productList.contains(item)) {
                                    productList.add(item);
                                    item.numberOfItem = 1;
                                  } else {
                                    productList.remove(item);
                                  }
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
