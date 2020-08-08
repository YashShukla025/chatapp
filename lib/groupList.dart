import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Firestore _firestore=Firestore.instance;

class GroutList extends StatelessWidget {
  dynamic currentUserEmail;
  GroutList(currentUserEmail){
    this.currentUserEmail=currentUserEmail;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection(
            '/chatapp/users/UserList/$currentUserEmail/connections')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData && !snap.hasError && snap.data != null) {
            return ListView.builder(
              itemCount: snap.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snap.data.documents[index];
                return Container(
                  decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                        ),
                      )
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      child: Image.network(ds['profilePic']),
                    ),
                    title: Text(ds['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(ds['about']),
                    onTap: () {

                    },
                  ),
                );
              },
            );
          } else
            return Text("No data found");
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: Icon(Icons.person_add),
        onPressed: () {
//          Navigator.push(
//              context, MaterialPageRoute(builder: (context) => userList(_currentUserEmail)));
        },
      ),
    );
  }
}
