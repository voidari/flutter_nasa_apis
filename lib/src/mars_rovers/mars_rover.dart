// Copyright (C) 2023 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nasa_apis/src/log.dart';
import 'package:nasa_apis/src/managers/database_manager.dart';
import 'package:nasa_apis/src/managers/request_manager.dart';
import 'package:nasa_apis/src/mars_rovers/cameras.dart';
import 'package:nasa_apis/src/mars_rovers/day_info_item.dart';
import 'package:nasa_apis/src/mars_rovers/day_info_item_model.dart';
import 'package:nasa_apis/src/mars_rovers/manifest.dart';
import 'package:nasa_apis/src/mars_rovers/manifest_model.dart';
import 'package:nasa_apis/src/mars_rovers/photo_item.dart';
import 'package:nasa_apis/src/mars_rovers/photo_item_model.dart';
import 'package:nasa_apis/src/util.dart';
import 'package:persist_notifier/persist_notifier.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

/// The manager for Mars Rover requests, providing a framework and caching
/// options to reduce the API key usage.
class NasaMarsRover {
  static const String _cManifestEndpoint = "/mars-photos/api/v1/manifests/%s";
  static const String _cPhotoEndpoint = "/mars-photos/api/v1/rovers/%s/photos";

  static const String roverSpirit = "Spirit";
  static const String roverOpportunity = "Opportunity";
  static const String roverCuriosity = "Curiosity";
  static const String roverPerseverance = "Perseverance";

  static const String _cParamSol = "sol";
  static const String _cParamEarthDate = "earth_date";
  static const String _cParamCamera = "camera";
  static const String _cParamPage = "page";

  static const String _cKeyPhotos = "photos";

  static late bool _cacheSupport;
  static late Duration? _cacheExpiration;

  static late PersistNotifier _lastManifestSync;

  /// Initializes the Mars Rover manager.
  static Future<void> init({
    bool cacheSupport = true,
    Duration? cacheExpiration = const Duration(days: 7),
  }) async {
    _cacheSupport = cacheSupport;
    _cacheExpiration = cacheExpiration;
    _lastManifestSync = await PersistNotifier.create(
        "com.voidari.nasa_mars_rover.lastManifestSync", 0);

    if (_cacheSupport) {
      _syncManifests();
      // Start the loop timer for the specified duration
      Timer.periodic(const Duration(minutes: 1), (timer) {
        _syncManifests();
        _deleteExpiredCache();
      });
    }
  }

  /// Syncs the latest manifests given the valid list and the existing
  /// manifests in the table.
  static Future<void> _syncManifests() async {
    // Check if we're ready to sync
    DateTime lastSync =
        DateTime.fromMillisecondsSinceEpoch(_lastManifestSync.value);
    if (!_cacheSupport || DateTime.now().difference(lastSync).inHours < 4) {
      return;
    }
    Set<String> rovers = {};
    // Query the database for all manifest rover names.
    List<Map<String, dynamic>> result = await DatabaseManager.getConnection()
        .query(MarsRoverManifestModel.tableName,
            columns: <String>[MarsRoverManifestModel.keyName]);
    for (Map<String, dynamic> map in result) {
      rovers.add(map[MarsRoverManifestModel.keyName]);
    }
    // Add the known rovers to the set
    rovers.add(roverSpirit);
    rovers.add(roverOpportunity);
    rovers.add(roverCuriosity);
    rovers.add(roverPerseverance);
    // Loop through the rovers and sync each manifest
    for (String rover in rovers) {
      requestManifest(rover, includePhotoManifest: false);
    }
    await _lastManifestSync.set(DateTime.now().millisecondsSinceEpoch);
  }

