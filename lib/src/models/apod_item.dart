// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nasa_apis/src/models/apod_item_model.dart';

/// The possible media types of an APOD.
enum MediaType { image, video, unknown }

/// The container for APOD data and helper functions for providing the
/// parsed information.
class ApodItem {
  /// The date that the image or video was posted.
  final DateTime date;

  /// An empty field by default, but can add new type IDs to add searchability
  /// and sorting to the saved items.
  List<String> categories;

  /// The copyright notice for the image or video. If no copyright exists,
  /// the copyright will be empty.
  final String copyright;

  /// An unformatted description of the media item.
  final String explanation;

  /// For images, the URL of the HD image. Not all images have HD URLs.
  final String hdUrl;

  /// The media type of the item, such as image or video.
  final MediaType mediaType;

  /// The service version of the item provided by the host server.
  final String serviceVersion;

  /// The thumbnail URL of the video if provided.
  final String thumbnailUrl;

  /// The title of the item.
  final String title;

  /// The standard (or only) URL version of an image or the video URL.
  final String url;

  /// The expiration time of the cache. Set to null to keep the cache persistent
  /// and avoid deletion. Set to the current time or less to force deletion.
  DateTime? expiration;

  /// The constructor of the APOD item.
  ApodItem(
      this.date,
      this.copyright,
      this.explanation,
      this.hdUrl,
      this.mediaType,
      this.serviceVersion,
      this.thumbnailUrl,
      this.title,
      this.url,
      {this.categories = const <String>[],
      this.expiration});

  /// Determines if the APOD item is an image.
  bool isImage() {
    return mediaType == MediaType.image;
  }

  /// Determines if the APOD item is a video.
  bool isVideo() {
    return mediaType == MediaType.video;
  }

  /// Gets the image corresponding to the type of item.
  String getImageUrl({bool isHd = false}) {
    if (isVideo() && thumbnailUrl.isNotEmpty) {
      return thumbnailUrl;
    } else if (isImage() && isHd && hdUrl.isNotEmpty) {
      return hdUrl;
    } else {
      return url;
    }
  }

  /// Creates an item from the provided map object
  static ApodItem fromMap(Map<String, dynamic> map) {
    DateTime? expiration = map.containsKey(ApodItemModel.keyExpiration)
        ? DateTime.fromMillisecondsSinceEpoch(map[ApodItemModel.keyExpiration])
        : null;
    List<String> categories = map.containsKey(ApodItemModel.keyLocalCategories)
        ? map[ApodItemModel.keyLocalCategories].split(',')
        : <String>[];
    String copyright = map.containsKey(ApodItemModel.keyCopyright)
        ? map[ApodItemModel.keyCopyright]
        : "";
    DateTime date = DateTime(0);
    if (map.containsKey(ApodItemModel.keyDate)) {
      date = map[ApodItemModel.keyDate] is int
          ? DateTime.fromMillisecondsSinceEpoch(map[ApodItemModel.keyDate])
          : DateTime.parse(map[ApodItemModel.keyDate]);
    }
    String explanation = map.containsKey(ApodItemModel.keyExplanation)
        ? map[ApodItemModel.keyExplanation]
        : "";
    String hdUrl = map.containsKey(ApodItemModel.keyHdUrl)
        ? map[ApodItemModel.keyHdUrl]
        : "";
    MediaType mediaType = _toMediaType(
        map.containsKey(ApodItemModel.keyMediaType)
            ? map[ApodItemModel.keyMediaType]
            : "");
    String serviceVersion = map.containsKey(ApodItemModel.keyServiceVersion)
        ? map[ApodItemModel.keyServiceVersion]
        : "";
    String thumbnailUrl = map.containsKey(ApodItemModel.keyThumbnailUrl)
        ? map[ApodItemModel.keyThumbnailUrl]
        : "";
    String title = map.containsKey(ApodItemModel.keyTitle)
        ? map[ApodItemModel.keyTitle]
        : "";
    String url =
        map.containsKey(ApodItemModel.keyUrl) ? map[ApodItemModel.keyUrl] : "";

    return ApodItem(date, copyright, explanation, hdUrl, mediaType,
        serviceVersion, thumbnailUrl, title, url,
        categories: categories, expiration: expiration);
  }

  /// Creates a map given the current APOD item data.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map.putIfAbsent(ApodItemModel.keyDate, () => date.millisecondsSinceEpoch);
    map.putIfAbsent(ApodItemModel.keyExpiration,
        () => expiration != null ? expiration?.millisecondsSinceEpoch : 0);
    map.putIfAbsent(
        ApodItemModel.keyLocalCategories, () => categories.join(','));
    map.putIfAbsent(ApodItemModel.keyCopyright, () => copyright);
    map.putIfAbsent(ApodItemModel.keyExplanation, () => explanation);
    map.putIfAbsent(ApodItemModel.keyHdUrl, () => hdUrl);
    map.putIfAbsent(
        ApodItemModel.keyMediaType, () => _fromMediaType(mediaType));
    map.putIfAbsent(ApodItemModel.keyServiceVersion, () => serviceVersion);
    map.putIfAbsent(ApodItemModel.keyThumbnailUrl, () => thumbnailUrl);
    map.putIfAbsent(ApodItemModel.keyTitle, () => title);
    map.putIfAbsent(ApodItemModel.keyUrl, () => url);
    return map;
  }

  /// Utility to convert the string to a media type.
  static MediaType _toMediaType(String mediaType) {
    if (mediaType == ApodItemModel.valueMediaTypeImage) {
      return MediaType.image;
    } else if (mediaType == ApodItemModel.valueMediaTypeVideo) {
      return MediaType.video;
    } else {
      return MediaType.unknown;
    }
  }

  /// Utility to convert a media type to a string.
  static String _fromMediaType(MediaType mediaType) {
    if (mediaType == MediaType.image) {
      return ApodItemModel.valueMediaTypeImage;
    } else if (mediaType == MediaType.video) {
      return ApodItemModel.valueMediaTypeVideo;
    } else {
      return "unknown";
    }
  }

  /// Provides an override for a detailed ApodItem string.
  @override
  String toString() {
    return "ApodItem("
        "${ApodItemModel.keyDate}: ${date.toString()}, "
        "${ApodItemModel.keyLocalCategories}: [${categories.join(',')}], "
        "${ApodItemModel.keyCopyright}: $copyright, "
        "${ApodItemModel.keyExplanation}: $explanation, "
        "${ApodItemModel.keyHdUrl}: $hdUrl, "
        "${ApodItemModel.keyMediaType}: ${_fromMediaType(mediaType)}, "
        "${ApodItemModel.keyServiceVersion}: $serviceVersion, "
        "${ApodItemModel.keyThumbnailUrl}: $thumbnailUrl, "
        "${ApodItemModel.keyTitle}: $title, "
        "${ApodItemModel.keyUrl}: $url"
        ")";
  }

  /// Comparison operator for the item.
  @override
  bool operator ==(Object other) {
    if (other is! ApodItem) {
      return false;
    }
    ApodItem otherItem = other;
    return date == otherItem.date &&
        listEquals(categories, otherItem.categories) &&
        copyright == otherItem.copyright &&
        explanation == otherItem.explanation &&
        hdUrl == otherItem.hdUrl &&
        mediaType == otherItem.mediaType &&
        serviceVersion == otherItem.serviceVersion &&
        thumbnailUrl == otherItem.thumbnailUrl &&
        title == otherItem.title &&
        url == otherItem.url;
  }

  /// The hash code override.
  @override
  int get hashCode => jsonEncode(toMap()).hashCode;
}
