import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/MyShop/add_product.dart';
import 'package:myapp/MyShop/update_product.dart';
import 'package:myapp/MyShop/shop_product_model.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:http/http.dart' as http;

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String userId;

  Future<List<Product>> _getProduct() async {
    var data = await http.get('${Config.API_URL}/product/findbyiduser?userId=${userId}');
    var da = utf8.decode(data.bodyBytes);
    var js = jsonDecode(da);

    List<Product> products = [];
    for(var u in js){
      Product product = Product(u['idProduct'],u['idUserShop'],u['productName'],u['productPrice'],u['productAmount'],u['productType'], u['productSubType'],u['productImg'],);
      products.add(product);

    }
    return products;
  }


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    SystemInstance instance = SystemInstance();
    userId = instance.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สินค้าของฉัน',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21.0),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: _getProduct(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text('กำลังดาวน์โหลดข้อมูล...'),
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      leading: Container(
                        height: 50.0,
                        width: 50.0,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'images/Loading.gif',
                          image: '${Config.API_URL}/product/image?imageName=${snapshot.data[index].productImg}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        snapshot.data[index].productName,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text('จำนวน ' +
                              snapshot.data[index].productAmount.toString()),
                          Spacer(),
                          Text(
                            snapshot.data[index].productPrice.toString() + " บาท",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      onTap: () {
                        //_displayDialog(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder:
                                (BuildContext context) => UpdateProduct(idProduct:snapshot.data[index].idProduct, productImg: snapshot.data[index].productImg))).then((value){setState(() {

                                });});

                      },
                    ),
                  );
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, size: 35.0,),
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AddProduct()))
              .then((value) {
            setState(() {});
          });
        },
      ),
    );
  }
}