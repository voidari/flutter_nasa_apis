// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/models/base_model.dart';

/// The container for APOD data and helper functions for providing the
/// parsed information.
class ApodItemModel implements BaseModel {
  // Map constants
  static const String keyExpiration = "expiration";
  static const String keyLocalCategories = "local_categories";
  static const String keyCopyright = "copyright";
  static const String keyDate = "date";
  static const String keyExplanation = "explanation";
  static const String keyHdUrl = "hdurl";
  static const String keyMediaType = "media_type";
  static const String keyServiceVersion = "service_version";
  static const String keyThumbnailUrl = "thumbnail_url";
  static const String keyTitle = "title";
  static const String keyUrl = "url";

  static const String valueMediaTypeImage = "image";
  static const String valueMediaTypeVideo = "video";

  // Table constants
  static const String tableName = "apod_items";

  /// For internal library use only. Performs a create of the table.
  @override
  String createTable() {
    String command = "CREATE TABLE $tableName(";
    command += "$keyDate INTEGER PRIMARY KEY,";
    command += "$keyExpiration INTEGER,";
    command += "$keyLocalCategories TEXT,";
    command += "$keyCopyright TEXT,";
    command += "$keyExplanation TEXT,";
    command += "$keyHdUrl TEXT,";
    command += "$keyMediaType TEXT,";
    command += "$keyServiceVersion TEXT,";
    command += "$keyThumbnailUrl TEXT,";
    command += "$keyTitle TEXT,";
    command += "$keyUrl TEXT";
    command += ");";
    return command;
  }

  /// For internal library use only. Performs an upgrade of the table.
  @override
  List<String> upgradeTable(int oldVersion, int newVersion) {
    List<String> commands = <String>[];
    return commands;
  }
}
