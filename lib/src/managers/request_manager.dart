// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nasa_apis/src/log.dart';

/// The manager for handling all requests and tracking the usage of the demo
/// key/API key combination.
class RequestManager {
  static const String _cClass = "RequestManager";
  static const String _cScheme = "https";
  static const String _cHostname = "api.nasa.gov";
  static const String _cParamApiKey = "api_key";
  static const String _cApiDemoKey = "DEMO_KEY";

  static const String _cResponseHeaderLimitRemaining = "x-ratelimit-remaining";

  static String? _apiKey;
  static bool _apiDemoKeyValid = true;

  /// Performs a GET request with the provided parameters
  static Future<http.Response> get(
      String endpoint, Map<String, String> params) async {
    http.Response response = http.Response("", HttpStatus.badRequest);
    bool isUseDevKey = false;

    // Check if the demo key has been used up
    if (_apiDemoKeyValid) {
      // Try using the demo key to avoid using the dev key
      params.putIfAbsent(_cParamApiKey, () => _cApiDemoKey);

      Uri uri = Uri(
          scheme: _cScheme,
          host: _cHostname,
          path: endpoint,
          queryParameters: params);

      try {
        response = await http.get(uri);

        // Check the response headers for the limit remaining
        bool isValid = false;
        if (response.headers.containsKey(_cResponseHeaderLimitRemaining)) {
          int remaining = int.parse(
              response.headers[_cResponseHeaderLimitRemaining] ?? "0");
          Log.out("get() Remaining demo requests: $remaining", name: _cClass);
          isValid = 0 < remaining;
        }

        // If the demo key is no longer valid, set it as such
        _apiDemoKeyValid = isValid;
      } on TimeoutException catch (_) {
        Log.out("get() A timeout occurred during request.", name: _cClass);
      } on SocketException catch (error) {
        Log.out("get() A socket exception ocurred. $error", name: _cClass);
      }

      // If the response code is an error caused by a rate limit, we will
      // retry the request with the development key, which is a lot more
      // likely to be successful.
      if (response.statusCode == HttpStatus.tooManyRequests) {
        _apiDemoKeyValid = false;
        isUseDevKey = true;
        Log.out("get() The demo key has been maxed out.", name: _cClass);
      }
    } else {
      isUseDevKey = true;
    }

    // If the flag to use the development key is setup, build the request
    // with the development key and make the request.
    if (isUseDevKey && _apiKey != null) {
      Log.out("get() Queue the request with the developer key");
      params[_cParamApiKey] = _apiKey!;

      // Build the URI and send the request
      Uri uri = Uri(
          scheme: _cScheme,
          host: _cHostname,
          path: endpoint,
          queryParameters: params);

      try {
        response = await http.get(uri);
      } on TimeoutException catch (_) {
        Log.out("get() A timeout occurred during request.", name: _cClass);
      } on SocketException catch (error) {
        Log.out("get() A socket exception ocurred. $error", name: _cClass);
      }

      if (response.statusCode == HttpStatus.tooManyRequests) {
        Log.out("get() The NASA development key has been maxed out.",
            name: _cClass);
      }
    }

    return Future<http.Response>.value(response);
  }
}
