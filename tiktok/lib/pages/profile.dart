import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import "../variable.dart";

class Profile extends StatefulWidget {
  final uid;
  Profile(this.uid);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName;
  String profilePic;
  String onlineUser;
  int likes = 0;
  bool _isDataThere = false;
  TextEditingController _userNameCon = TextEditingController();

  var followUsers;
  var followingUser;
  bool _isFollow = false;

  Future<QuerySnapshot> myVideos;

  @override
  void initState() {
    getAllData();
    super.initState();
  }

  getAllData() async {
    print(widget.uid);
    // get videos data
    myVideos = cloudInstance
        .collection('videos')
        .where('uid', isEqualTo: widget.uid)
        .get();

// get user data
    final userDoc =
        await cloudInstance.collection('users').doc(widget.uid).get();
    // print('hello ${userDoc.data()}');
    userName = userDoc.data()['username'];
    profilePic = userDoc.data()['profilepic'];

    // get likes
    final doc = await myVideos;

    // get followers details

    final followDoc = await cloudInstance
        .collection('users')
        .doc(widget.uid)
        .collection('followers')
        .get();

    // get following detail

    final follwingDoc = await cloudInstance
        .collection('users')
        .doc(widget.uid)
        .collection('following')
        .get();

    followUsers = followDoc.docs.length;
    followingUser = follwingDoc.docs.length;

    cloudInstance
        .collection('users')
        .doc(widget.uid)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then(
      (doc) {
        if (!doc.exists) {
          setState(() {
            _isFollow = false;
          });
        } else {
          setState(() {
            _isFollow = true;
          });
        }
      },
    );

    for (final item in doc.docs) {
      likes = item.data()['likes'].length + likes;
    }
    setState(() {
      _isDataThere = true;
    });
  }

  // follow user
  followUser() async {
    var doc = await cloudInstance
        .collection('users')
        .doc(widget.uid)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (!doc.exists) {
      cloudInstance
          .collection('users')
          .doc(widget.uid)
          .collection('followers')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({});

      cloudInstance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('following')
          .doc(widget.uid)
          .set({});
      setState(() {
        _isFollow = true;
        followUsers++;
      });
    } else {
      cloudInstance
          .collection('users')
          .doc(widget.uid)
          .collection('followers')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .delete();

      cloudInstance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('following')
          .doc(widget.uid)
          .delete();
      setState(() {
        _isFollow = false;
        followUsers--;
      });
    }
  }

  //edit profile
  editProfile(uid) {
    return showDialog(
        context: context,
        builder: (ctx) => Dialog(
              child: Container(
                alignment: Alignment.center,
                height: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hey, Edit your Profile",
                      style: myStyle(18, Colors.black, FontWeight.w500),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: TextFormField(
                        controller: _userNameCon,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: myStyle(
                            18,
                            Colors.grey,
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        cloudInstance.collection('users').doc(uid).update(
                          {'username': _userNameCon.text.trim()},
                        );
                        setState(() {
                          userName = _userNameCon.text.trim();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 2,
                        height: 40,
                        color: Colors.redAccent,
                        child: Text(
                          "Update",
                          style: myStyle(
                            18,
                            Colors.white,
                            FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isDataThere == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 12),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        profilePic,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      userName,
                      style: myStyle(
                        18,
                        Colors.black,
                        FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          followUsers.toString(),
                          style: myStyle(
                            16,
                            Colors.black,
                            FontWeight.w500,
                          ),
                        ),
                        Text(
                          followingUser.toString(),
                          style: myStyle(
                            16,
                            Colors.black,
                            FontWeight.w500,
                          ),
                        ),
                        Text(
                          likes.toString(),
                          style: myStyle(
                            16,
                            Colors.black,
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Followers',
                          style: myStyle(
                            16,
                            Colors.black54,
                            FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Following',
                          style: myStyle(
                            16,
                            Colors.black54,
                            FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Likes',
                          style: myStyle(
                            16,
                            Colors.black54,
                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    widget.uid == FirebaseAuth.instance.currentUser.uid
                        ? InkWell(
                            onTap: () => editProfile(
                                FirebaseAuth.instance.currentUser.uid),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Edit Profile",
                                style: myStyle(
                                  18,
                                  Colors.white,
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () => followUser(),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _isFollow ? "Unfollow" : "Follow",
                                style: myStyle(
                                  18,
                                  Colors.white,
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "My Videos",
                      style: myStyle(
                        18,
                        Colors.black,
                        FontWeight.w500,
                      ),
                    ),
                    FutureBuilder(
                      future: myVideos,
                      builder: (ctx, snapShot) {
                        if (!snapShot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapShot.data.docs.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 5,
                          ),
                          itemBuilder: (ctx, index) => Container(
                            child: Image(
                              image: NetworkImage(
                                snapShot.data.docs[index]['previewimage'],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
