// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/models/base_model.dart';

/// The SQL model for the ApodItem, used to create and edit the database
/// and provide non-public constants.
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

  /// Performs a create of the table. Once published, this should never
  /// be changed.
  @override
  String createTable() {
    String command = "CREATE TABLE IF NOT EXISTS $tableName(";
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

  /// Performs an upgrade of the table from [oldVersion] to [newVersion].
  @override
  List<String> upgradeTable(int oldVersion, int newVersion) {
    List<String> commands = <String>[];
    return commands;
  }
}
