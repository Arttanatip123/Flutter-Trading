import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/BuyEvent/cart_screen.dart';
import 'package:myapp/BuyEvent/map_navigator_creen.dart';
import 'package:myapp/BuyEvent/product_model.dart';
import 'package:myapp/config.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopProductList extends StatefulWidget {
  final int shopId;
  final String shopName;
  final double shopLat;
  final double shopLng;

  const ShopProductList({Key key, this.shopId, this.shopName, this.shopLat, this.shopLng})
      : super(key: key);
  @override
  _ShopProductListState createState() => _ShopProductListState(this.shopId,this.shopName,this.shopLat,this.shopLng);
}

class _ShopProductListState extends State<ShopProductList> {
  _ShopProductListState(this.shopId,this.shopName,this.shopLat,this.shopLng);
  Future<void> _launched;
  List<Product> products = List<Product>();
  List<Product> productList = List<Product>();
  int shopId;
  String shopName;
  String shopPhone = '';
  double shopLat;
  double shopLng;



  Future<List<Product>> _getProduct() async {
    var data = await http.get('${Config.API_URL}/product/findbyiduser?userId=${shopId}');
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

  getData() async {
    var data = await http.post('${Config.API_URL}/shop/detail?idUserShop=${shopId}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    shopPhone = jsonData['shopPhone'];
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
    getData();
    _getProduct().then((res){
      setState(() {});
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName,style: TextStyle(fontSize: 20.0),),
        actions: <Widget>[

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
                                          print(shopPhone);
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
                      }
                  );
                },
              ),
              SizedBox(width: 15.0,),
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
                          builder: (context) => Cart(productList,widget.shopId),
                        ),
                      );
                  },
                ),
              ),
              Container(width: 20.0,)
            ],
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
                height: 50.0,
                width: 50.0,
                child: FadeInImage.assetNetwork(
                  placeholder: 'images/Loading.gif',
                  image: '${Config.API_URL}/product/image?imageName=${item.productImg}',
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(item.productName,style: TextStyle(fontSize: 20.0),),
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
