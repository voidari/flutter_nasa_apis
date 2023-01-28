// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/managers/database_manager.dart';
import 'package:nasa_apis/src/managers/request_manager.dart';

export 'src/apod/apod.dart';
export 'src/apod/apod_item.dart';

export 'src/mars_rovers/cameras.dart';
export 'src/mars_rovers/day_info_item.dart';
export 'src/mars_rovers/manifest.dart';
export 'src/mars_rovers/mars_rover.dart';
export 'src/mars_rovers/photo_item.dart';

/// The interface used to make NASA API calls for all of their open APIs.
/// Initialize the instance of the API with your configuration required and
/// quickly make requests in your app.
class Nasa {
  /// Initialize the library with the [apiKey] provided by api.nasa.gov and
  /// a function [logReceiver] to receive log events to your personal logging
  /// tool. [isTest] should only be used for internal testing.
  static Future<void> init(
      {final String? apiKey,
      final Function(String, String)? logReceiver,
      bool cacheSupport = true,
      bool isTest = false}) async {
    // Add the log receiver if provided
    if (logReceiver != null) {
      Log.setLogFunction(logReceiver);
    }

    /// Initialize the request manager
    RequestManager.init(apiKey);

    // Initialize the database if cache is supported.
    if (cacheSupport) {
      await DatabaseManager.init(isTest: isTest);
    }
  }
}
