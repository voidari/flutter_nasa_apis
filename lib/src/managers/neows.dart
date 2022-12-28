// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/managers/database_manager.dart';
import 'package:nasa_apis/src/managers/request_manager.dart';
import 'package:nasa_apis/src/models/apod_item.dart';
import 'package:nasa_apis/src/models/apod_item_model.dart';
import 'package:nasa_apis/src/util.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

/// The manager for Near Earth Object Web Service requests, providing a framework
/// and caching options to reduce the API key usage.
class NasaNeoWs {
  static const String _cClass = "NasaNeows";

  static final String _cEndpoint = p.join("neo", "rest", "v1");
  static final String _cFeedEndpoint = p.join(_cEndpoint, "feed");
  static final String _cLookupEndpoint = p.join(_cEndpoint, "neo");
  static final String _cBrowseEndpoint = p.join(_cEndpoint, "neo", "browse");

  static const String _cParamStartDate = "start_date";
  static const String _cParamEndDate = "end_date";
  static const String _cAsteroidId = "asteroid_id";

  static late bool _cacheSupport;
  static late Duration? _defaultCacheExpiration;

  /// Initializes the NeoWs manager. This is for internal use only. Use the
  /// NASA initialization function.
  static void init(
      {bool cacheSupport = true,
      Duration? defaultCacheExpiration = const Duration(hours: 1)}) {
    _cacheSupport = cacheSupport;
    _defaultCacheExpiration = defaultCacheExpiration;

    if (_cacheSupport) {
      // Start the loop timer for the specified duration
      Timer.periodic(const Duration(minutes: 1), (timer) {
        _deleteExpiredCache();
      });
    }
  }

  /// The update loop that checks for expired rows. Removes expired entries.
  static Future<void> _deleteExpiredCache() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    DatabaseManager.getConnection().delete(ApodItemModel.tableName,
        where: "${ApodItemModel.keyExpiration} < $now AND "
            "${ApodItemModel.keyExpiration} > 0");
  }

  /// Requests APOD matching the provided [date]. The tuple returned will
  /// contain a http response code for understanding failures, and an APOD
  /// item if the request was successful.
  static Future<Tuple2<int, ApodItem?>> requestFeed(DateTime startDate,
      {DateTime? endDate}) async {
    Tuple2<int, List<ApodItem>?> results = await requestByRange(date, date);
    ApodItem? item;
    if (results.item2 != null && results.item2!.isNotEmpty) {
      item = results.item2![0];
    }
    return Tuple2(results.item1, item);
  }
}
