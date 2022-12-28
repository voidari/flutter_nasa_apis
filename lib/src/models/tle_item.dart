// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:convert';

import 'package:nasa_apis/src/models/tle_item_model.dart';

/// The container for two-line element set data and helper functions for
/// providing the parsed information.
class TleItem {
  /// The ID of the TLE element
  final String id;

  /// The type of TLE item
  final String type;

  /// The assigned ID of the satellite.
  final int satelliteId;

  /// The name of the orbiting object.
  final String name;

  /// The date of the TLE element information.
  final DateTime date;

  /// The satellite catalog number.
  final int satelliteCatalogNumber;

  /// U: unclassified, C: classified, S: secret
  final String classification;

  /// International Designator (last two digits of launch year)
  final int launchYear;

  /// International Designator (launch number of the year)
  final int launchNumOfYear;

  /// International Designator (piece of the launch)
  final String pieceOfLaunch;

  /// Epoch year (last two digits of year)
  final int epochYear;

  /// Epoch (day of the year and fractional portion of the day)
  final double epochDayOfYear;

  /// First derivative of mean motion; the ballistic coefficient
  final double meanMotionFirstDeriv;

  /// Second derivative of mean motion (decimal point assumed)
  final double meanMotionSecondDeriv;

  /// B*, the drag term, or radiation pressure coefficient (decimal point assumed)
  final double radiationPressureCoeff;

  /// Ephemeris type (always zero; only used in undistributed TLE data)
  final int ephemerisType;

  /// Element set number. Incremented when a new TLE is generated for this object.
  final int elementSetNumber;

  /// Inclination (degrees)
  final double inclination;

  /// Right ascension of the ascending node (degrees)
  final double rightAscension;

  /// Eccentricity (decimal point assumed)
  final double eccentricity;

  /// Argument of perigee (degrees)
  final double argumentPerigee;

  /// Mean anomaly (degrees)
  final double meanAnomaly;

  /// Mean motion (revolutions per day)
  final double meanMotion;

  /// Revolution number at epoch (revolutions)
  final int revolutionsAtEpoch;

  /// The expiration time of the cache. Set to null to keep the cache persistent
  /// and avoid deletion. Set to the current time or less to force deletion. The
  /// expiration date should be a future date and time.
  DateTime? expiration;

  /// The constructor of the TLE item.
  TleItem(
      this.id,
      this.type,
      this.satelliteId,
      this.name,
      this.date,
      this.satelliteCatalogNumber,
      this.classification,
      this.launchYear,
      this.launchNumOfYear,
      this.pieceOfLaunch,
      this.epochYear,
      this.epochDayOfYear,
      this.meanMotionFirstDeriv,
      this.meanMotionSecondDeriv,
      this.radiationPressureCoeff,
      this.ephemerisType,
      this.elementSetNumber,
      this.inclination,
      this.rightAscension,
      this.eccentricity,
      this.argumentPerigee,
      this.meanAnomaly,
      this.meanMotion,
      this.revolutionsAtEpoch,
      {this.expiration});

  /// Creates an item from the provided [map] object.
  static TleItem fromMap(Map<String, dynamic> map) {
    // Parse the header information
    String id =
        map.containsKey(TleItemModel.keyId) ? map[TleItemModel.keyId] : "";
    String type =
        map.containsKey(TleItemModel.keyType) ? map[TleItemModel.keyType] : "";
    int satelliteId = map.containsKey(TleItemModel.keySatelliteId)
        ? map[TleItemModel.keySatelliteId]
        : 0;
    String name =
        map.containsKey(TleItemModel.keyName) ? map[TleItemModel.keyName] : "";
    DateTime date = DateTime(0);
    if (map.containsKey(TleItemModel.keyDate)) {
      date = map[TleItemModel.keyDate] is int
          ? DateTime.fromMillisecondsSinceEpoch(map[TleItemModel.keyDate])
          : DateTime.parse(map[TleItemModel.keyDate]);
    }
    DateTime? expiration = map.containsKey(TleItemModel.keyExpiration)
        ? DateTime.fromMillisecondsSinceEpoch(map[TleItemModel.keyExpiration])
        : null;

    // Parse the first line
    int satelliteCatalogNumber = 0;
    String classification = "";
    int launchYear = 0;
    int launchNumOfYear = 0;
    String pieceOfLaunch = "";
    int epochYear = 0;
    double epochDayOfYear = 0.0;
    double meanMotionFirstDeriv = 0.0;
    double meanMotionSecondDeriv = 0.0;
    double radiationPressureCoeff = 0.0;
    int ephemerisType = 0;
    int elementSetNumber = 0;

    // Parse the second line
    double inclination = 0.0;
    double rightAscension = 0.0;
    double eccentricity = 0.0;
    double argumentPerigee = 0.0;
    double meanAnomaly = 0.0;
    double meanMotion = 0.0;
    int revolutionsAtEpoch = 0;

    return TleItem(
        id,
        type,
        satelliteId,
        name,
        date,
        satelliteCatalogNumber,
        classification,
        launchYear,
        launchNumOfYear,
        pieceOfLaunch,
        epochYear,
        epochDayOfYear,
        meanMotionFirstDeriv,
        meanMotionSecondDeriv,
        radiationPressureCoeff,
        ephemerisType,
        elementSetNumber,
        inclination,
        rightAscension,
        eccentricity,
        argumentPerigee,
        meanAnomaly,
        meanMotion,
        revolutionsAtEpoch,
        expiration: expiration);
  }