  /// The update loop that checks for expired rows. Removes expired entries.
  static Future<void> _deleteExpiredCache() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    await DatabaseManager.getConnection()
        .delete(MarsRoverPhotoItemModel.tableName,
            where: "${MarsRoverPhotoItemModel.keyExpiration} < $now AND "
                "${MarsRoverPhotoItemModel.keyExpiration} > 0");
  }

  /// Requests the manifest for the provided [rover]. The tuple returned will
  /// contain a http response code for understanding failures, and a
  /// MarsRoverManifest item if the request was successful.
  static Future<Tuple2<int, MarsRoverManifest?>> requestManifest(
      final String rover,
      {bool includePhotoManifest = true}) async {
    // Check the database for existing manifest data if a sync is not required
    DateTime lastSync =
        DateTime.fromMillisecondsSinceEpoch(_lastManifestSync.value);
    if (_cacheSupport && DateTime.now().difference(lastSync).inHours < 4) {
      List<Map<String, dynamic>> map = await DatabaseManager.getConnection()
          .query(MarsRoverManifestModel.tableName,
              where: "${MarsRoverManifestModel.keyName} == '$rover'");
      if (map.isNotEmpty) {
        MarsRoverManifest manifest = MarsRoverManifest.fromMap(map[0]);
        if (includePhotoManifest) {
          List<MarsRoverDayInfoItem> dayInfoItems = <MarsRoverDayInfoItem>[];
          map = await DatabaseManager.getConnection().query(
              MarsRoverDayInfoItemModel.tableName,
              where: "${MarsRoverDayInfoItemModel.keyRover} = '$rover'");
          for (Map<String, dynamic> mapIter in map) {
            dayInfoItems.add(MarsRoverDayInfoItem.fromUrlMap(mapIter, rover));
          }
          manifest.dayInfoItems = dayInfoItems;
        }
        Log.out("requestManifest() A cache hit was found for $rover.");
        return Tuple2(HttpStatus.ok, manifest);
      }
    }
    // The manifest does not exist in the database. Request the manifest from
    // the NASA servers.
    http.Response response =
        await RequestManager.get(_cManifestEndpoint.replaceFirst("%s", rover));
    if (response.statusCode != HttpStatus.ok) {
      return Tuple2(response.statusCode, null);
    }
    MarsRoverManifest manifest =
        MarsRoverManifest.fromUrlMap(json.decode(response.body));
    // Add to cache
    if (_cacheSupport) {
      // Write the manifest to the database
      await DatabaseManager.getConnection().insert(
        MarsRoverManifestModel.tableName,
        manifest.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (manifest.dayInfoItems != null) {
        for (MarsRoverDayInfoItem marsRoverDayInfoItem
            in manifest.dayInfoItems!) {
          await DatabaseManager.getConnection().insert(
            MarsRoverDayInfoItemModel.tableName,
            marsRoverDayInfoItem.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
    // Remove photos if requested
    if (!includePhotoManifest) {
      manifest.dayInfoItems = null;
    }
    // Return the manifest
    return Tuple2(HttpStatus.ok, manifest);
  }

  /// Searches the manifest for all day infos matching a specific date.
  static Future<Tuple2<int, List<MarsRoverDayInfoItem>?>> getManifestDayInfo(
      DateTime date) async {
    List<MarsRoverDayInfoItem> items = [];
    if (_cacheSupport) {
      // Setup the where clause
      String whereClause =
          "${MarsRoverDayInfoItemModel.keyEarthDate} = ${date.millisecondsSinceEpoch}";
      // Query the database
      List<Map<String, dynamic>> result = await DatabaseManager.getConnection()
          .query(MarsRoverDayInfoItemModel.tableName, where: whereClause);
      for (Map<String, dynamic> map in result) {
        items.add(MarsRoverDayInfoItem.fromMap(map));
      }
      return Tuple2(HttpStatus.ok, items);
    }

    // TODO: Handle non-cache support
    return const Tuple2(600, null);
  }

  /// Creates the where clause for rovers in the day info.
  static String? _createDayInfoRoversWhereClause(List<String>? rovers) {
    String? whereClause;
    if (rovers != null && rovers.isNotEmpty) {
      whereClause = "${MarsRoverDayInfoItemModel.keyRover} IN (";
      for (String rover in rovers) {
        whereClause = "$whereClause '$rover', ";
      }
      whereClause = whereClause!.substring(0, whereClause.length - 2);
      whereClause = "$whereClause)";
    }
    return whereClause;
  }

  /// Creates the where clause for cameras in the day info.
  static String? _createDayInfoCamerasWhereClause(
      List<MarsRoverCameras>? cameras) {
    String? whereClause;
    if (cameras != null && cameras.isNotEmpty) {
      whereClause = "";
      for (MarsRoverCameras camera in cameras) {
        String cameraStr = MarsRoverCamerasUtil.toStringKey(camera);
        whereClause =
            "$whereClause ${MarsRoverDayInfoItemModel.keyCameras} LIKE '%$cameraStr%' OR ";
      }
      whereClause = whereClause!.substring(0, whereClause.length - 4);
    }
    return whereClause;
  }

  /// The minimum and maximum photo range of the provided [rovers] and
  /// [cameras], or all rovers if left null.
  /// NOTICE: This is only implemented for cached manifests.
  static Future<Tuple2<int, Tuple2<DateTime, DateTime>?>> getValidPhotoRange(
      {List<String>? rovers, List<MarsRoverCameras>? cameras}) async {
    // If cache is supported, attempt to pull the values from cache.
    if (_cacheSupport) {
      String? whereClause = "";
      // Add the where clause for the rovers
      String? roversClause = _createDayInfoRoversWhereClause(rovers);
      if (roversClause != null) {
        whereClause = "$whereClause $roversClause";
      }
      // Add the where caluse for the cameras
      String? camerasClause = _createDayInfoCamerasWhereClause(cameras);
      if (camerasClause != null) {
        whereClause =
            "$whereClause ${whereClause.isNotEmpty ? " AND " : ""} ($camerasClause)";
      }
      // Remove the where clause if it hasn't been added
      whereClause = whereClause.isNotEmpty ? whereClause : null;
      // Perform the requests
      DateTime? minDate;
      List<Map<String, dynamic>> result = await DatabaseManager.getConnection()
          .query(MarsRoverDayInfoItemModel.tableName,
              columns: [
                "MIN(${MarsRoverDayInfoItemModel.keyEarthDate}) as ${MarsRoverDayInfoItemModel.keyEarthDate}"
              ],
              where: whereClause);
      if (result.isNotEmpty &&
          result[0][MarsRoverDayInfoItemModel.keyEarthDate] is int) {
        minDate = DateTime.fromMillisecondsSinceEpoch(
            result[0][MarsRoverDayInfoItemModel.keyEarthDate]);
      }
      DateTime? maxDate;
      result = await DatabaseManager.getConnection()
          .query(MarsRoverDayInfoItemModel.tableName,
              columns: [
                "MAX(${MarsRoverDayInfoItemModel.keyEarthDate}) as ${MarsRoverDayInfoItemModel.keyEarthDate}"
              ],
              where: whereClause);
      if (result.isNotEmpty &&
          result[0][MarsRoverDayInfoItemModel.keyEarthDate] is int) {
        maxDate = DateTime.fromMillisecondsSinceEpoch(
            result[0][MarsRoverDayInfoItemModel.keyEarthDate]);
      }
      // If both dates are valid, then return it
      if (minDate != null && maxDate != null) {
        return Tuple2(HttpStatus.ok, Tuple2(minDate, maxDate));
      }
    }

    // TODO: Implement for non-cache support
    return const Tuple2(600, null);
  }

  /// Gets the previous day where photos exist from the [date] provided,
  /// filtered for the provided [rovers] and [cameras].
  /// NOTICE: Currently only implemented with cached manifests.
  static Future<Tuple2<int, DateTime?>> getPreviousDayWithPhotos(DateTime date,
      {List<String>? rovers, List<MarsRoverCameras>? cameras}) async {
    return _getNextOrPreviousDayWithPhotos(date, false,
        rovers: rovers, cameras: cameras);
  }

  /// Gets the next day where photos exist from the [date] provided,
  /// filtered for the provided [rovers] and [cameras].
  /// NOTICE: Currently only implemented with cached manifests.
  static Future<Tuple2<int, DateTime?>> getNextDayWithPhotos(DateTime date,
      {List<String>? rovers, List<MarsRoverCameras>? cameras}) async {
    return _getNextOrPreviousDayWithPhotos(date, true,
        rovers: rovers, cameras: cameras);
  }

  /// Gets the previous or next day where photos exist from the [date] provided,
  /// filtered for the provided [rovers] and [cameras].
  /// NOTICE: Currently only implemented with cached manifests.
  static Future<Tuple2<int, DateTime?>> _getNextOrPreviousDayWithPhotos(
      DateTime date, bool isNext,
      {List<String>? rovers, List<MarsRoverCameras>? cameras}) async {
    if (_cacheSupport) {
      String whereClause =
          "${MarsRoverDayInfoItemModel.keyEarthDate} ${isNext ? ">" : "<"} ${date.millisecondsSinceEpoch}";
      // Add the where clause for the rovers
      String? roversClause = _createDayInfoRoversWhereClause(rovers);
      if (roversClause != null) {
        whereClause = "$whereClause AND $roversClause";
      }
      // Add the where caluse for the cameras
      String? camerasClause = _createDayInfoCamerasWhereClause(cameras);
      if (camerasClause != null) {
        whereClause =
            "$whereClause ${whereClause.isNotEmpty ? " AND " : ""} ($camerasClause)";
      }

      // Start the query
      List<Map<String, dynamic>> result = await DatabaseManager.getConnection()
          .query(MarsRoverDayInfoItemModel.tableName,
              columns: [
                "${isNext ? "MIN" : "MAX"}(${MarsRoverDayInfoItemModel.keyEarthDate}) as ${MarsRoverDayInfoItemModel.keyEarthDate}"
              ],
              where: whereClause);
      if (result.isNotEmpty &&
          result[0][MarsRoverDayInfoItemModel.keyEarthDate] is int) {
        return Tuple2(
            HttpStatus.ok,
            DateTime.fromMillisecondsSinceEpoch(
                result[0][MarsRoverDayInfoItemModel.keyEarthDate]));
      }
    }
    // TODO: Implement for non-cache support
    return const Tuple2(600, null);
  }

  /// Requests the photos for the provided [rover] on the selected [martianSol].
  /// The optional [cameras] and [page] can be provided. The tuple returned will
  /// contain a http response code for understanding failures, and a
  /// list of MarsRoverPhotoItem items if the request was successful.
  static Future<Tuple2<int, List<MarsRoverPhotoItem>?>> requestByMartianSol(
      final String rover, final int martianSol,
      {List<MarsRoverCameras>? cameras, int? page}) async {
    return _requestPhotos(<String>[rover],
        martianSol: martianSol, cameras: cameras, page: page);
  }

  /// Requests the photos for the provided [rovers] on the selected [earthDate].
  /// The optional [cameras] and [page] can be provided. The tuple returned will
  /// contain a http response code for understanding failures, and a
  /// list of MarsRoverPhotoItem items if the request was successful.
  static Future<Tuple2<int, List<MarsRoverPhotoItem>?>> requestByEarthDate(
      final List<String> rovers, DateTime earthDate,
      {List<MarsRoverCameras>? cameras, int? page}) async {
    return _requestPhotos(rovers,
        earthDate: earthDate, cameras: cameras, page: page);
  }

  static Future<bool> _isPhotosDateCacheValid(
      List<String> rovers, DateTime earthDate) async {
    // Query the items for the date
    Tuple2<int, List<MarsRoverDayInfoItem>?> dayInfoList =
        await getManifestDayInfo(earthDate);
    if (dayInfoList.item2 == null) {
      return false;
    }

    // Query the items in the photos table into a count
    Map<String, int> cachedRoverCount = <String, int>{};
    const String countKey = "count";
    List<
        Map<String,
            dynamic>> photoItemList = await DatabaseManager.getConnection().query(
        MarsRoverPhotoItemModel.tableName,
        columns: [
          MarsRoverPhotoItemModel.keyRover,
          "COUNT(${MarsRoverPhotoItemModel.keyRover}) as $countKey"
        ],
        where:
            "${MarsRoverPhotoItemModel.keyEarthDate} = ${earthDate.millisecondsSinceEpoch}",
        groupBy: MarsRoverPhotoItemModel.keyRover);
    for (Map<String, dynamic> photoItemMap in photoItemList) {
      if (photoItemMap[MarsRoverPhotoItemModel.keyRover] != null) {
        cachedRoverCount[photoItemMap[MarsRoverPhotoItemModel.keyRover]] =
            photoItemMap[countKey];
      } else {
        cachedRoverCount[photoItemMap[MarsRoverPhotoItemModel.keyRover]] = 0;
      }
    }

    // Iterate over the day info items and compare them to the count
    for (MarsRoverDayInfoItem dayInfoItem in dayInfoList.item2!) {
      if (!cachedRoverCount.containsKey(dayInfoItem.rover) ||
          cachedRoverCount[dayInfoItem.rover] != dayInfoItem.totalPhotos) {
        await _requestPhotos([dayInfoItem.rover],
            earthDate: earthDate, skipCacheCheck: true);
      }
    }
    return true;
  }

  // TODO: Implement function
  static Future<bool> _isPhotosSolCacheValid(
      String rover, int martianSol) async {
    return false;
  }

  /// Requests the photos for the provided [rovers] on the selected [earthDate].
  /// The optional [cameras] and [page] can be provided. The tuple returned will
  /// contain a http response code for understanding failures, and a
  /// MarsRoverManifest item if the request was successful.
  static Future<Tuple2<int, List<MarsRoverPhotoItem>?>> _requestPhotos(
      final List<String> rovers,
      {DateTime? earthDate,
      int? martianSol,
      List<MarsRoverCameras>? cameras,
      int? page,
      bool skipCacheCheck = false}) async {
    // Validate parameters
    if (rovers.isEmpty || (earthDate == null && martianSol == null)) {
      return const Tuple2(600, null);
    }
    // Check the database for existing data
    if (_cacheSupport && !skipCacheCheck) {
      // Validate the cache
      if ((martianSol != null &&
              await _isPhotosSolCacheValid(rovers[0], martianSol)) ||
          (earthDate != null &&
              await _isPhotosDateCacheValid(rovers, earthDate))) {
        // Build the where clause and search for the photos in cache
        String whereClause =
            "${MarsRoverPhotoItemModel.keyRover} IN ('${rovers.join("','")}')";
        if (earthDate != null) {
          whereClause +=
              " AND ${MarsRoverPhotoItemModel.keyEarthDate} = ${earthDate.millisecondsSinceEpoch}";
        }
        if (martianSol != null) {
          whereClause += " AND ${MarsRoverPhotoItemModel.keySol} = $martianSol";
        }
        if (cameras != null && cameras.isNotEmpty) {
          whereClause += " AND (";
          for (MarsRoverCameras camera in cameras) {
            if (camera != MarsRoverCameras.unknown) {
              whereClause +=
                  "${MarsRoverPhotoItemModel.keyCamera} = '${MarsRoverCamerasUtil.toStringKey(camera)}' OR ";
            } else {
              String cameraGroup = "(";
              for (MarsRoverCameras groupCamera in MarsRoverCameras.values) {
                if (groupCamera != MarsRoverCameras.unknown) {
                  cameraGroup +=
                      "'${MarsRoverCamerasUtil.toStringKey(groupCamera)}', ";
                }
              }
              cameraGroup = cameraGroup.substring(0, cameraGroup.length - 2);
              cameraGroup += ")";
              whereClause +=
                  "${MarsRoverPhotoItemModel.keyCamera} NOT IN $cameraGroup OR ";
            }
          }
          whereClause = whereClause.substring(0, whereClause.length - 4);
          whereClause += ")";
        }
        List<Map<String, dynamic>> mapList =
            await DatabaseManager.getConnection()
                .query(MarsRoverPhotoItemModel.tableName, where: whereClause);

        List<MarsRoverPhotoItem> photoItems = <MarsRoverPhotoItem>[];
        for (Map<String, dynamic> map in mapList) {
          photoItems.add(MarsRoverPhotoItem.fromMap(map));
        }
        Log.out(
            "requestManifest() A cache hit was found for $rovers on $earthDate where $cameras.");
        return Tuple2(HttpStatus.ok, photoItems);
      }
    }
    // The photos do not exist in the database. Request the photos from
    // the NASA servers.
    List<MarsRoverPhotoItem> photoItems = <MarsRoverPhotoItem>[];
    for (String rover in rovers) {
      Map<String, String> params = {};
      if (earthDate != null) {
        params[_cParamEarthDate] = Util.toRequestDateFormat(earthDate);
      }
      if (martianSol != null) {
        params[_cParamSol] = martianSol.toString();
      }
      if (cameras != null && cameras.length == 1) {
        params[_cParamCamera] = MarsRoverCamerasUtil.toStringKey(cameras[0]);
      }
      if (page != null) {
        params[_cParamPage] = page.toString();
      }
      http.Response response = await RequestManager.get(
          _cPhotoEndpoint.replaceFirst("%s", rover),
          params: params);
      if (response.statusCode != HttpStatus.ok) {
        return Tuple2(response.statusCode, null);
      }
      // Parse the response
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (!jsonResponse.containsKey(_cKeyPhotos)) {
        return Tuple2(response.statusCode, null);
      }
      for (Map<String, dynamic> map in jsonResponse[_cKeyPhotos]) {
        MarsRoverPhotoItem marsRoverPhotoItem =
            MarsRoverPhotoItem.fromUrlMap(map);
        if (cameras == null ||
            cameras.isEmpty ||
            cameras.contains(marsRoverPhotoItem.camera)) {
          marsRoverPhotoItem.expiration = DateTime.now().add(_cacheExpiration!);
          photoItems.add(marsRoverPhotoItem);
        }

        // Insert the response into the database for caching
        if (_cacheSupport) {
          await DatabaseManager.getConnection().insert(
            MarsRoverPhotoItemModel.tableName,
            marsRoverPhotoItem.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
    // Return the photos list
    return Tuple2(HttpStatus.ok, photoItems);
  }
}
