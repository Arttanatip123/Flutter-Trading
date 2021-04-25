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
  SystemInstance systemInstance = SystemInstance();
  String userId;
  bool _isLoading = false;

  Future<List<Product>> _getProduct() async {
    _isLoading = true;
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.get('${Config.API_URL}/product/findbyiduser?userId=${userId}', headers: header);
    var da = utf8.decode(data.bodyBytes);
    var js = jsonDecode(da);

    List<Product> products = [];
    for(var u in js){
      Product product = Product(u['idProduct'],u['idUserShop'],u['productName'],u['productPrice'],u['productAmount'],u['productType'], u['productSubType'],u['productImg'],);
      products.add(product);

    }
    _isLoading = false;
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
            if (_isLoading == true) {
              return Center(
                child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.teal),),
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
                      title: Container(
                        height: 150.0,
                        child: FadeInImage(
                          placeholder: AssetImage("images/Loading.gif"),
                          image: NetworkImage(
                            "${Config.API_URL}/product/image?imageName=${snapshot.data[index].productImg}",
                            headers: {"Authorization": "Bearer ${systemInstance.token}"},
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(snapshot.data[index].productName, style: TextStyle(fontSize: 20.0, color: Colors.black),),
                          Row(
                            children: [
                              Text('จำนวน ' +
                                  snapshot.data[index].productAmount.toString(),
                                style: TextStyle(fontSize: 18.0, color: Colors.black),
                              ),
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
