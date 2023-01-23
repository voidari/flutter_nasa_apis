// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/mars_rovers/manifest.dart';
import 'package:nasa_apis/src/mars_rovers/manifest_model.dart';
import 'package:nasa_apis/src/mars_rovers/photo_item_model.dart';
import 'package:nasa_apis/src/models/base_model.dart';

/// The SQL model for the MarsRoverDayInfoItem, used to create and edit the
/// database and provide non-public constants.
class MarsRoverDayInfoItemModel implements BaseModel {
  // Map constants
  static const String keyRover = "rover";
  static const String keySol = "sol";
  static const String keyTotalPhotos = "total_photos";
  static const String keyCameras = "cameras";

  // Table constants
  static const String tableName = "mars_rover_day_info_items";

  /// Performs a create of the table. Once published, this should never
  /// be changed.
  @override
  String createTable() {
    String command = "CREATE TABLE $tableName(";
    command += "$keyRover TEXT PRIMARY KEY,";
    command += "$keySol INTEGER,";
    command += "$keyTotalPhotos INTEGER,";
    command += "$keyCameras TEXT,";
    command +=
        " FOREIGN KEY ($keyRover) references ${MarsRoverPhotoItemModel.tableName}(${MarsRoverManifestModel.keyName}) ON DELETE CASCADE";
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
