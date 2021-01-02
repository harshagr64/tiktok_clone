import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";

import "variable.dart";

import "navigation.dart";

class Register extends StatefulWidget {
  static const routeName = 'register';
  @override
  _RegisterState createState() => _RegisterState();
}

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class _RegisterState extends State<Register> {
  var _email = TextEditingController();
  var _pass = TextEditingController();
  var _user = TextEditingController();
  bool _isValid = false;
  bool _isValid1 = false;
  bool _isLoad = false;
  authProblems errorType;

  dialogShow(BuildContext ctx, content) {
    return showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: Text("Error Occured!"),
        content: Text(content),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Okay',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void regUser(ctx) async {
    setState(() {
      _isValid = false;
      _isValid1 = false;
      _isLoad = true;
    });
    if (_pass.text.trim().length < 7 || _pass.text.trim().contains(" ")) {
      setState(() {
        _isValid = true;
        _isLoad = false;
      });
      return;
    }
    setState(() {
      _isValid = false;
    });

    if (_email.text.trim().isEmpty || _user.text.trim().isEmpty) {
      setState(() {
        _isValid1 = true;
        _isLoad = false;
      });
      return;
    }

    setState(() {
      _isValid1 = false;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _pass.text,
      );
      User user = userCredential.user;
      cloudInstance.collection('users').doc(user.uid).set({
        'email': _email.text.trim(),
        'username': _user.text.trim(),
        'password': _pass.text.trim(),
        'profilepic': 'https://picsum.photos/250?image=9',
        'id': user.uid,
      });
      Navigator.of(context).pushReplacementNamed(Login.routeName);
    } on FirebaseAuthException catch (err) {
      setState(() {
        _isLoad = false;
      });
      print(err.code);
      if (err.code == 'email-already-in-use') {
        dialogShow(ctx, 'This Email Id already exists');
      }
      if (err.code == 'invalid-email') {
        dialogShow(ctx, 'Please Enter a valid Email Id');
      }
      if (err.code == '') {
        dialogShow(ctx, 'Please check your Internet Connectivity');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.red[200],
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: Image.asset(
              'assets/images/guitar.jpg',
              fit: BoxFit.cover,
              color: Colors.black54,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to TikTok",
                    style: myStyle(
                      25,
                      Colors.white,
                      FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 55,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    width: double.infinity,
                    child: TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        hintText: 'Email',
                        hintStyle: myStyle(15),
                        prefixIcon:
                            Icon(Icons.email_outlined, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 55,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    width: double.infinity,
                    child: TextField(
                      controller: _user,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        hintText: 'Username',
                        hintStyle: myStyle(15),
                        prefixIcon:
                            Icon(Icons.person_outline, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 55,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    width: double.infinity,
                    child: TextField(
                      controller: _pass,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Password',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: _isValid
                                ? BorderSide(
                                    color: Colors.redAccent,
                                    width: 2,
                                  )
                                : BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  )),
                        hintStyle: myStyle(15),
                        prefixIcon:
                            Icon(Icons.lock_outline, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  if (_isValid)
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        '* Password length should be > 6 Characters & no Spaces',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_isValid1)
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        '* Text Fields should not be empty',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: _isLoad ? () {} : () => regUser(context),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: MediaQuery.of(context).size.width / 2,
                      child: _isLoad
                          ? SizedBox(
                              height: 50,
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              "Sign Up",
                              style: myStyle(20, Colors.white),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an Account?",
                        style: myStyle(15, Colors.grey, FontWeight.w500),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(Login.routeName),
                        child: Text(
                          "Login",
                          style: myStyle(15, Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
