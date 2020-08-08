import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
Firestore _firestore=Firestore.instance;
class userList extends StatelessWidget {
  dynamic currentUserEmail;
  userList(currentUserEmail){
    this.currentUserEmail=currentUserEmail;
  }
  createChatConnection(email) async {
    String name, about, profilPic;
    var j = email.toString().split("@");
    var yy = currentUserEmail.toString().split("@");
    String chatId = j[0] + '_' + yy[0];
    DocumentSnapshot result = await _firestore
        .collection('chatapp/users/UserList')
        .document(currentUserEmail)
        .get();
    name = result['name'];
    about = result['about'];
    profilPic = result['profilePic'];
    _firestore
        .collection('chatapp/users/UserList')
        .document(email)
        .collection('connections')
        .document(currentUserEmail)
        .setData({
      'chatId': chatId,
      'name': name,
      'profilePic': profilPic,
      'about': about
    });
    result = await _firestore
        .collection('chatapp/users/UserList')
        .document(email)
        .get();
    name = result['name'];
    about = result['about'];
    profilPic = result['profilePic'];
    _firestore
        .collection('chatapp/users/UserList')
        .document(currentUserEmail)
        .collection('connections')
        .document(email)
        .setData({
      'chatId': chatId,
      'name': name,
      'profilePic': profilPic,
      'about': about
    });
    _firestore
        .collection('/chatapp/messages/solo')
        .document(chatId)
        .collection('chats').document('default').setData({'email': null});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("User List"),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection("chatapp/users/UserList").snapshots(),
          builder: (context, snap) {
            if (snap.hasData && !snap.hasError && snap.data != null) {
              return ListView.builder(
                itemCount: snap.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snap.data.documents[index];
                  if (ds['email'] != currentUserEmail) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 15,
                        child: Image.network(ds['profilePic']),
                      ),
                      title: Text(ds['name']),
                      subtitle: Text(ds['about']),
                      onTap: () {
                        createChatConnection(ds['email']);
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    return SizedBox(
                      height: 0,
                    );
                  }
                },
              );
            } else
              return Text("No data found");
          },
        ),
      ),
    );
  }
}