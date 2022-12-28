// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/models/base_model.dart';

/// The SQL model for the ApodItem, used to create and edit the database
/// and provide non-public constants.
class NeoWsAsteroidItemModel implements BaseModel {
  // Map constants
  static const String keyExpiration = "expiration";

  // Table constants
  static const String tableName = "neows_asteroid_items";

  /// Performs a create of the table. Once published, this should never
  /// be changed.
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

  /// Performs an upgrade of the table from [oldVersion] to [newVersion].
  @override
  List<String> upgradeTable(int oldVersion, int newVersion) {
    List<String> commands = <String>[];
    return commands;
  }
}
