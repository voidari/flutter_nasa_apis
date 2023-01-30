// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:convert';

import 'package:nasa_apis/src/mars_rovers/cameras.dart';
import 'package:nasa_apis/src/mars_rovers/photo_item_model.dart';

/// The container for photo item data and helper functions for providing the
/// parsed information.
class MarsRoverPhotoItem {
  /// The ID of the photo
  final int id;

  /// The lowercase name ID of the rover.
  final String rover;

  /// Martian sol when the photo was taken.
  final int sol;

  /// The earth date when the photo was taken.
  final DateTime earthDate;

  /// The camera that took the photo.
  final MarsRoverCameras camera;

  /// The URL of the photo source.
  final String imageSource;

  /// The expiration time of the cache. Set to null to keep the cache persistent
  /// and avoid deletion. Set to the current time or less to force deletion. The
  /// expiration date should be a future date and time.
  DateTime? expiration;

  /// The constructor of the photo item.
  MarsRoverPhotoItem(
    this.id,
    this.rover,
    this.sol,
    this.earthDate,
    this.camera,
    this.imageSource, {
    this.expiration,
  });

  /// Creates an item from the provided [map] object.
  static MarsRoverPhotoItem fromMap(Map<String, dynamic> map) {
    final int id = map[MarsRoverPhotoItemModel.keyId];
    final String rover = map[MarsRoverPhotoItemModel.keyRover];
    final int sol = map[MarsRoverPhotoItemModel.keySol];
    final DateTime earthDate = DateTime.fromMillisecondsSinceEpoch(
        map[MarsRoverPhotoItemModel.keyEarthDate]);
    MarsRoverCameras camera = MarsRoverCamerasUtil.fromStringKey(
        map[MarsRoverPhotoItemModel.keyCamera]);
    final String imageSource = map[MarsRoverPhotoItemModel.keyImageSource];
    DateTime? expiration =
        map.containsKey(MarsRoverPhotoItemModel.keyExpiration)
            ? DateTime.fromMillisecondsSinceEpoch(
                map[MarsRoverPhotoItemModel.keyExpiration])
            : null;
    return MarsRoverPhotoItem(id, rover, sol, earthDate, camera, imageSource,
        expiration: expiration);
  }

  /// Creates an item from the provided [map] object.
  static MarsRoverPhotoItem fromUrlMap(Map<String, dynamic> map) {
    final int id = map[MarsRoverPhotoItemModel.keyId];
    final int sol = map[MarsRoverPhotoItemModel.keySol];
    final String cameraName = map["camera"]["name"].toUpperCase();
    MarsRoverCameras camera = MarsRoverCamerasUtil.fromStringKey(cameraName);
    final String imageSource = map[MarsRoverPhotoItemModel.keyImageSource];
    final DateTime earthDate =
        DateTime.parse(map[MarsRoverPhotoItemModel.keyEarthDate]);
    final String rover = map["rover"]["name"];
    return MarsRoverPhotoItem(
      id,
      rover,
      sol,
      earthDate,
      camera,
      imageSource,
    );
  }

  /// Creates a map given the current item data.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map[MarsRoverPhotoItemModel.keyId] = id;
    map[MarsRoverPhotoItemModel.keyRover] = rover;
    map[MarsRoverPhotoItemModel.keySol] = sol;
    map[MarsRoverPhotoItemModel.keyEarthDate] =
        earthDate.millisecondsSinceEpoch;
    map[MarsRoverPhotoItemModel.keyCamera] =
        MarsRoverCamerasUtil.toStringKey(camera);
    map[MarsRoverPhotoItemModel.keyImageSource] = imageSource;
    map[MarsRoverPhotoItemModel.keyExpiration] =
        expiration != null ? expiration?.millisecondsSinceEpoch : 0;
    return map;
  }

  /// Provides an override for a detailed MarsRoverPhotoItem string.
  @override
  String toString() {
    return "MarsRoverDayInfoItem("
        "${MarsRoverPhotoItemModel.keyId}: ${id.toString()}, "
        "${MarsRoverPhotoItemModel.keyRover}: $rover, "
        "${MarsRoverPhotoItemModel.keySol}: ${sol.toString()}, "
        "${MarsRoverPhotoItemModel.keyEarthDate}: ${earthDate.toUtc()}, "
        "${MarsRoverPhotoItemModel.keyCamera}: ${camera.name}, "
        "${MarsRoverPhotoItemModel.keyImageSource}: $imageSource, "
        ")";
  }

  /// Comparison operator for the item. Used to perform a deep comparison.
  @override
  bool operator ==(Object other) {
    if (other is! MarsRoverPhotoItem) {
      return false;
    }
    MarsRoverPhotoItem otherItem = other;
    return id == otherItem.id &&
        rover == otherItem.rover &&
        sol == otherItem.sol &&
        earthDate == otherItem.earthDate &&
        camera == otherItem.camera &&
        imageSource == otherItem.imageSource;
  }

  /// The hash code override.
  @override
  int get hashCode => jsonEncode(toMap()).hashCode;
}
