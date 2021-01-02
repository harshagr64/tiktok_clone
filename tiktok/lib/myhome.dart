import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import "pages/create.dart";
import "pages/messages.dart";
import "pages/profile.dart";
import "pages/search.dart";
import "pages/videos.dart";

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  customIcon() {
    // print(FirebaseAuth.instance.currentUser.uid);
    return Container(
      height: 27,
      width: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10),
            width: 38,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 250, 45, 108),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10),
            width: 38,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 32, 211, 234),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          Center(
            child: Container(
              height: double.infinity,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List pagesOption = [
    Videos(),
    Search(),
    Create(),
    Messages(),
    Profile(FirebaseAuth.instance.currentUser.uid),
  ];
  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pagesOption[page],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
        currentIndex: page,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: customIcon(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
              size: 30,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
