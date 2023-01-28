// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/models/base_model.dart';

/// The SQL model for the MarsRoverManifest, used to create and edit the
/// database and provide non-public constants.
class MarsRoverManifestModel implements BaseModel {
  // Map constants
  static const String keyName = "name";
  static const String keyLandingDate = "landing_date";
  static const String keyLaunchDate = "launch_date";
  static const String keyStatus = "status";
  static const String keyMaxSol = "max_sol";
  static const String keyMaxDate = "max_date";
  static const String keyTotalPhotos = "total_photos";

  // Table constants
  static const String tableName = "mars_rover_manifests";

  /// Performs a create of the table. Once published, this should never
  /// be changed.
  @override
  String createTable() {
    String command = "CREATE TABLE $tableName(";
    command += "$keyName TEXT PRIMARY KEY,";
    command += "$keyLandingDate INTEGER,";
    command += "$keyLaunchDate INTEGER,";
    command += "$keyStatus TEXT,";
    command += "$keyMaxSol INTEGER,";
    command += "$keyMaxDate INTEGER,";
    command += "$keyTotalPhotos INTEGER";
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
