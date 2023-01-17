// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/managers/database_manager.dart';
import 'package:nasa_apis/src/managers/request_manager.dart';
import 'package:nasa_apis/src/apod/apod_item.dart';
import 'package:nasa_apis/src/apod/apod_item_model.dart';
import 'package:nasa_apis/src/util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

/// The container for the rovers, providing information for the API.
class Rover {
  String name;
  DateTime launchDate;
  DateTime? landDate;
  DateTime? lastContactDate;
  Rover(
    this.name,
    this.launchDate, {
    this.landDate,
    this.lastContactDate,
  });
}

/// The manager for Mars Rover requests, providing a framework and caching
/// options to reduce the API key usage.
class MarsRover {
  static const String _cClass = "MarsRover";

  static const String _cEndpoint = "/mars-photos/api/v1/rovers/%s/photos";

  static const String _cParamDate = "date";
  static const String _cParamStartDate = "start_date";
  static const String _cParamEndDate = "end_date";
  static const String _cParamCount = "count";
  static const String _cParamThumbs = "thumbs";

  static final DateTime _minimumApiDate = DateTime(1995, 6, 16);

  static late bool _cacheSupport;
  static late Duration? _defaultCacheExpiration;

  /// Initializes the APOD manager. This is for internal use only. Use the
  /// NASA initialization function.
  static void init(
      {bool cacheSupport = true,
      Duration? defaultCacheExpiration = const Duration(days: 90)}) {
    _cacheSupport = cacheSupport;
    _defaultCacheExpiration = defaultCacheExpiration;

    if (_cacheSupport) {
      // Start the loop timer for the specified duration
      Timer.periodic(const Duration(seconds: 5), (timer) {
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
  static Future<Tuple2<int, ApodItem?>> requestByDate(DateTime date) async {
    Tuple2<int, List<ApodItem>?> results = await requestByRange(date, date);
    ApodItem? item;
    if (results.item2 != null && results.item2!.isNotEmpty) {
      item = results.item2![0];
    }
    return Tuple2(results.item1, item);
  }

  /// Requests the list of APODs for the [year] and [month] provided. The tuple
  /// returned will contain the http response code for understanding failures,
  /// and an APOD item list if the request was successful.
  static Future<Tuple2<int, List<ApodItem>?>> requestByMonth(
      int year, int month) async {
    Log.out("requestByMonth() year: $year, month: $month", name: _cClass);
    // Create the start date
    DateTime startDate = DateTime(year, month, 1);
    if (startDate.isBefore(_minimumApiDate)) {
      startDate = _minimumApiDate;
    }
    // Create the end date
    DateTime endDate = DateTime(year, month, DateTime(year, month + 1, 0).day);
    // If the current date/time is before the endDate, update the endDate.
    DateTime currentDate = DateTime.now();
    if (currentDate.isBefore(endDate)) {
      endDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    }
    return await requestByRange(startDate, endDate);
  }

  /// Requests a random, reasonably sized list of APODs totaling the [count]
  /// provided. The tuple reurned will contain the http response code for
  /// understanding failures, and an APOD item list if the request was
  /// successful. The response for random requests is not cached.
  static Future<Tuple2<int, List<ApodItem>?>> requestByRandom(int count) async {
    Log.out("requestByRandom() Count: $count", name: _cClass);

    // Add the required parameters
    Map<String, String> params = <String, String>{};
    params.putIfAbsent(_cParamCount, () => count.toString());
    params.putIfAbsent(_cParamThumbs, () => true.toString());

    // Perform the request
    http.Response response = await RequestManager.get(_cEndpoint, params);
    List<ApodItem>? items;
    if (response.statusCode == HttpStatus.ok) {
      // Parse the response
      items = <ApodItem>[];
      dynamic jsonBody = json.decode(response.body);
      for (dynamic jsonItem in jsonBody) {
        items.add(ApodItem.fromMap(jsonItem));
      }
    }

    return Tuple2(response.statusCode, items);
  }

  /// Performs a request for APOD items given the provided date range between
  /// and including the [startDate] and [endDate]. The tuple reurned will
  /// contain the http response code for understanding failures, and an APOD
  /// item list if the request was successful.
  static Future<Tuple2<int, List<ApodItem>?>> requestByRange(
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

  /// Retrieves all APOD items that have the provided [category] or
  /// [categoryList] associated with them.
  static Future<List<ApodItem>> getCategory(
      {final String? category, List<String>? categoryList}) async {
    // Create the category list where-clause
    categoryList ??= <String>[];
    if (category != null && !categoryList.contains(category)) {
      categoryList.add(category);
    }
    String whereClause = "";
    for (String category in categoryList) {
      if (whereClause.isNotEmpty) {
        whereClause += " OR ";
      }
      whereClause += "${ApodItemModel.keyLocalCategories} LIKE  '%$category%'";
    }

    // Retrieve the categories from the database
    final List<Map<String, dynamic>> maps =
        await DatabaseManager.getConnection()
            .query(ApodItemModel.tableName, where: whereClause);

    // Populate the APOD items list
    List<ApodItem> items = <ApodItem>[];
    for (Map<String, dynamic> map in maps) {
      items.add(ApodItem.fromMap(map));
    }
    return items;
  }

  /// Updates the cache with the provided [apodItem] or [apodItemList].
  /// Use this function to update the list of categories associated with the
  /// item or items. Set the expiration to null to make the item persistent and
  /// avoid being deleted. Set [useDefaultCacheExpiration] to true if the
  /// default expiration should be set.
  static Future<void> updateItemCache(
      {ApodItem? apodItem,
      List<ApodItem>? apodItemList,
      final bool useDefaultCacheExpiration = false}) async {
    if (!_cacheSupport) {
      Log.out("Caching is not enabled. Enable caching in the init function.",
          name: _cClass);
      return;
    }
    // Create the list of APOD items for insertion
    apodItemList = apodItemList ?? <ApodItem>[];
    if (apodItem != null && !apodItemList.contains(apodItem)) {
      apodItemList.add(apodItem);
    }

    // Insert or update the items in the database
    for (ApodItem item in apodItemList) {
      // Update the cache to the default expiration if provided
      if (useDefaultCacheExpiration && _defaultCacheExpiration != null) {
        item.expiration = DateTime.now().add(_defaultCacheExpiration!);
      }
      // Insert the item into the table.
      await DatabaseManager.getConnection().insert(
        ApodItemModel.tableName,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Delete expired cache if supported so any changes made in the update
    // will reflect in the next query.
    await _deleteExpiredCache();
  }

  /// Determines if the date provided is valid. The API only supports dates
  /// at or after the minimum provided date.
  static bool _isValidDate(DateTime date) {
    DateTime now = Util.getEstDateTime();
    DateTime maximumApiDate = DateTime(now.year, now.month, now.day);
    return (date.isAtSameMomentAs(_minimumApiDate) ||
            date.isAfter(_minimumApiDate)) &&
        (date.isAtSameMomentAs(maximumApiDate) ||
            date.isBefore(maximumApiDate));
  }

  /// Converts a [dateTime] to the expected NASA request format.
  static String _toRequestDateFormat(DateTime dateTime) {
    return "${dateTime.year.toString()}-${dateTime.month.toString()}-${dateTime.day.toString()}";
  }

  /// Utility function used to count the number of days between and including
  /// the [start] and [end] dates.
  static int _daysInRange(DateTime start, DateTime end) {
    start = DateTime(start.year, start.month, start.day);
    end = DateTime(end.year, end.month, end.day);
    return end.difference(start).inHours ~/ 24 + 1;
  }
}
