// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:developer';

/// Internal class used to handle all logging. Provides a means to retrieve
/// the logging information.
class Log {
  /// The external log capture function.
  static Function(String message, String name) _logFunc = _internalOut;

  /// Sets the external log capture function [logFunc].
  static void setLogFunction(Function(String message, String name) logFunc) {
    _logFunc = logFunc;
  }

  /// Handles the logging of the provided message and parameters.
  static void out(final String message, {String? name}) {
    _logFunc(message, name ?? '');
  }

  /// The internal logger, which is the default log function.
  static void _internalOut(final String message, String name) {
    log(message, name: name);
  }
}
