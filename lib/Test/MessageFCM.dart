import 'package:flutter/material.dart';

import 'messageing_widget.dart';

class MessageFCM extends StatefulWidget {
  @override
  _MessageFCMState createState() => _MessageFCMState();
}

class _MessageFCMState extends State<MessageFCM> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM TEST'),
      ),
      body: MessagingWidged(),
    );
  }
}
