// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/models/base_model.dart';

/// The SQL model for the MarsRoverPhotoItem, used to create and edit the
/// database and provide non-public constants.
class MarsRoverPhotoItemModel implements BaseModel {
  // Map constants
  static const String keyId = "id";
  static const String keyRover = "rover";
  static const String keySol = "sol";
  static const String keyEarthDate = "earth_date";
  static const String keyCamera = "camera";
  static const String keyImageSource = "img_src";
  static const String keyExpiration = "expiration";

  // Table constants
  static const String tableName = "mars_rover_photo_items";

  /// Performs a create of the table. Once published, this should never
  /// be changed.
  @override
  String createTable() {
    String command = "CREATE TABLE $tableName(";
    command += "$keyId TEXT PRIMARY KEY,";
    command += "$keyRover TEXT,";
    command += "$keySol INTEGER,";
    command += "$keyEarthDate INT,";
    command += "$keyCamera TEXT,";
    command += "$keyImageSource TEXT,";
    command += "$keyExpiration INTEGER";
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
