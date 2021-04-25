import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/BuyEvent/shop_product_list.dart';
import 'package:myapp/Dashboard/shop_list_screen.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;

class Search extends SearchDelegate{
  Search(this.allProducts);
  SystemInstance systemInstance = SystemInstance();
  List<AllProducts> allProducts = List<AllProducts>();
  List<AllProducts> recentList = [];
  List<AllProducts> products = [];

  Future getShopDetail(int idUserShop) async {
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http
        .post('${Config.API_URL}/shop/detail?idUserShop=${idUserShop}',headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    return jsonData;
  }

  Future getUserDetail(int idUserProfile) async {
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.post(
        '${Config.API_URL}/user/user_detail?idUserProfile=${idUserProfile}',headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    return jsonData;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(icon: Icon(Icons.close), onPressed: (){
        query = "";
      })
    ];
    throw UnimplementedError();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
      Navigator.pop(context);
    });
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    List<AllProducts> suggestionList = [];

    if(query.isEmpty){
      suggestionList = allProducts;
    }else{
      for(var i in allProducts){
        if(i.productName.toLowerCase().contains(query)){
          suggestionList.add(i);
        }
      }
    }
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index){
          var item = suggestionList[index];
          return suggestionList.isEmpty ? Center(child: Text('ไม่พบข้อมูล...'),) : ListTile(
            title: ListTile(
              title: Container(
                height: 150.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: FadeInImage(
                    placeholder: AssetImage("images/Loading.gif"),
                    image: NetworkImage(
                      "${Config.API_URL}/product/image?imageName=${item.productImg}",
                      headers: {"Authorization": "Bearer ${systemInstance.token}"},
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.productName}', style: TextStyle(fontSize: 25.0, color: Colors.black),),
                  Row(
                    children: [
                      Text('${item.productPrice}  บาท', style: TextStyle(fontSize: 16.0, color: Colors.black),),
                      Spacer(),
                      Text('ไปยังร้านค้า',style: TextStyle(color: Colors.teal),),
                      Icon(Icons.arrow_right, color: Colors.teal,)
                    ],
                  ),
                ],
              ),
              onTap: () {
                var data = getShopDetail(item.idUserShop);
                data.then((value) {
                  //TODO เช็คว่าสินค้ามีร้านค้าหรือไม่
                  if (value['shopName'] != null) {
                    //TODO ถ้ามีร้านค้า
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ShopProductList(
                                    shopId: item.idUserShop,
                                    shopName: value['shopName'],
                                    shopLat: double.parse(
                                        value['latitude']),
                                    shopLng: double.parse(
                                        value['longtitude']))));
                  } else {
                    var data = getUserDetail(item.idUserShop);
                    data.then((value) {
                      //TODO ไม่มีร้านส่ง id ชื่อร้าน shopName = userName lat = 0 lng = 0
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ShopProductList(
                                      shopId: item.idUserShop,
                                      shopName:
                                      value['userName'],
                                      shopLat:
                                      value['latitude'],
                                      shopLng: value[
                                      'longtitude'])));
                    });
                  }
                });
              },
            ),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<AllProducts> suggestionList = [];

    if(query.isEmpty){
      suggestionList = allProducts;
    }else{
      for(var i in allProducts){
        if(i.productName.toLowerCase().contains(query)){
          suggestionList.add(i);
        }
      }
    }
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index){
          var item = suggestionList[index];
          return suggestionList.isEmpty ? Center(child: Text('ไม่พบข้อมูล...'),) : ListTile(
            title: ListTile(
              title: Container(
                height: 150.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: FadeInImage(
                    placeholder: AssetImage("images/Loading.gif"),
                    image: NetworkImage(
                      "${Config.API_URL}/product/image?imageName=${item.productImg}",
                      headers: {"Authorization": "Bearer ${systemInstance.token}"},
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.productName}', style: TextStyle(fontSize: 25.0, color: Colors.black),),
                  Row(
                    children: [
                      Text('${item.productPrice}  บาท', style: TextStyle(fontSize: 16.0, color: Colors.black),),
                      Spacer(),
                      Text('ไปยังร้านค้า',style: TextStyle(color: Colors.teal),),
                      Icon(Icons.arrow_right, color: Colors.teal,)
                    ],
                  ),
                ],
              ),
              onTap: () {
                var data = getShopDetail(item.idUserShop);
                data.then((value) {
                  //TODO เช็คว่าสินค้ามีร้านค้าหรือไม่
                  if (value['shopName'] != null) {
                    //TODO ถ้ามีร้านค้า
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ShopProductList(
                                    shopId: item.idUserShop,
                                    shopName: value['shopName'],
                                    shopLat: double.parse(
                                        value['latitude']),
                                    shopLng: double.parse(
                                        value['longtitude']))));
                  } else {
                    var data = getUserDetail(item.idUserShop);
                    data.then((value) {
                      //TODO ไม่มีร้านส่ง id ชื่อร้าน shopName = userName lat = 0 lng = 0
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ShopProductList(
                                      shopId: item.idUserShop,
                                      shopName:
                                      value['userName'],
                                      shopLat:
                                      value['latitude'],
                                      shopLng: value[
                                      'longtitude'])));
                    });
                  }
                });
              },
            ),
        );
    });

  }

}