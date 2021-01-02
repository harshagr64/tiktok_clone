import "package:flutter/material.dart";

import "package:image_picker/image_picker.dart";
import "../confirm.dart";
import "dart:io";
import 'package:tiktok/variable.dart';

class Create extends StatefulWidget {
  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> {
  pickVideo(ImageSource src) async {
    Navigator.pop(context);
    final video = await ImagePicker().getVideo(source: src);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Confirm(File(video.path), video.path, src),
      ),
    );
  }

  dialogShow(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text("Open with"),
        children: [
          SimpleDialogOption(
            onPressed: () => pickVideo(ImageSource.gallery),
            child: Text(
              "Gallery",
            ),
          ),
          SimpleDialogOption(
            onPressed: () => pickVideo(ImageSource.camera),
            child: Text("Camera"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: InkWell(
          onTap: () => dialogShow(context),
          child: Container(
            alignment: Alignment.center,
            height: 70,
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              "Upload TIkTok",
              style: myStyle(18, Colors.white, FontWeight.normal),
            ),
          ),
        ),
      ),
    );
  }
}
