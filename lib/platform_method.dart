import 'dart:async';
import 'dart:convert';

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

  Future<String> rawQuery(String query, List<dynamic> params, bool writeToDB,
      {bool isExecutable = false}) {
    if (query != null && query.isNotEmpty && params != null) {
      Map<String, dynamic> json = {
        'query': query,
        'params': params,
        'write': writeToDB,
        'executable': isExecutable
      };
      String jsonStr = JSON.encode(json);
      print(jsonStr);
      try {
        return dbPlatform.invokeMethod('query', jsonStr);
      } on PlatformException catch (e) {
        print('Failed to query db');
        print(e.message);
      }
    }
    return new Future<String>.value("[]");
  }
}