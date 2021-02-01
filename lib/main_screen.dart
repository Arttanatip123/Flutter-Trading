import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myapp/Dashboard/shop_list_screen.dart';
import 'package:myapp/Dashboard/shop_order_screen.dart';
import 'package:myapp/MyShop/home_shop_screen.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/MyStorage.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:myapp/user/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard/profile_screen.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _children =[
    ShopListScreen(),
    ShopOrder(),
    ProfileScreen(),
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
            icon: Icon(Icons.shopping_cart,),
            title: Text('หน้าแรก'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment,),
            title: Text('รายการ'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle,),
            title: Text('โปรไฟล์'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
