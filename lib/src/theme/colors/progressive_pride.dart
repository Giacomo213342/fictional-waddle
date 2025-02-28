import 'package:flutter/animation.dart';

abstract class ProgressiveColors {
  const ProgressiveColors._();

  static const rainPurple = Color(0xff6d2380);
  static const rainBlue = Color(0xff2c58a4);
  static const rainGreen = Color(0xff78b82a);
  static const rainYellow = Color(0xffefe524);
  static const rainOrange = Color(0xfff28917);
  static const rainRed = Color(0xffe22016);
  static const black = Color(0xff000000);
  static const brown = Color(0xff945516);
  static const transBlue = Color(0xff7bcce5);
  static const transPink = Color(0xfff4aec8);
  static const transWhite = Color(0xffffffff);
  static const interYellow = Color(0xfffdd817);
  static const interPurple = Color(0xff66338b);

  static const sequence = [
    rainPurple,
    rainBlue,
    rainGreen,
    rainYellow,
    rainOrange,
    rainRed,
    black,
    brown,
    transBlue,
    transPink,
    transWhite,
    interYellow,
    interPurple,
  ];
}
