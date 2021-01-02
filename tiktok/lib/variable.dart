import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import "package:firebase_storage/firebase_storage.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:path_provider/path_provider.dart';

TextStyle myStyle(double size, [Color color, FontWeight fw = FontWeight.w700]) {
  return GoogleFonts.montserrat(
    fontSize: size,
    color: color,
    fontWeight: fw,
  );
}

FirebaseFirestore cloudInstance = FirebaseFirestore.instance;

final videoFolder = FirebaseStorage.instance.ref().child('videos');
final imagesFolder = FirebaseStorage.instance.ref().child('images');
