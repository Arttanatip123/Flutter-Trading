import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/BuyEvent/shop_product_list.dart';
import 'package:myapp/Dashboard/search_screen.dart';
import 'package:myapp/MyShop/home_shop_screen.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/MyStorage.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:myapp/user/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ShopListScreen extends StatefulWidget {
  @override
  _ShopListScreenState createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  SystemInstance systemInstance = SystemInstance();
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Shops> shopList = List<Shops>();
  Position position;
  double latMe = 16.4396085;
  double lngMe = 102.8285524;
  MyStorage myStorage;
  var userId;
  String userName = "",passWord="", firsName = "", lastName = "",phoneNumber="";
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    checkLoginStatus();
    myStorage = new MyStorage();
    myStorage.readCounter().then((value) {
      setState(() {
        userId = value;
        systemInstance.userId = userId.toString();
        print(userId);
        getData(userId);
      });

    getShop();
    super.initState();
  });
  }

  getData(int userId) async{
    var data = await http.post('${Config.API_URL}/user/user_detail?idUserProfile=${userId}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    setState(() {
      userName = jsonData['userName'];
      passWord = jsonData['passWord'];
      firsName = jsonData['firstName'];
      lastName = jsonData['lastName'];
      phoneNumber = jsonData['phoneNumber'];
    });
  }


  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
              (Route<dynamic> route) => false);
    }
  }


  Future getShop() async {
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    latMe = position.latitude.toDouble();
    lngMe = position.longitude.toDouble();

    var data = await http.get('${Config.API_URL}/shop/list');
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
  
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('ร้านค้า'),
      actions: [searchBar.getSearchAction(context)],
    );
  }

  void onSubmitted(String value) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SearchScreen(value)));
    // setState(() {
    //   _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text('You wrote $value!')));
    // });
  }

  _ShopListScreenState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onCleared: () {
          print("cleared");
        },
        onClosed: () {
          print("closed");
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 70.0,
                    width: 70.0,
                    child: CircleAvatar(
                      child: Icon(Icons.account_circle, color: Colors.white, size: 60.0,),
                      backgroundColor: Colors.teal[200],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สวัสดี ,',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(width: 10.0,),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('('+
                          firsName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      SizedBox(width: 10.0,),
                      Text(
                        lastName + ')',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('ซื้อสินค้า'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('ขายสินค้า'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomeShopScreen()));
                // Navigator.of(context).pushAndRemoveUntil(
                //     MaterialPageRoute(
                //         builder: (BuildContext context) => HomeShopScreen()),
                //         (Route<dynamic> route) => false);
              },
            ),
            SizedBox(height: 290.0,),
            ListTile(
              leading: Icon(Icons.logout,),
              title: Text('ออกจากระบบ'),
              onTap: (){
                sharedPreferences.clear();
                sharedPreferences.commit();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginScreen()),
                        (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
      key: _scaffoldKey,
      body: shopList.isEmpty ? Container(child: Center(child: Text('กำลังค้นหาร้านค้า...'),),) : ListView.builder(
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
                        // Positioned(
                        //   top: 6.0,
                        //   right: 6.0,
                        //   child: Card(
                        //     shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(4.0)),
                        //     child: Padding(
                        //       padding: EdgeInsets.all(2.0),
                        //       child: Row(
                        //         children: <Widget>[
                        //           Icon(
                        //             Icons.star,
                        //             color: Colors.lightBlueAccent,
                        //             size: 10.0,
                        //           ),
                        //           Text(
                        //             "rating",
                        //             style: TextStyle(
                        //               fontSize: 10.0,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
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




class Shops {
  final int idUserShop;
  final String shopName;
  final String shopPhone;
  final String latitude;
  final String longtitude;
  final String officeHours;
  final String shopComment;
  final String shopImg;
  final String shopStatus;
  final String shopDistance;

  Shops(this.idUserShop, this.shopName, this.shopPhone, this.latitude, this.longtitude, this.officeHours, this.shopComment, this.shopImg, this.shopStatus, this.shopDistance);
}