  /// Creates a map given the current APOD item data.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map.putIfAbsent(TleItemModel.keyId, () => id);
    map.putIfAbsent(TleItemModel.keyType, () => type);
    map.putIfAbsent(TleItemModel.keySatelliteId, () => satelliteId);
    map.putIfAbsent(TleItemModel.keyName, () => name);
    map.putIfAbsent(TleItemModel.keyDate, () => date.millisecondsSinceEpoch);
    map.putIfAbsent(TleItemModel.keyLine1, () => getFirstLine());
    map.putIfAbsent(TleItemModel.keyLine2, () => getSecondLine());
    map.putIfAbsent(TleItemModel.keyExpiration,
        () => expiration != null ? expiration?.millisecondsSinceEpoch : 0);
    return map;
  }

  /// Constructs the first line of the TLE item.
  String getFirstLine() {
    return "";
  }

  /// Constructs the second line of the TLE item.
  String getSecondLine() {
    return "";
  }

  /// Provides an override for a detailed TleItem string.
  @override
  String toString() {
    return "TleItem("
        "${TleItemModel.keyId}: ${id.toString()}, "
        "${TleItemModel.keyType}: $type, "
        "${TleItemModel.keySatelliteId}: ${satelliteId.toString()}, "
        "${TleItemModel.keyName}: $name, "
        "${TleItemModel.keyDate}: ${date.toUtc().toString()}, "
        "${TleItemModel.keyLine1}: ${getFirstLine()}, "
        "${TleItemModel.keyLine2}: ${getSecondLine()}, "
        "${TleItemModel.keyExpiration}: $expiration, "
        ")";
  }

  /// Comparison operator for the item. Used to perform a deep comparison.
  @override
  bool operator ==(Object other) {
    if (other is! TleItem) {
      return false;
    }
    TleItem otherItem = other;
    return id == otherItem.id &&
        type == otherItem.type &&
        satelliteId == otherItem.satelliteId &&
        name == otherItem.name &&
        date == otherItem.date &&
        satelliteCatalogNumber == otherItem.satelliteCatalogNumber &&
        classification == otherItem.classification &&
        launchYear == otherItem.launchYear &&
        launchNumOfYear == otherItem.launchNumOfYear &&
        pieceOfLaunch == otherItem.pieceOfLaunch &&
        epochYear == otherItem.epochYear &&
        epochDayOfYear == otherItem.epochDayOfYear &&
        meanMotionFirstDeriv == otherItem.meanMotionFirstDeriv &&
        meanMotionSecondDeriv == otherItem.meanMotionSecondDeriv &&
        radiationPressureCoeff == otherItem.radiationPressureCoeff &&
        ephemerisType == otherItem.ephemerisType &&
        elementSetNumber == otherItem.elementSetNumber &&
        inclination == otherItem.inclination &&
        rightAscension == otherItem.rightAscension &&
        eccentricity == otherItem.eccentricity &&
        argumentPerigee == otherItem.argumentPerigee &&
        meanAnomaly == otherItem.meanAnomaly &&
        meanMotion == otherItem.meanMotion &&
        revolutionsAtEpoch == otherItem.revolutionsAtEpoch &&
        expiration == otherItem.expiration;
  }

  /// The hash code override.
  @override
  int get hashCode => jsonEncode(toMap()).hashCode;
}
