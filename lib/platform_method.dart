import 'package:flutter/services.dart';

class PlatformMethod {
  static final PlatformMethod _instance = new PlatformMethod._internal();
  PlatformMethodChannel dbPlatform;

  factory PlatformMethod() {
    return _instance;
  }

  PlatformMethod._internal() {
    dbPlatform = const PlatformMethodChannel('database');
  }
}