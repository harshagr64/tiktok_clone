import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tiktok/pages/profile.dart';
import 'package:tiktok/variable.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot> searchedUser;
  searchUser(String typesUser) {
    var users = cloudInstance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: typesUser)
        .get();

    setState(() {
      searchedUser = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffECE5DA),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextFormField(
            style: myStyle(
              18,
              Colors.white,
              FontWeight.w500,
            ),
            cursorColor: Colors.white,
            onFieldSubmitted: searchUser,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintText: 'Search Here',
              hintStyle: myStyle(
                16,
                Colors.white,
                FontWeight.w500,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black87,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
      body: searchedUser == null
          ? Center(
              child: Text(
                "Search for a TikToker",
                style: myStyle(
                  20,
                  Colors.black,
                  FontWeight.w500,
                ),
              ),
            )
          : FutureBuilder(
              future: searchedUser,
              builder: (ctx, snapShot) {
                if (!snapShot.hasData) {
                  return Center(
                    child: Text("Searching..."),
                  );
                }

                return ListView.builder(
                  itemCount: snapShot.data.docs.length,
                  itemBuilder: (ctx, index) => InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => Profile(
                          snapShot.data.docs[index]['id'],
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                            snapShot.data.docs[index]['profilepic']),
                      ),
                      title: Text(
                        snapShot.data.docs[index]['username'],
                        style: myStyle(
                          18,
                          Colors.black,
                          FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
