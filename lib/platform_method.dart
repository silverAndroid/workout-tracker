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

  Future<String> runTransaction(List<String> queries, List<List<dynamic>> params, bool writeToDB) {
    if (queries.length != params.length) {
      throw new Exception('Query length does not match param length!');
    }

    List<Map<String, dynamic>> queriesList = [];
    for (int i = 0, length = queries.length; i < length; i++) {
      String query = queries[i];
      Map<String, dynamic> json = {
        'query': query,
        'params': params[i],
      };
      queriesList.add(json);
    }
    Map<String, dynamic> json = {
      'queries': queriesList,
      'write': writeToDB,
    };
    print(JSON.encode(json).toString());
    try {
      return dbPlatform.invokeMethod('transaction', JSON.encode(json).toString());
    } on PlatformException catch (e) {
      print('Failed to run transaction');
      print(e.message);
    }
    return new Future<String>.value("[]");
  }
}