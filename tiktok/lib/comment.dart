import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:tiktok/variable.dart';
import "variable.dart";
import "package:timeago/timeago.dart" as ta;

class Comment extends StatefulWidget {
  final vid;
  Comment(this.vid);
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  String uid;
  TextEditingController _comController = TextEditingController();
  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;

    super.initState();
  }

  uploadComment() async {
    final userDocs = await cloudInstance.collection('users').doc(uid).get();
    final allDocs = await cloudInstance
        .collection('videos')
        .doc(widget.vid)
        .collection('comments')
        .get();
    int length = allDocs.docs.length;
    await cloudInstance
        .collection('videos')
        .doc(widget.vid)
        .collection("comments")
        .doc('comment $length')
        .set({
      'username': userDocs.data()['username'],
      'uid': uid,
      'profilepic': userDocs.data()['profilepic'],
      'comment': _comController.text.trim(),
      'likes': [],
      'time': DateTime.now(),
      'id': 'comment $length',
    });
    _comController.clear();

    final vdocs =
        await cloudInstance.collection('videos').doc(widget.vid).get();
    await cloudInstance.collection('videos').doc(widget.vid).update({
      'comments': vdocs['comments'] + 1,
    });
  }

  likeComment(String cid) async {
    final doc = await cloudInstance
        .collection('videos')
        .doc(widget.vid)
        .collection('comments')
        .doc(cid)
        .get();

    if (doc.data()['likes'].contains(uid)) {
      await cloudInstance
          .collection('videos')
          .doc(widget.vid)
          .collection('comments')
          .doc(cid)
          .update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await cloudInstance
          .collection('videos')
          .doc(widget.vid)
          .collection('comments')
          .doc(cid)
          .update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: StreamBuilder(
                    stream: cloudInstance
                        .collection('videos')
                        .doc(widget.vid)
                        .collection('comments')
                        .snapshots(),
                    builder: (ctx, snapShot) {
                      if (!snapShot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapShot.data.docs.length,
                        itemBuilder: (ctx, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  snapShot.data.docs[index]['profilepic'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              '${snapShot.data.docs[index]['username']}',
                              style: myStyle(16, Colors.white, FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${snapShot.data.docs[index]['comment']}',
                                  style:
                                      myStyle(14, Colors.grey, FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${ta.format(snapShot.data.docs[index]['time'].toDate())}',
                                      style: myStyle(
                                          13, Colors.grey, FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "${snapShot.data.docs[index]['likes'].length} Likes",
                                      style: myStyle(
                                        13,
                                        Colors.grey,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: InkWell(
                              onTap: () =>
                                  likeComment(snapShot.data.docs[index]['id']),
                              child: snapShot.data.docs[index]['likes']
                                      .contains(uid)
                                  ? Icon(Icons.favorite,
                                      color: Colors.redAccent)
                                  : Icon(
                                      Icons.favorite_border_outlined,
                                      color: Colors.white,
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Divider(),
              ListTile(
                title: TextFormField(
                  controller: _comController,
                  cursorColor: Colors.white,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your Comment Here',
                    hintStyle: myStyle(
                      15,
                      Colors.grey,
                      FontWeight.normal,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                trailing: FlatButton(
                  color: Colors.redAccent,
                  onPressed: () => uploadComment(),
                  child: Text(
                    'Post',
                    style: myStyle(16, Colors.white, FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
