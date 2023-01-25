import 'package:chatapp/constants.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
User? login;

class ChatScreen extends StatefulWidget {
  static String id = '/chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? message;
  final controllertext = TextEditingController();
  void getCurrentuser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        login = user;
      }
      print(login!.email);
    } catch (e) {
      print(e);
    }
  }

  void getMessage() async {
    await for (var snapshot in _firestore.collection('message').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentuser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Messagestream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controllertext,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      _firestore
                          .collection('message')
                          .add({'text': message, 'sender': login!.email});
                      controllertext.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Messagestream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection('message').snapshots(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.amberAccent.shade200),
            );
          }
          final messages = snapshot.data?.docs.reversed;
          List<Massagebox> messageWidget = [];
          for (var message in messages!) {
            final messagetext = message.data()['text'];
            final sender = message.data()['sender'];

            final messagefull = Massagebox(
              messagetext: messagetext,
              sender: sender,
              isuser: login!.email == sender,
            );
            messageWidget.add(messagefull);
          }

          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              children: messageWidget,
            ),
          );
        }));
  }
}

class Massagebox extends StatelessWidget {
  Massagebox({this.messagetext, this.sender, this.isuser});

  final String? messagetext;
  final String? sender;
  final bool? isuser;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isuser! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender.toString(),
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            borderRadius: isuser!
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            elevation: 5.0,
            color: isuser! ? Colors.amber.shade200 : Colors.green.shade200,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$messagetext ',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
