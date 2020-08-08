import 'package:flutter/material.dart';
import 'auth.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mainChatPage.dart';
import 'userList.dart';
import 'groupList.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
Firestore _firestore = Firestore.instance;
dynamic _currentUserEmail = '';
dynamic connectedUserlist;

class HomePage extends StatefulWidget {
  final baseAuth auth;
  final VoidCallback onSingedout;
  final String currentuser;
  HomePage({this.auth, this.onSingedout, this.currentuser});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _signedOut() async {
    try {
      if (formTypeReturn()) {
        await widget.auth.signOutGoogle();
        widget.onSingedout();
        print('google signout');
      }
      await widget.auth.signedOut();
      widget.onSingedout();
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    _currentUserEmail = widget.currentuser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('ChatApp'),
          actions: <Widget>[
            FlatButton(
              child: Text('Logout'),
              onPressed: _signedOut,
            ),
          ],
        ),
        body: connectedUserPage(widget.auth),

      ),
    );
  }
}

class connectedUserPage extends StatefulWidget {
  baseAuth auth;
  connectedUserPage(auth) {
    this.auth = auth;
  }

  @override
  _connectedUserPage createState() => _connectedUserPage();
}
class _connectedUserPage extends State<connectedUserPage> {
  int bottomSelectedIndex = 0;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index, duration: Duration(milliseconds: 150) , curve: Curves.ease);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            pageChanged(index);
          });
        },
        children: <Widget>[
          Scaffold(
            body: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(
                  '/chatapp/users/UserList/$_currentUserEmail/connections')
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
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => MainChatPage(_currentUserEmail,ds['name'],ds['email'],ds['profilePic'],ds['chatId'])));
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
              child: Icon(Icons.message),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => userList(_currentUserEmail)));
              },
            ),

          ),
          GroutList(_currentUserEmail),
        ],

      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: bottomSelectedIndex,
        height: 50,
        color: Colors.teal,
        buttonBackgroundColor:Colors.white,
        backgroundColor: Colors.white,
        items: <Widget>[
          Icon(Icons.person, size: 30),
          Icon(Icons.people, size: 30),
        ],
        onTap: (index) {
          setState(() {
            bottomTapped(index);
          });

        },
      ),
    );

  }
}




