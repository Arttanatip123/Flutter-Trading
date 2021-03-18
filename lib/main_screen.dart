import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Dashboard/shop_list_screen.dart';
import 'package:myapp/Dashboard/shop_order_screen.dart';

import 'Dashboard/profile_screen.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true)
    );
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
