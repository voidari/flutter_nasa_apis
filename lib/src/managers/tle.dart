// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

/*

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/managers/database_manager.dart';
import 'package:nasa_apis/src/models/tle_item.dart';
import 'package:nasa_apis/src/util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

/// A context class used to track a pageable view of TLE objects.
class TleContext {
  /// The context of the TLE view.
  String context;
  /// The ID of the context.
  String id;
  /// The type of context view being queried.
  String type;
  /// The total number of items available in the context.
  int totalItems;

  /// The constructor of the context.
  TleContext(this.context, this.id, this.type, this.totalItems);

  /// A static constructor of the TLE context.
  static Future<TleContext?> create(String data) async {
    Map<String, dynamic> map = jsonDecode(data);
    
  } 
}

/// The manager for TLE (Two-line element) requests, which consist of earth
/// orbiting objects, satellites, and debris, and provides framework/caching
/// options to reduce data usage.
class CelesTrakTle {
  static const String _cClass = "CelesTrakTle";

  static const String _cScheme = "https";
  static const String _cHostname = "tle.ivanstanojevic.me";
  static const String _cSearchNameEndpoint = "/api/tle?search={q}";
  static const String _cIdEndpoint = "/api/tle/{q}";

  static late bool _cacheSupport;
  static late Duration? _defaultCacheExpiration;

  /// Initializes the manager. This is for internal use only. Use the
  /// NASA initialization function.
  static void init(
      {bool cacheSupport = true,
      Duration? defaultCacheExpiration = const Duration(hours: 8)}) {
    _cacheSupport = cacheSupport;
    _defaultCacheExpiration = defaultCacheExpiration;

    if (_cacheSupport) {
      // Start the loop timer for the specified duration
      Timer.periodic(const Duration(seconds: 60), (timer) {
        _deleteExpiredCache();
      });
    }
  }

  /// The update loop that checks for expired rows. Removes expired entries.
  static Future<void> _deleteExpiredCache() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    /*
    DatabaseManager.getConnection().delete(ApodItemModel.tableName,
        where: "${ApodItemModel.keyExpiration} < $now AND "
            "${ApodItemModel.keyExpiration} > 0");
    */
  }

  /// Performs a search of all earth orbiting objects by the [name] of the
  /// object itself. Returns a list of TLE item elements.
  static Future<Tuple2<int, List<TleItem>>> searchByName(String name) async {
    return const Tuple2(600, <TleItem>[]);
  }

  /// Retrieves the TLE item of the matching [id] if the ID is valid.
  static Future<Tuple2<int, TleItem?>> getById(int id) async {
    return const Tuple2(600, null);
  }

  static Future<Tuple2<int, 

  /// Performs a request for APOD items given the provided date range between
  /// and including the [startDate] and [endDate]. The tuple reurned will
  /// contain the http response code for understanding failures, and an APOD
  /// item list if the request was successful.
  static Future<Tuple2<int, List<ApodItem>?>> request(
      DateTime startDate, DateTime endDate) async {
    // Drop the time element
    startDate = DateTime(startDate.toLocal().year, startDate.toLocal().month,
        startDate.toLocal().day);
    endDate = DateTime(
        endDate.toLocal().year, endDate.toLocal().month, endDate.toLocal().day);
    Log.out("requestByRange() startDate: $startDate, endDate: $endDate",
        name: _cClass);
    // Check bounds for eastern time
    DateTime currentEstTime = Util.getEstDateTime(dateOnly: true);
    if (startDate.isAfter(currentEstTime)) {
      startDate.subtract(const Duration(days: 1));
    }
    if (endDate.isAfter(currentEstTime)) {
      endDate.subtract(const Duration(days: 1));
    }
    // Validate the requested dates
    if (!_isValidDate(startDate) ||
        !_isValidDate(endDate) ||
        endDate.isBefore(startDate)) {
      Log.out("requestByRange() Start date or end date is invalid",
          name: _cClass);
      return const Tuple2(600, null);
    }

    // Check cache for the items if caching is allowed
    if (_cacheSupport && _defaultCacheExpiration != null) {
      final List<
          Map<String,
              dynamic>> maps = await DatabaseManager.getConnection().query(
          ApodItemModel.tableName,
          where:
              "${startDate.millisecondsSinceEpoch} <= ${ApodItemModel.keyDate} "
              "AND ${ApodItemModel.keyDate} <= ${endDate.millisecondsSinceEpoch}");
      if (maps.length == _daysInRange(startDate, endDate)) {
        Log.out(
            "requestByRange() A cache hit was found. Converting to return.");
        List<ApodItem> items = <ApodItem>[];
        // Add the items to the list and reset the cache
        DateTime now = DateTime.now();
        for (Map<String, dynamic> map in maps) {
          ApodItem item = ApodItem.fromMap(map);
          item.expiration = now.add(_defaultCacheExpiration!);
          items.add(item);
          await DatabaseManager.getConnection().update(
              ApodItemModel.tableName, item.toMap(),
              where:
                  "${ApodItemModel.keyDate} = ${item.date.millisecondsSinceEpoch}"
                  " AND ${ApodItemModel.keyLocalCategories} = ''",
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        return Tuple2(HttpStatus.ok, items);
      }
    }

    // Create the parameters for the request
    Map<String, String> params = <String, String>{};
    if (startDate.isAtSameMomentAs(endDate)) {
      params.putIfAbsent(_cParamDate, () => _toRequestDateFormat(startDate));
    } else {
      params.putIfAbsent(
          _cParamStartDate, () => _toRequestDateFormat(startDate));
      params.putIfAbsent(_cParamEndDate, () => _toRequestDateFormat(endDate));
    }
    params.putIfAbsent(_cParamThumbs, () => true.toString());

    // Perform the request
    http.Response response = await RequestManager.get(_cEndpoint, params);
    List<ApodItem>? items;
    if (response.statusCode == HttpStatus.ok) {
      // Parse the response
      items = <ApodItem>[];
      dynamic jsonBody = json.decode(response.body);
      if (startDate.isAtSameMomentAs(endDate)) {
        items.add(ApodItem.fromMap(jsonBody));
      } else {
        for (dynamic jsonItem in jsonBody) {
          items.add(ApodItem.fromMap(jsonItem));
        }
      }

      // Cache the response if caching is support
      if (_cacheSupport && _defaultCacheExpiration != null) {
        DateTime expiration = DateTime.now().add(_defaultCacheExpiration!);
        for (ApodItem item in items) {
          item.expiration = expiration;
          await DatabaseManager.getConnection().insert(
            ApodItemModel.tableName,
            item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }

    return Tuple2(response.statusCode, items);
  }
}
*/
