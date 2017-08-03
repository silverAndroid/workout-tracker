import 'package:flutter/material.dart';

class MyCard extends Card {

  final GestureTapCallback onTap;

  MyCard({Key key, Color color, double elevation = 2.0, Widget child, this.onTap}) : super(key: key, color: color, elevation: elevation, child: child);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onTap,
      child: super.build(context)
    );
  }
}