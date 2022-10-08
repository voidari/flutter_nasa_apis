// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/managers/request_manager.dart';
import 'package:nasa_apis/src/models/apod_item.dart';
import 'package:tuple/tuple.dart';

/// The manager for APOD requests, providing a framework and caching options
/// to reduce the API key usage.
class NasaApod {
  static const String _cClass = "NasaApod";

  static const String _cEndpoint = "/planetary/apod";

  static const String _cParamDate = "date";
  static const String _cParamStartDate = "start_date";
  static const String _cParamEndDate = "end_date";
  static const String _cParamCount = "count";
  static const String _cParamThumbs = "thumbs";

  static final DateTime _minimumApiDate = DateTime.utc(1995, 6, 16);

  /// Retrieves the minimum date allowed for query. This is the first date
  /// an APOD was released.
  static DateTime getMinimumDate() {
    return _minimumApiDate;
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
    DateTime startDate = DateTime.utc(year, month, 1);
    if (startDate.isBefore(_minimumApiDate)) {
      startDate = _minimumApiDate;
    }
    // Create the end date
    DateTime endDate =
        DateTime.utc(year, month, DateTime(year, month + 1, 0).day);
    // If the current date/time is before the endDate, update the endDate.
    DateTime currentDate = DateTime.now();
    if (currentDate.isBefore(endDate)) {
      endDate =
          DateTime.utc(currentDate.year, currentDate.month, currentDate.day);
    }
    return await requestByRange(startDate, endDate);
  }

  /// Requests a random, reasonably sized list of APODs totaling the [count]
  /// provided. The tuple reurned will contain the http response code for
  /// understanding failures, and an APOD item list if the request was
  /// successful.
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
    Log.out("requestByRange() startDate: $startDate, endDate: $endDate",
        name: _cClass);
    // Validate the requested dates
    if (!_isValidDate(startDate) ||
        !_isValidDate(endDate) ||
        endDate.isBefore(startDate)) {
      Log.out("requestByRange() Start date or end date is invalid",
          name: _cClass);
      return const Tuple2(600, null);
    }

    // Create the parameters for the requst
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
    }

    return Tuple2(response.statusCode, items);
  }

  /// Determines if the date provided is valid. The API only supports dates
  /// at or after the minimum provided date.
  static bool _isValidDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime maximumApiDate = DateTime(now.year, now.month, now.day);
    return (date.isAtSameMomentAs(_minimumApiDate) ||
            date.isAfter(_minimumApiDate)) &&
        (date.isAtSameMomentAs(maximumApiDate) ||
            date.isBefore(maximumApiDate));
  }

  /// Converts a DateTime to the expected NASA request format.
  static String _toRequestDateFormat(DateTime dateTime) {
    return "${dateTime.year.toString()}-${dateTime.month.toString()}-${dateTime.day.toString()}";
  }
}
