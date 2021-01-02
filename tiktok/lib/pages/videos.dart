import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:tiktok/variable.dart';
import 'package:video_player/video_player.dart';
import "../widget/circle_animation.dart";
import "dart:io";
import "../comment.dart";
import "package:esys_flutter_share/esys_flutter_share.dart";
import "package:flutter/foundation.dart";

class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  Stream myStream;
  String userId;

  buildProfile(String url) {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: (60 / 2) - (50 / 2),
            child: Container(
              width: 50,
              height: 50,
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50 / 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: (60 / 2) - (20 / 2),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  buildMusic(String url) {
    return Container(
      height: 50,
      width: 50,
      padding: EdgeInsets.all(11.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[800],
            Colors.grey[700],
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  likeVideo(String vid) async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    final docs = await cloudInstance.collection('videos').doc(vid).get();
    if (docs.data()['likes'].contains(uid)) {
      cloudInstance.collection('videos').doc(vid).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      cloudInstance.collection('videos').doc(vid).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  shareVideo(String vid, String url) async {
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('TikTok', 'video.mp4', bytes, 'video/mp4');
    DocumentSnapshot doc =
        await cloudInstance.collection('videos').doc(vid).get();
    cloudInstance.collection('videos').doc(vid).update({
      'shares': doc.data()['shares'] + 1,
    });
  }

  @override
  void initState() {
    myStream = cloudInstance.collection('videos').snapshots();
    userId = FirebaseAuth.instance.currentUser.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder(
        stream: myStream,
        builder: (ctx, snapShot) {
          if (!snapShot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            itemBuilder: (ctx, index) => Stack(
              children: [
                // Videos Container
                VideoItem(snapShot.data.docs[index]['videosurl']),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Following',
                            style: myStyle(15, Colors.white, FontWeight.normal),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'For You',
                            style: myStyle(15, Colors.white, FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              height: 70,
                              padding: EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    snapShot.data.docs[index]['username'],
                                    style: myStyle(
                                        15, Colors.white, FontWeight.normal),
                                  ),
                                  Text(
                                    snapShot.data.docs[index]['caption'],
                                    style: myStyle(
                                        12, Colors.white, FontWeight.normal),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      Text(
                                        "Tera Yaar Hoon Main",
                                        style: myStyle(12, Colors.white,
                                            FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            margin: EdgeInsets.only(top: size.height / 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildProfile(
                                    snapShot.data.docs[index]['profilepic']),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => likeVideo(
                                          snapShot.data.docs[index]['vid']),
                                      child: Icon(
                                        Icons.favorite,
                                        size: 30,
                                        color: snapShot
                                                .data.docs[index]['likes']
                                                .contains(userId)
                                            ? Colors.redAccent
                                            : Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      snapShot.data.docs[index]['likes'].length
                                          .toString(),
                                      style: myStyle(15, Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => Comment(
                                              snapShot.data.docs[index]['vid']),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.comment,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      snapShot.data.docs[index]['comments']
                                          .toString(),
                                      style: myStyle(15, Colors.white),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => shareVideo(
                                          snapShot.data.docs[index]['vid'],
                                          snapShot.data.docs[index]
                                              ['videosurl']),
                                      child: Icon(
                                        Icons.reply,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      snapShot.data.docs[index]['shares']
                                          .toString(),
                                      style: myStyle(15, Colors.white),
                                    ),
                                  ],
                                ),
                                CircleAnimation(
                                  buildMusic(
                                      snapShot.data.docs[index]['profilepic']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right Section
                  ],
                ),
              ],
            ),
            itemCount: snapShot.data.docs.length,
          );
        },
      ),
    );
  }
}

class VideoItem extends StatefulWidget {
  final videoUrl;
  VideoItem(this.videoUrl);
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  VideoPlayerController _vidController;

  @override
  void initState() {
    _vidController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        _vidController.play();
        _vidController.setVolume(1);
        _vidController.setLooping(true);
      });
    super.initState();
  }


  @override
  void dispose() {
    _vidController.pause();
    _vidController.dispose();

    setState(() {
      _vidController = null;
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: VideoPlayer(_vidController));
  }
}
