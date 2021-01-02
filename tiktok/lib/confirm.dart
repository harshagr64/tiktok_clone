import 'dart:io';

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import 'package:tiktok/variable.dart';
import 'package:video_player/video_player.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:flutter_video_compress/flutter_video_compress.dart";

class Confirm extends StatefulWidget {
  static const routeName = 'confirm';
  final File videoFile;
  final String videoPath;
  final ImageSource imageSource;
  Confirm(this.videoFile, this.videoPath, this.imageSource);
  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  VideoPlayerController _controller;
  TextEditingController _songController = TextEditingController();
  TextEditingController _capController = TextEditingController();
  FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();
  bool _isLoading = false;
  @override
  void initState() {
    setState(() {
      _controller = VideoPlayerController.file(widget.videoFile);
    });

    _controller.initialize();
    _controller.play();
    _controller.setVolume(1);
    _controller.setLooping(true);

    super.initState();
  }

  uploadVideo(BuildContext ctx) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser.uid;
      DocumentSnapshot userDocs =
          await cloudInstance.collection('users').doc(uid).get();
      var allDocs = await cloudInstance.collection('videos').get();
      int length = allDocs.docs.length;
      String video = await videoUrl('video $length');
      String preImage = await prevImage('video $length');
      cloudInstance.collection('videos').doc('video $length').set({
        'username': userDocs.data()['username'],
        'uid': uid,
        'profilepic': userDocs.data()['profilepic'],
        'likes': [],
        'comments': 0,
        'shares': 0,
        'songname': _songController.text,
        'caption': _capController.text,
        'videosurl': video,
        'vid': 'video $length',
        'previewimage': preImage,
      });
      Navigator.pop(context);
    } catch (error) {
      print("hello there is some error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  videoUrl(String id) async {
    final storageUploadTask =
        videoFolder.child(id).putFile(await compressVideo());
    final snapShot1 = await storageUploadTask.onComplete;
    final url = await snapShot1.ref.getDownloadURL();
    return url;
  }

  prevImage(String id) async {
    final storageUploadTask =
        imagesFolder.child(id).putFile(await getPreviewImage());
    final snapShot1 = await storageUploadTask.onComplete;
    final url = await snapShot1.ref.getDownloadURL();
    return url;
  }

  getPreviewImage() async {
    final prevImage =
        await flutterVideoCompress.getThumbnailWithFile(widget.videoPath);
    return prevImage;
  }

  compressVideo() async {
    if (widget.imageSource == ImageSource.gallery) {
      return widget.videoFile;
    }
    final compressVideo = await flutterVideoCompress.compressVideo(
      widget.videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return File(compressVideo.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Uploading..."),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width,
                    child: VideoPlayer(_controller),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            controller: _songController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Song Name',
                              hintStyle: myStyle(15),
                              prefixIcon: Icon(
                                Icons.music_note,
                                color: Colors.grey,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            controller: _capController,
                            decoration: InputDecoration(
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              fillColor: Colors.white,
                              hintText: 'Caption',
                              hintStyle: myStyle(15),
                              prefixIcon: Icon(
                                Icons.closed_caption,
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        padding: EdgeInsets.all(15),
                        onPressed: () => uploadVideo(context),
                        color: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Upload",
                          style: myStyle(
                            15,
                            Colors.white,
                          ),
                        ),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.redAccent,
                        child: Text(
                          "Retake",
                          style: myStyle(
                            15,
                            Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
