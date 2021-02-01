import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/BuyEvent/shop_product_list.dart';
import 'package:myapp/Dashboard/shop_list_screen.dart';
import 'package:myapp/config.dart';

class SearchScreen extends StatefulWidget {
  final String value;
  SearchScreen(this.value);
  @override
  _SearchScreenState createState() => _SearchScreenState(this.value);
}

class _SearchScreenState extends State<SearchScreen> {
  _SearchScreenState(this.value);
  List<Shops> shopList = List<Shops>();
  String value;
  Position position;
  double latMe = 16.4396085;
  double lngMe = 102.8285524;


  @override
  void initState() {
    getShop();
    super.initState();
  }

  Future getShop() async{
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    latMe = position.latitude.toDouble();
    lngMe = position.longitude.toDouble();

    var data = await http.post('${Config.API_URL}/product/search?value=${value}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    for(var i in jsonData){
      if(i['shopName'] != null){
        double lat = double.parse(i['latitude']);
        double long = double.parse(i['longtitude']);
        double distance = calculateDistance(latMe,lngMe,lat,long);
        if(distance < 20){
          Shops shops = Shops(i['idUserShop'],i['shopName'],i['shopPhone'],i['latitude'],i['longtitude'],i['officeHours'],i['shopComment'],i['shopImg'], i['shopStatus'],distance.toString());
          shopList.add(shops);
        }
      }
    }
    setState(() {

    });
    return shopList;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    double distance = 0;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    distance = 12742 * asin(sqrt(a));
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ร้านค้า'),
      ),
      body: shopList.isEmpty ? Container(child: Center(child: Text('กำลังค้นหา...'),),) : ListView.builder(
        itemCount: shopList.length,
        itemBuilder: (context, index){
          var item = shopList[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    int shopId = item.idUserShop;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ShopProductList(
                                    shopId: shopId, shopName: item.shopName, shopLat: double.parse(item.latitude), shopLng: double.parse(item.longtitude)
                                )
                        )
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 5.5,
                        width: MediaQuery.of(context).size.width - 15,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'images/Loading.gif',
                            image: '${Config.API_URL}/shop/image?imageName=${item.shopImg}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6.0,
                        left: 6.0,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0)),
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: item.shopStatus == '1' ? Text(
                              " OPEN ",
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ) : Text(
                              " OFF ",
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7.0),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      item.shopName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SizedBox(height: 1.0),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Text(
                          "เวลาทำการ " + item.officeHours,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Spacer(),
                        Text(item.shopDistance.toString().substring(0,4) + '  Km '),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
              ],
            ),
          );
        },
      ),
    );
  }
}
