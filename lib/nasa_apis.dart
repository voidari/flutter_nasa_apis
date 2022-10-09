// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/managers/apod.dart';
import 'package:nasa_apis/src/managers/database_manager.dart';

export 'src/managers/apod.dart';
export 'src/models/apod_item.dart';

/// The interface used to make NASA API calls for all of their open APIs.
/// Initialize the instance of the API with your configuration required and
/// quickly make requests in your app.
class Nasa {
  /// Initialize the library with the [apiKey] provided by api.nasa.gov and
  /// a function [logReceiver] to receive log events to your personal logging
  /// tool.
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
    // Initialize the database if anything storage related is supported
    if (apodSupport && apodCacheSupport) {
      await DatabaseManager.init(isTest: isTest);
    }
    // Initialize the APOD
    if (apodSupport) {
      NasaApod.init(
          cacheSupport: apodCacheSupport,
          defaultCacheExpiration: apodDefaultCacheExpiration);
    }
  }
}
