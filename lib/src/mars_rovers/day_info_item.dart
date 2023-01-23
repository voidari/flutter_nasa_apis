// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nasa_apis/src/mars_rovers/cameras.dart';
import 'package:nasa_apis/src/mars_rovers/day_info_item_model.dart';

/// The container for Day Info data and helper functions for providing the
/// parsed information.
class MarsRoverDayInfoItem {
  /// Martian sol of the Rover's mission.
  final int sol;

  /// The number of photos taken by that rover on that sol.
  final int totalPhotos;

  /// Cameras for which there are photos by that Rover on that sol.
  final List<MarsRoverCameras> cameras;

  /// The constructor of the Day Info item.
  MarsRoverDayInfoItem(
    this.sol,
    this.totalPhotos,
    this.cameras,
  );

  /// Creates an item from the provided [map] object.
  static MarsRoverDayInfoItem fromMap(Map<String, dynamic> map) {
    final int sol = map[MarsRoverDayInfoItemModel.keySol];
    final int totalPhotos = map[MarsRoverDayInfoItemModel.keyTotalPhotos];
    final List<MarsRoverCameras> cameras = [];
    for (String cameraStr in map[MarsRoverDayInfoItemModel.keyCameras]) {
      if (MarsRoverCamerasUtil.fromStringKey(cameraStr) !=
          MarsRoverCameras.unknown) {
        cameras.add(MarsRoverCamerasUtil.fromStringKey(cameraStr));
      }
    }
    return MarsRoverDayInfoItem(sol, totalPhotos, cameras);
  }

  /// Creates a map given the current item data.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map[MarsRoverDayInfoItemModel.keySol] = sol;
    map[MarsRoverDayInfoItemModel.keyTotalPhotos] = totalPhotos;
    List<String> camerasList = [];
    for (MarsRoverCameras camera in cameras) {
      camerasList.add(MarsRoverCamerasUtil.toStringKey(camera));
    }
    map[MarsRoverDayInfoItemModel.keyCameras] = camerasList;
    return map;
  }

  /// Provides an override for a detailed MarsRoverDayInfoItem string.
  @override
  String toString() {
    return "MarsRoverDayInfoItem("
        "${MarsRoverDayInfoItemModel.keySol}: ${sol.toString()}, "
        "${MarsRoverDayInfoItemModel.keyTotalPhotos}: ${totalPhotos.toString()}, "
        "${MarsRoverDayInfoItemModel.keyCameras}: [${cameras.join(',')}]"
        ")";
  }

  /// Comparison operator for the item. Used to perform a deep comparison.
  @override
  bool operator ==(Object other) {
    if (other is! MarsRoverDayInfoItem) {
      return false;
    }
    MarsRoverDayInfoItem otherItem = other;
    return sol == otherItem.sol &&
        totalPhotos == otherItem.totalPhotos &&
        listEquals(cameras, otherItem.cameras);
  }

  /// The hash code override.
  @override
  int get hashCode => jsonEncode(toMap()).hashCode;
}
