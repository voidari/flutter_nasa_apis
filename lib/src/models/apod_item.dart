// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:uuid/uuid.dart';

/// The possible media types of an APOD.
enum MediaType { image, video, unknown }

/// The container for APOD data and helper functions for providing the
/// parsed information.
class ApodItem {
  // Map constants
  static const String _cUuid = "uuid";
  static const String _cCopyright = "copyright";
  static const String _cDate = "date";
  static const String _cExplanation = "explanation";
  static const String _cHdUrl = "hdurl";
  static const String _cMediaType = "media_type";
  static const String _cServiceVersion = "service_version";
  static const String _cThumnailUrl = "thumbnail_url";
  static const String _cTitle = "title";
  static const String _cUrl = "url";

  static const String _cValueMediaTypeImage = "image";
  static const String _cValueMediaTypeVideo = "video";

  /// The unique ID of the item, not provided by NASA.
  final String uuid;

  /// The copyright notice for the image or video. If no copyright exists,
  /// the copyright will be empty.
  final String copyright;

  /// The date that the image or video was posted.
  final DateTime date;

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

  /// The constructor of the APOD item.
  ApodItem(
      this.uuid,
      this.copyright,
      this.date,
      this.explanation,
      this.hdUrl,
      this.mediaType,
      this.serviceVersion,
      this.thumbnailUrl,
      this.title,
      this.url);

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
  static ApodItem fromMap(Map map) {
    String uuid;
    if (map.containsKey(_cUuid)) {
      uuid = map[_cUuid];
    } else {
      uuid = const Uuid().v4();
    }
    String copyright = map.containsKey(_cCopyright) ? map[_cCopyright] : "";
    DateTime date =
        map.containsKey(_cDate) ? DateTime.parse(map[_cDate]) : DateTime.now();
    String explanation =
        map.containsKey(_cExplanation) ? map[_cExplanation] : "";
    String hdUrl = map.containsKey(_cHdUrl) ? map[_cHdUrl] : "";
    MediaType mediaType =
        _toMediaType(map.containsKey(_cMediaType) ? map[_cMediaType] : "");
    String serviceVersion =
        map.containsKey(_cServiceVersion) ? map[_cServiceVersion] : "";
    String thumbnailUrl =
        map.containsKey(_cThumnailUrl) ? map[_cThumnailUrl] : "";
    String title = map.containsKey(_cTitle) ? map[_cTitle] : "";
    String url = map.containsKey(_cUrl) ? map[_cUrl] : "";

    return ApodItem(uuid, copyright, date, explanation, hdUrl, mediaType,
        serviceVersion, thumbnailUrl, title, url);
  }

  /// Creates a map given the current APOD item data.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map.putIfAbsent(_cUuid, () => uuid);
    map.putIfAbsent(_cCopyright, () => copyright);
    map.putIfAbsent(_cDate, () => date.toString());
    map.putIfAbsent(_cExplanation, () => explanation);
    map.putIfAbsent(_cHdUrl, () => hdUrl);
    map.putIfAbsent(_cMediaType, () => _fromMediaType(mediaType));
    map.putIfAbsent(_cServiceVersion, () => serviceVersion);
    map.putIfAbsent(_cThumnailUrl, () => thumbnailUrl);
    map.putIfAbsent(_cTitle, () => title);
    map.putIfAbsent(_cUrl, () => url);
    return map;
  }

  /// Utility to convert the string to a media type.
  static MediaType _toMediaType(String mediaType) {
    if (mediaType == _cValueMediaTypeImage) {
      return MediaType.image;
    } else if (mediaType == _cValueMediaTypeVideo) {
      return MediaType.video;
    } else {
      return MediaType.unknown;
    }
  }

  /// Utility to convert a media type to a string.
  static String _fromMediaType(MediaType mediaType) {
    if (mediaType == MediaType.image) {
      return _cValueMediaTypeImage;
    } else if (mediaType == MediaType.video) {
      return _cValueMediaTypeVideo;
    } else {
      return "unknown";
    }
  }
}
