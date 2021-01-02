import "package:flutter/material.dart";
import "myhome.dart";
import "register.dart";
import "variable.dart";
import "package:firebase_auth/firebase_auth.dart";

class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  bool _isSigned = false;
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          _isSigned = true;
        });
      } else {
        setState(() {
          _isSigned = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isSigned ? MyHome() : Login(),
    );
  }
}

class Login extends StatefulWidget {
  static const routeName = 'login';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _email = TextEditingController();
  var _pass = TextEditingController();
  bool _isValid = false;
  bool _isValid1 = false;
  bool _isLoad = false;

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

  loginUser(BuildContext ctx) async {
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

    if (_email.text.trim().isEmpty) {
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );
    } on FirebaseAuthException catch (err) {
      setState(() {
        _isLoad = false;
      });
      if (err.code == "user-not-found") {
        dialogShow(
          ctx,
          "No Account exist with this Email Id, Please Sign Up first",
        );
      }

      if (err.code == "wrong-password") {
        dialogShow(
          ctx,
          "Please Enter Correct Password",
        );
      }
      if (err.code == "invalid-email") {
        dialogShow(
          ctx,
          "Please Enter a valid Email Id ",
        );
      }
      // if (err.code == '') {
      //   dialogShow(
      //     ctx,
      //     "Please Check your Internet Connectivity",
      //   );
      // }
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
                        hintText: 'Email',
                        hintStyle: myStyle(15),
                        prefixIcon: Icon(Icons.email_outlined),
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
                        hintStyle: myStyle(15),
                        prefixIcon: Icon(Icons.lock_outline),
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
                        '* Email should not be empty',
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
                    onTap: _isLoad ? () {} : () => loginUser(context),
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
                              "Login",
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
                        "Don't have an Account?",
                        style: myStyle(15, Colors.grey, FontWeight.w500),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(Register.routeName),
                        child: Text(
                          "SignUp",
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
