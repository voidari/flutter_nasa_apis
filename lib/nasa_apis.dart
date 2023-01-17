// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/apod/apod.dart';
import 'package:nasa_apis/src/managers/database_manager.dart';
import 'package:nasa_apis/src/managers/request_manager.dart';
import 'package:timezone/data/latest.dart' as tz;

export 'src/apod/apod.dart';
export 'src/apod/apod_item.dart';

/// The interface used to make NASA API calls for all of their open APIs.
/// Initialize the instance of the API with your configuration required and
/// quickly make requests in your app.
class Nasa {
  /// Initialize the library with the [apiKey] provided by api.nasa.gov and
  /// a function [logReceiver] to receive log events to your personal logging
  /// tool. [isTest] should only be used for internal testing.
  /// Enable APOD support using [apodSupport] and caching for less API usage
  /// using [apodCacheSupport], which is enabled by default. Change the default
  /// caching duration by updating the [apodDefaultCacheExpiration] parameter.
  static Future<void> init(
      {final String? apiKey,
      final Function(String, String)? logReceiver,
      bool apodSupport = false,
      bool apodCacheSupport = true,
      Duration? apodDefaultCacheExpiration = const Duration(days: 90),
      bool isTest = false}) async {
    // Add the log receiver if provided
    if (logReceiver != null) {
      Log.setLogFunction(logReceiver);
    }

    /// Initialize the request manager
    RequestManager.init(apiKey);

    // Initialize the database if anything storage related is supported
    if (apodSupport && apodCacheSupport) {
      await DatabaseManager.init(isTest: isTest);
    }
    // Initialize the APOD
    if (apodSupport) {
      tz.initializeTimeZones();
      NasaApod.init(
          cacheSupport: apodCacheSupport,
          defaultCacheExpiration: apodDefaultCacheExpiration);
    }
  }
}
