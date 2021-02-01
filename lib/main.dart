import 'package:flutter/material.dart';
import 'file:///C:/myApp/myapp/lib/Dashboard/profile_screen.dart';
import 'package:myapp/main_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Itim',
          primaryColor: Colors.teal,
          primarySwatch: Colors.teal,
          splashColor: Colors.teal,
      ),
      home: MainScreen(),
  ));
}
class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}



