import 'package:flutter/material.dart';

class MyCard extends Card {

  GestureTapCallback onTap;

  MyCard({Key key, Color color, int elevation = 2, Widget child, this.onTap}) : super(key: key, color: color, elevation: elevation, child: child);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onTap,
      child: super.build(context)
    );
  }
}