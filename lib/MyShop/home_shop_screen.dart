import 'package:flutter/material.dart';
import 'package:myapp/MyShop/shop_product_list_screen.dart';
import 'package:myapp/MyShop/shop_order_list.dart';
import 'package:myapp/MyShop/shop_profile_screen.dart';

class HomeShopScreen extends StatefulWidget {
  @override
  _HomeShopScreenState createState() => _HomeShopScreenState();
}

class _HomeShopScreenState extends State<HomeShopScreen> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    ProductList(),
    ShopOrderList(),
    ShopProfileScreen(),

  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              title: Text('รายการ')
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            title: Text('ออเดอร์'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('ตั้งค่า')
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
