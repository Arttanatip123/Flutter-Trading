import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/BuyEvent/product_model.dart';
class SearchProductScreen extends StatefulWidget {
  final String value;
  SearchProductScreen(this.value);
  @override
  _SearchProductScreenState createState() => _SearchProductScreenState(this.value);
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  _SearchProductScreenState(this.value);
  String value;
  List<Product> productList = List<Product>();
  Position position;
  double latMe = 16.4396085;
  double lngMe = 102.8285524;

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  Future getProduct() async {

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Search Product...'),
      ),
    );
  }
}
