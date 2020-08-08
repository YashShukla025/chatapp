import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'auth.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignedIn;
  final baseAuth auth;
  LoginPage({this.auth, this.onSignedIn});

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType { login, register, googleSignIn }
FormType _formType = FormType.login;
bool formTypeReturn() {
  if (_formType == FormType.googleSignIn) {
    return true;
  } else {
    return false;
  }
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  String _email, _password,_name,_about;

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (_formType == FormType.googleSignIn || validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userID =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('login Success $userID');
        } else if (_formType == FormType.googleSignIn) {
          String userID = await widget.auth.signedInWithGoogle();
          googleSignIn();
          print('Google Login Success');
        } else {
          String userID = await widget.auth
              .createUserWithEmailAndPassword(_email, _password,_name,_about);
          print(userID);
          print('Register Success $userID');
        }
        widget.onSignedIn();
      } catch (e) {
        print(e);
        print('main fail');
      }
    }
  }

  void moveToRegister() {
    formkey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formkey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }
  void signInWithEmailAndPassword() {
    setState(() {
      _formType = FormType.login;
    });
  }
  void googleSignIn() {
    setState(() {
      _formType = FormType.googleSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Login page'),
        ),
        body: Padding(
          padding: EdgeInsets.all(25.0),  
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: buildInputs() + buildSubmitButtons(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    return [
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Enter Email',
          icon: Icon(Icons.mail_outline),
        ),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Enter Password',
          icon: Icon(Icons.vpn_key),
        ),
        obscureText: true,
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login || _formType == FormType.googleSignIn) {
      return [
        RaisedButton.icon(
            label: Text('Login'),
            onPressed: (){
              signInWithEmailAndPassword();
              validateAndSubmit();
            },
            icon: Icon(Icons.lock_outline)),
        SignInButton(
          Buttons.Google,
          text: "Sign up with Google",
          onPressed: () {
            googleSignIn();
            validateAndSubmit();
          },
        ),
        FlatButton(
          child: Text('Create an account'),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Enter Name',
            icon: Icon(Icons.supervised_user_circle),
          ),
          validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
          onSaved: (value) => _name = value.trim(),
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'About',
            icon: Icon(Icons.library_books),
          ),
          validator: (value) => value.isEmpty ? 'About can\'t be empty' : null,
          onSaved: (value) => _about = value.trim(),
        ),

        RaisedButton.icon(
          label: Text('Create an account'),
          onPressed: validateAndSubmit,
          icon: Icon(Icons.lock_outline),
        ),
        FlatButton(
          child: Text('Already have account ? Login'),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
