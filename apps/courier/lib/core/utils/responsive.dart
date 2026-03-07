import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mq;
  static late double screenWidth;
  static late double screenHeight;
  static late double bh;
  static late double bv;
  static late bool isTablet;
  static late bool isPhone;

  static void init(BuildContext context) {
    _mq = MediaQuery.of(context);
    screenWidth = _mq.size.width;
    screenHeight = _mq.size.height;
    bh = screenWidth / 100;
    bv = screenHeight / 100;
    isPhone = screenWidth < 600;
    isTablet = screenWidth >= 600;
  }

  static double w(double p) => bh * p;
  static double h(double p) => bv * p;
  static double sp(double s) => (s * (screenWidth / 375)).clamp(s * 0.8, s * 1.4);
  static T value<T>({required T phone, required T tablet}) => isTablet ? tablet : phone;
  static EdgeInsets padding({double horizontal = 0, double vertical = 0}) => EdgeInsets.symmetric(horizontal: horizontal * (isTablet ? 1.5 : 1), vertical: vertical);
}
