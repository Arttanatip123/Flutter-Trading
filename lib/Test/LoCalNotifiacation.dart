import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification extends StatefulWidget {
  @override
  _LocalNotificationState createState() => _LocalNotificationState();
}

class _LocalNotificationState extends State<LocalNotification> {
  FlutterLocalNotificationsPlugin localNotifications;

  @override
  void initState() {
    super.initState();
    var androidInitialize = new AndroidInitializationSettings('ic_launcher');
    var iOSIntialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
      android: androidInitialize, iOS: iOSIntialize);
    localNotifications = new FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings);
  }

  Future _showNotification() async{
    var androidDetails = new AndroidNotificationDetails("channelId", "Local Notification", "This is a Notification",
    importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotifications.show(100, "Notif", "The body of the Notification", generalNotificationDetails);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('TES NOTIFICATION'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.notifications),
        onPressed: _showNotification,
      ),
    );
  }
}