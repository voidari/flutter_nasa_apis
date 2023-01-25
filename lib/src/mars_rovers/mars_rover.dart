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
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

/// The manager for Mars Rover requests, providing a framework and caching
/// options to reduce the API key usage.
class NasaMarsRover {
  static const String _cManifestEndpoint = "/mars-photos/api/v1/manifests/%s";
  static const String _cPhotoEndpoint = "/mars-photos/api/v1/rovers/%s/photos";

  static const String roverSojourner = "Sojourner";
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
  static late Duration? _defaultCacheExpiration;
  static late Duration? _defaultManifestCacheExpiration;

  /// Initializes the APOD manager. This is for internal use only. Use the
  /// NASA initialization function.
  static void init({
    bool cacheSupport = true,
    Duration? defaultCacheExpiration = const Duration(days: 7),
    Duration? defaultManifestCacheExpiration = const Duration(hours: 4),
  }) {
    _cacheSupport = cacheSupport;
    _defaultCacheExpiration = defaultCacheExpiration;
    _defaultManifestCacheExpiration = defaultManifestCacheExpiration;

    if (_cacheSupport) {
      // Start the loop timer for the specified duration
      Timer.periodic(const Duration(seconds: 5), (timer) {
        _deleteExpiredCache();
      });
    }
  }

  /// The update loop that checks for expired rows. Removes expired entries.
  static Future<void> _deleteExpiredCache() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    await DatabaseManager.getConnection()
        .delete(MarsRoverManifestModel.tableName,
            where: "${MarsRoverManifestModel.keyExpiration} < $now AND "
                "${MarsRoverManifestModel.keyExpiration} > 0");
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
    // Check the database for existing manifest data
    if (_cacheSupport) {
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
            dayInfoItems.add(MarsRoverDayInfoItem.fromMap(mapIter));
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
      // Set the expiration and write the manifest to the database
      manifest.expiration =
          DateTime.now().add(_defaultManifestCacheExpiration!);
      await DatabaseManager.getConnection().insert(
        MarsRoverManifestModel.tableName,
        manifest.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      if (manifest.dayInfoItems != null) {
        for (MarsRoverDayInfoItem marsRoverDayInfoItem
            in manifest.dayInfoItems!) {
          await DatabaseManager.getConnection().insert(
            MarsRoverDayInfoItemModel.tableName,
            marsRoverDayInfoItem.toMap(rover: manifest.name),
            conflictAlgorithm: ConflictAlgorithm.ignore,
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

  /// Requests the photos for the provided [rover] on the selected [martianSol].
  /// The optional [camera] and [page] can be provided. The tuple returned will
  /// contain a http response code for understanding failures, and a
  /// list of MarsRoverPhotoItem items if the request was successful.
  static Future<Tuple2<int, List<MarsRoverPhotoItem>?>> requestByMartianSol(
      final String rover, final int martianSol,
      {MarsRoverCameras? camera, int? page}) async {
    return _requestPhotos(rover,
        martianSol: martianSol, camera: camera, page: page);
  }

  /// Requests the photos for the provided [rover] on the selected [earthDate].
  /// The optional [camera] and [page] can be provided. The tuple returned will
  /// contain a http response code for understanding failures, and a
  /// list of MarsRoverPhotoItem items if the request was successful.
  static Future<Tuple2<int, List<MarsRoverPhotoItem>?>> requestByEarthDate(
      final String rover, DateTime earthDate,
      {MarsRoverCameras? camera, int? page}) async {
    return _requestPhotos(rover,
        earthDate: earthDate, camera: camera, page: page);
  }

  /// Requests the photos for the provided [rover] on the selected [earthDate].
  /// The optional [camera] and [page] can be provided. The tuple returned will
  /// contain a http response code for understanding failures, and a
  /// MarsRoverManifest item if the request was successful.
  static Future<Tuple2<int, List<MarsRoverPhotoItem>?>> _requestPhotos(
      final String rover,
      {DateTime? earthDate,
      int? martianSol,
      MarsRoverCameras? camera,
      int? page}) async {
    // Check the database for existing data
    if (_cacheSupport) {
      String whereClause = "${MarsRoverPhotoItemModel.keyRover} == '$rover'";
      if (earthDate != null) {
        whereClause +=
            " AND ${MarsRoverPhotoItemModel.keyEarthDate} = ${earthDate.millisecondsSinceEpoch}";
      }
      if (martianSol != null) {
        whereClause += " AND ${MarsRoverPhotoItemModel.keySol} = $martianSol";
      }
      if (camera != null) {
        whereClause +=
            " AND ${MarsRoverPhotoItemModel.keyCamera} = ${camera.name}";
      }
      List<Map<String, dynamic>> mapList = await DatabaseManager.getConnection()
          .query(MarsRoverPhotoItemModel.tableName, where: whereClause);
      if (mapList.isNotEmpty) {
        List<MarsRoverPhotoItem> photoItems = <MarsRoverPhotoItem>[];
        for (Map<String, dynamic> map in mapList) {
          photoItems.add(MarsRoverPhotoItem.fromMap(map));
        }
        Log.out(
            "requestManifest() A cache hit was found for $earthDate and $camera.");
        return Tuple2(HttpStatus.ok, photoItems);
      }
    }
    // The photos do not exist in the database. Request the photos from
    // the NASA servers.
    Map<String, String> params = {};
    if (earthDate != null) {
      params[_cParamEarthDate] = Util.toRequestDateFormat(earthDate);
    }
    if (martianSol != null) {
      params[_cParamSol] = martianSol.toString();
    }
    if (camera != null) {
      params[_cParamCamera] = MarsRoverCamerasUtil.toStringKey(camera);
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
    List<MarsRoverPhotoItem> photoItems = <MarsRoverPhotoItem>[];
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    if (!jsonResponse.containsKey(_cKeyPhotos)) {
      return Tuple2(response.statusCode, null);
    }
    for (Map<String, dynamic> map in jsonResponse[_cKeyPhotos]) {
      MarsRoverPhotoItem marsRoverPhotoItem =
          MarsRoverPhotoItem.fromUrlMap(map);
      marsRoverPhotoItem.expiration =
          DateTime.now().add(_defaultCacheExpiration!);
      photoItems.add(marsRoverPhotoItem);

      // Insert the response into the database for caching
      if (_cacheSupport) {
        await DatabaseManager.getConnection().insert(
          MarsRoverPhotoItemModel.tableName,
          marsRoverPhotoItem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    // Return the photos list
    return Tuple2(HttpStatus.ok, photoItems);
  }
}
