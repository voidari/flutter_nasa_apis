// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/models/base_model.dart';

/// The SQL model for the TleItem, used to create and edit the database
/// and provide non-public constants.
class TleItemModel implements BaseModel {
  // Map constants
  static const String keyId = "@id";
  static const String keyType = "@type";
  static const String keySatelliteId = "satelliteId";
  static const String keyName = "name";
  static const String keyDate = "date";
  static const String keyLine1 = "line1";
  static const String keyLine2 = "line2";
  static const String keyExpiration = "expiration";

  // Table constants
  static const String tableName = "tle_items";

  /// Performs a create of the table. Once published, this should never
  /// be changed.
  @override
  String createTable() {
    String command = "CREATE TABLE $tableName(";
    command += "$keyId TEXT PRIMARY KEY,";
    command += "$keyExpiration INTEGER,";
    command += "$keyType TEXT,";
    command += "$keySatelliteId INTEGER,";
    command += "$keyName TEXT,";
    command += "$keyDate TEXT,";
    command += "$keyLine1 TEXT,";
    command += "$keyLine2 TEXT,";
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
