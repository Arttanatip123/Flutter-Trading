import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:myapp/Test/message_model.dart';

class MessagingWidged extends StatefulWidget{
  @override
  _MessagingWidgedState createState() => _MessagingWidgedState();
}

class _MessagingWidgedState extends State<MessagingWidged> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];


  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
         print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          messages.add(Message(title: notification['title'], body: notification['body']));
        });
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


  @override
  Widget build(BuildContext context) {
    return ListView(
      children: messages.map(buildMessage).toList(),
    );
  }

  Widget buildMessage(Message message) {
    return ListTile(
      title: Text(message.title),
      subtitle: Text(message.body),
    );
  }
}