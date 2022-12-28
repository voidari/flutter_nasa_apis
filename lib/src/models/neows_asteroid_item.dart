// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nasa_apis/src/models/apod_item_model.dart';

/// The container for APOD data and helper functions for providing the
/// parsed information.
class NeoWsAsteroidItem {
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
  /// and avoid deletion. Set to the current time or less to force deletion. The
  /// expiration date should be a future date and time.
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

  /// Gets the image corresponding to the type of item. The HD image URL can
  /// be selected if [isHd] is set to true. The standard version will be
  /// returned by default.
  String getImageUrl({bool isHd = false}) {
    if (isVideo() && thumbnailUrl.isNotEmpty) {
      return thumbnailUrl;
    } else if (isImage() && isHd && hdUrl.isNotEmpty) {
      return hdUrl;
    } else {
      return url;
    }
  }

  /// Creates an item from the provided [map] object.
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

  /// Comparison operator for the item. Used to perform a deep comparison.
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


{
   "links":{
      "self":"http://api.nasa.gov/neo/rest/v1/neo/2382406?api_key=DEMO_KEY"
   },
   "id":"2382406",
   "neo_reference_id":"2382406",
   "name":"382406 (1996 AJ1)",
   "designation":"382406",
   "nasa_jpl_url":"http://ssd.jpl.nasa.gov/sbdb.cgi?sstr=2382406",
   "absolute_magnitude_h":20.53,
   "estimated_diameter":{
      "kilometers":{
         "estimated_diameter_min":0.208235599,
         "estimated_diameter_max":0.4656289548
      },
      "meters":{
         "estimated_diameter_min":208.2355990473,
         "estimated_diameter_max":465.6289548051
      },
      "miles":{
         "estimated_diameter_min":0.1293915624,
         "estimated_diameter_max":0.2893283293
      },
      "feet":{
         "estimated_diameter_min":683.1876827782,
         "estimated_diameter_max":1527.6541000826
      }
   },
   "is_potentially_hazardous_asteroid":true,
   "close_approach_data":[
      {
         "close_approach_date":"1901-03-26",
         "close_approach_date_full":"1901-Mar-26 03:29",
         "epoch_date_close_approach":-2170182660000,
         "relative_velocity":{
            "kilometers_per_second":"37.5880071327",
            "kilometers_per_hour":"135316.8256778903",
            "miles_per_hour":"84080.6131552424"
         },
         "miss_distance":{
            "astronomical":"0.3325029764",
            "lunar":"129.3436578196",
            "kilometers":"49741737.038100268",
            "miles":"30908082.1686609784"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1901-05-10",
         "close_approach_date_full":"1901-May-10 05:14",
         "epoch_date_close_approach":-2166288360000,
         "relative_velocity":{
            "kilometers_per_second":"43.5369055428",
            "kilometers_per_hour":"156732.8599541052",
            "miles_per_hour":"97387.704008705"
         },
         "miss_distance":{
            "astronomical":"0.0616159079",
            "lunar":"23.9685881731",
            "kilometers":"9217608.579956173",
            "miles":"5727556.3812662674"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1901-05-30",
         "close_approach_date_full":"1901-May-30 07:19",
         "epoch_date_close_approach":-2164552860000,
         "relative_velocity":{
            "kilometers_per_second":"36.6976263393",
            "kilometers_per_hour":"132111.4548213284",
            "miles_per_hour":"82088.920358286"
         },
         "miss_distance":{
            "astronomical":"0.1176446593",
            "lunar":"45.7637724677",
            "kilometers":"17599390.448155691",
            "miles":"10935754.1268268958"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1902-12-21",
         "close_approach_date_full":"1902-Dec-21 17:14",
         "epoch_date_close_approach":-2115269160000,
         "relative_velocity":{
            "kilometers_per_second":"21.4700644589",
            "kilometers_per_hour":"77292.2320520735",
            "miles_per_hour":"48026.3871881342"
         },
         "miss_distance":{
            "astronomical":"0.1960043219",
            "lunar":"76.2456812191",
            "kilometers":"29321829.067034353",
            "miles":"18219739.7216979514"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1904-03-25",
         "close_approach_date_full":"1904-Mar-25 15:28",
         "epoch_date_close_approach":-2075531520000,
         "relative_velocity":{
            "kilometers_per_second":"37.7891683752",
            "kilometers_per_hour":"136041.006150824",
            "miles_per_hour":"84530.5907385495"
         },
         "miss_distance":{
            "astronomical":"0.3384712306",
            "lunar":"131.6653087034",
            "kilometers":"50634575.154038822",
            "miles":"31462866.0482348636"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1905-12-21",
         "close_approach_date_full":"1905-Dec-21 05:43",
         "epoch_date_close_approach":-2020616220000,
         "relative_velocity":{
            "kilometers_per_second":"21.2330495828",
            "kilometers_per_hour":"76438.9784981124",
            "miles_per_hour":"47496.2086117855"
         },
         "miss_distance":{
            "astronomical":"0.2044491207",
            "lunar":"79.5307079523",
            "kilometers":"30585152.980092909",
            "miles":"19004732.8006597842"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1907-03-25",
         "close_approach_date_full":"1907-Mar-25 20:36",
         "epoch_date_close_approach":-1980905040000,
         "relative_velocity":{
            "kilometers_per_second":"38.1691553163",
            "kilometers_per_hour":"137408.959138802",
            "miles_per_hour":"85380.5835271073"
         },
         "miss_distance":{
            "astronomical":"0.3498935697",
            "lunar":"136.1085986133",
            "kilometers":"52343332.753816539",
            "miles":"32524638.7856806782"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1908-12-20",
         "close_approach_date_full":"1908-Dec-20 17:42",
         "epoch_date_close_approach":-1925965080000,
         "relative_velocity":{
            "kilometers_per_second":"20.9049313779",
            "kilometers_per_hour":"75257.7529605376",
            "miles_per_hour":"46762.2409992851"
         },
         "miss_distance":{
            "astronomical":"0.2176797222",
            "lunar":"84.6774119358",
            "kilometers":"32564422.783311714",
            "miles":"20234594.0269570932"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1910-03-25",
         "close_approach_date_full":"1910-Mar-25 03:45",
         "epoch_date_close_approach":-1886271300000,
         "relative_velocity":{
            "kilometers_per_second":"38.5240429024",
            "kilometers_per_hour":"138686.5544487822",
            "miles_per_hour":"86174.4315684669"
         },
         "miss_distance":{
            "astronomical":"0.3603771667",
            "lunar":"140.1867178463",
            "kilometers":"53911656.534954929",
            "miles":"33499149.9945948602"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1910-04-03",
         "close_approach_date_full":"1910-Apr-03 09:30",
         "epoch_date_close_approach":-1885473000000,
         "relative_velocity":{
            "kilometers_per_second":"25.2082483689",
            "kilometers_per_hour":"90749.6941281077",
            "miles_per_hour":"56388.3307764345"
         },
         "miss_distance":{
            "astronomical":"0.1189435708",
            "lunar":"46.2690490412",
            "kilometers":"17793704.841874196",
            "miles":"11056495.4922320648"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1911-12-21",
         "close_approach_date_full":"1911-Dec-21 03:26",
         "epoch_date_close_approach":-1831322040000,
         "relative_velocity":{
            "kilometers_per_second":"20.5706205626",
            "kilometers_per_hour":"74054.2340254975",
            "miles_per_hour":"46014.4211365654"
         },
         "miss_distance":{
            "astronomical":"0.2299998901",
            "lunar":"89.4699572489",
            "kilometers":"34407493.659194087",
            "miles":"21379825.1641569206"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1913-03-24",
         "close_approach_date_full":"1913-Mar-24 06:36",
         "epoch_date_close_approach":-1791653040000,
         "relative_velocity":{
            "kilometers_per_second":"38.9728587278",
            "kilometers_per_hour":"140302.2914202406",
            "miles_per_hour":"87178.3876883156"
         },
         "miss_distance":{
            "astronomical":"0.3735059485",
            "lunar":"145.2938139665",
            "kilometers":"55875694.327929695",
            "miles":"34719546.488611991"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1913-04-17",
         "close_approach_date_full":"1913-Apr-17 19:55",
         "epoch_date_close_approach":-1789531500000,
         "relative_velocity":{
            "kilometers_per_second":"31.2056043782",
            "kilometers_per_hour":"112340.1757614455",
            "miles_per_hour":"69803.8164335493"
         },
         "miss_distance":{
            "astronomical":"0.0460407841",
            "lunar":"17.9098650149",
            "kilometers":"6887603.234489867",
            "miles":"4279758.1948874846"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1914-12-20",
         "close_approach_date_full":"1914-Dec-20 14:28",
         "epoch_date_close_approach":-1736674320000,
         "relative_velocity":{
            "kilometers_per_second":"20.1891657878",
            "kilometers_per_hour":"72680.9968360141",
            "miles_per_hour":"45161.1449506889"
         },
         "miss_distance":{
            "astronomical":"0.245431351",
            "lunar":"95.472795539",
            "kilometers":"36716007.34082237",
            "miles":"22814269.049873906"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1916-03-23",
         "close_approach_date_full":"1916-Mar-23 09:30",
         "epoch_date_close_approach":-1697034600000,
         "relative_velocity":{
            "kilometers_per_second":"39.4455709301",
            "kilometers_per_hour":"142004.055348481",
            "miles_per_hour":"88235.7976136158"
         },
         "miss_distance":{
            "astronomical":"0.3872313253",
            "lunar":"150.6329855417",
            "kilometers":"57928981.462157111",
            "miles":"35995399.9517096918"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1917-12-19",
         "close_approach_date_full":"1917-Dec-19 23:42",
         "epoch_date_close_approach":-1642033080000,
         "relative_velocity":{
            "kilometers_per_second":"19.7404299553",
            "kilometers_per_hour":"71065.5478390537",
            "miles_per_hour":"44157.3677669942"
         },
         "miss_distance":{
            "astronomical":"0.2628752343",
            "lunar":"102.2584661427",
            "kilometers":"39325575.127030941",
            "miles":"24435779.2817953458"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1919-03-23",
         "close_approach_date_full":"1919-Mar-23 06:33",
         "epoch_date_close_approach":-1602437220000,
         "relative_velocity":{
            "kilometers_per_second":"40.0695794813",
            "kilometers_per_hour":"144250.4861326454",
            "miles_per_hour":"89631.6423416985"
         },
         "miss_distance":{
            "astronomical":"0.4054943111",
            "lunar":"157.7372870179",
            "kilometers":"60661085.237677357",
            "miles":"37693050.5167152466"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1920-12-19",
         "close_approach_date_full":"1920-Dec-19 11:12",
         "epoch_date_close_approach":-1547383680000,
         "relative_velocity":{
            "kilometers_per_second":"19.2507019214",
            "kilometers_per_hour":"69302.5269170468",
            "miles_per_hour":"43061.8951279839"
         },
         "miss_distance":{
            "astronomical":"0.2837154724",
            "lunar":"110.3653187636",
            "kilometers":"42443230.357083788",
            "miles":"26373000.4116127544"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1922-03-22",
         "close_approach_date_full":"1922-Mar-22 06:12",
         "epoch_date_close_approach":-1507830480000,
         "relative_velocity":{
            "kilometers_per_second":"40.6493411286",
            "kilometers_per_hour":"146337.6280629287",
            "miles_per_hour":"90928.5111705459"
         },
         "miss_distance":{
            "astronomical":"0.4224620915",
            "lunar":"164.3377535935",
            "kilometers":"63199429.044145105",
            "miles":"39270304.219828249"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1923-12-19",
         "close_approach_date_full":"1923-Dec-19 21:49",
         "epoch_date_close_approach":-1452737460000,
         "relative_velocity":{
            "kilometers_per_second":"18.7469707692",
            "kilometers_per_hour":"67489.0947691765",
            "miles_per_hour":"41935.0989136586"
         },
         "miss_distance":{
            "astronomical":"0.3044373147",
            "lunar":"118.4261154183",
            "kilometers":"45543173.827639689",
            "miles":"28299215.9644141482"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1925-03-20",
         "close_approach_date_full":"1925-Mar-20 23:03",
         "epoch_date_close_approach":-1413248220000,
         "relative_velocity":{
            "kilometers_per_second":"41.3929618765",
            "kilometers_per_hour":"149014.6627552798",
            "miles_per_hour":"92591.9164214681"
         },
         "miss_distance":{
            "astronomical":"0.4439451679",
            "lunar":"172.6946703131",
            "kilometers":"66413251.514632373",
            "miles":"41267280.9019498274"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1925-05-24",
         "close_approach_date_full":"1925-May-24 01:52",
         "epoch_date_close_approach":-1407708480000,
         "relative_velocity":{
            "kilometers_per_second":"32.1926494231",
            "kilometers_per_hour":"115893.5379231078",
            "miles_per_hour":"72011.7374945"
         },
         "miss_distance":{
            "astronomical":"0.027395934",
            "lunar":"10.657018326",
            "kilometers":"4098373.37306058",
            "miles":"2546611.126092804"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1926-10-12",
         "close_approach_date_full":"1926-Oct-12 15:52",
         "epoch_date_close_approach":-1363939680000,
         "relative_velocity":{
            "kilometers_per_second":"31.931105065",
            "kilometers_per_hour":"114951.9782341415",
            "miles_per_hour":"71426.6889199864"
         },
         "miss_distance":{
            "astronomical":"0.0405085132",
            "lunar":"15.7578116348",
            "kilometers":"6059987.291586884",
            "miles":"3765501.4943676392"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1926-12-19",
         "close_approach_date_full":"1926-Dec-19 13:19",
         "epoch_date_close_approach":-1358073660000,
         "relative_velocity":{
            "kilometers_per_second":"18.3511281888",
            "kilometers_per_hour":"66064.0614797581",
            "miles_per_hour":"41049.6386455753"
         },
         "miss_distance":{
            "astronomical":"0.3227535494",
            "lunar":"125.5511307166",
            "kilometers":"48283243.525179778",
            "miles":"30001816.3238378164"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1928-03-20",
         "close_approach_date_full":"1928-Mar-20 07:16",
         "epoch_date_close_approach":-1318610640000,
         "relative_velocity":{
            "kilometers_per_second":"41.7341969193",
            "kilometers_per_hour":"150243.1089095722",
            "miles_per_hour":"93355.2250888394"
         },
         "miss_distance":{
            "astronomical":"0.4538066189",
            "lunar":"176.5307747521",
            "kilometers":"67888503.579341743",
            "miles":"42183960.0279843334"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1929-12-19",
         "close_approach_date_full":"1929-Dec-19 05:50",
         "epoch_date_close_approach":-1263406200000,
         "relative_velocity":{
            "kilometers_per_second":"18.1019332008",
            "kilometers_per_hour":"65166.9595229221",
            "miles_per_hour":"40492.2143768957"
         },
         "miss_distance":{
            "astronomical":"0.3339756453",
            "lunar":"129.9165260217",
            "kilometers":"49962045.168755511",
            "miles":"31044975.2932316118"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1931-03-20",
         "close_approach_date_full":"1931-Mar-20 10:31",
         "epoch_date_close_approach":-1223990940000,
         "relative_velocity":{
            "kilometers_per_second":"42.1599543514",
            "kilometers_per_hour":"151775.8356648672",
            "miles_per_hour":"94307.6018885393"
         },
         "miss_distance":{
            "astronomical":"0.466172048",
            "lunar":"181.340926672",
            "kilometers":"69738345.43433776",
            "miles":"43333398.456510688"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1932-12-19",
         "close_approach_date_full":"1932-Dec-19 01:59",
         "epoch_date_close_approach":-1168725660000,
         "relative_velocity":{
            "kilometers_per_second":"17.8625001575",
            "kilometers_per_hour":"64305.0005669708",
            "miles_per_hour":"39956.6266022936"
         },
         "miss_distance":{
            "astronomical":"0.3472354849",
            "lunar":"135.0746036261",
            "kilometers":"51945688.929457163",
            "miles":"32277554.3706803294"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1934-03-19",
         "close_approach_date_full":"1934-Mar-19 17:23",
         "epoch_date_close_approach":-1129358220000,
         "relative_velocity":{
            "kilometers_per_second":"42.518218653",
            "kilometers_per_hour":"153065.5871509058",
            "miles_per_hour":"95109.0033049615"
         },
         "miss_distance":{
            "astronomical":"0.4767795127",
            "lunar":"185.4672304403",
            "kilometers":"71325199.559557949",
            "miles":"44319423.8873157362"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1934-03-27",
         "close_approach_date_full":"1934-Mar-27 16:41",
         "epoch_date_close_approach":-1128669540000,
         "relative_velocity":{
            "kilometers_per_second":"29.9908793433",
            "kilometers_per_hour":"107967.1656358552",
            "miles_per_hour":"67086.5980030123"
         },
         "miss_distance":{
            "astronomical":"0.019574349",
            "lunar":"7.614421761",
            "kilometers":"2928280.91703663",
            "miles":"1819549.388220294"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1935-12-19",
         "close_approach_date_full":"1935-Dec-19 18:08",
         "epoch_date_close_approach":-1074059520000,
         "relative_velocity":{
            "kilometers_per_second":"17.7778374764",
            "kilometers_per_hour":"64000.2149150346",
            "miles_per_hour":"39767.2446509558"
         },
         "miss_distance":{
            "astronomical":"0.3513102252",
            "lunar":"136.6596776028",
            "kilometers":"52555261.399140324",
            "miles":"32656325.1395075112"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1937-01-09",
         "close_approach_date_full":"1937-Jan-09 07:29",
         "epoch_date_close_approach":-1040661060000,
         "relative_velocity":{
            "kilometers_per_second":"16.4994125452",
            "kilometers_per_hour":"59397.8851625627",
            "miles_per_hour":"36907.5359222601"
         },
         "miss_distance":{
            "astronomical":"0.0516331224",
            "lunar":"20.0852846136",
            "kilometers":"7724205.132489288",
            "miles":"4799598.5089886544"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"1937-03-19",
         "close_approach_date_full":"1937-Mar-19 13:49",
         "epoch_date_close_approach":-1034676660000,
         "relative_velocity":{
            "kilometers_per_second":"42.4342750179",
            "kilometers_per_hour":"152763.3900645246",
            "miles_per_hour":"94921.2297875931"
         },
         "miss_distance":{
            "astronomical":"0.4743602274",
            "lunar":"184.5261284586",
            "kilometers":"70963279.631755638",
            "miles":"44094537.2723102844"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1938-12-19",
         "close_approach_date_full":"1938-Dec-19 13:43",
         "epoch_date_close_approach":-979381020000,
         "relative_velocity":{
            "kilometers_per_second":"17.8483633232",
            "kilometers_per_hour":"64254.1079635909",
            "miles_per_hour":"39925.0039177101"
         },
         "miss_distance":{
            "astronomical":"0.348547206",
            "lunar":"135.584863134",
            "kilometers":"52141919.61205122",
            "miles":"32399486.462778036"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1940-03-19",
         "close_approach_date_full":"1940-Mar-19 11:49",
         "epoch_date_close_approach":-939989460000,
         "relative_velocity":{
            "kilometers_per_second":"42.3394311479",
            "kilometers_per_hour":"152421.9521324652",
            "miles_per_hour":"94709.0735347532"
         },
         "miss_distance":{
            "astronomical":"0.4717522986",
            "lunar":"183.5116441554",
            "kilometers":"70573139.038163982",
            "miles":"43852115.1487156716"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1940-04-13",
         "close_approach_date_full":"1940-Apr-13 13:49",
         "epoch_date_close_approach":-937822260000,
         "relative_velocity":{
            "kilometers_per_second":"26.4749647046",
            "kilometers_per_hour":"95309.8729364354",
            "miles_per_hour":"59221.8485476423"
         },
         "miss_distance":{
            "astronomical":"0.0968087538",
            "lunar":"37.6586052282",
            "kilometers":"14482383.365834406",
            "miles":"8998935.7373345628"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1941-12-19",
         "close_approach_date_full":"1941-Dec-19 07:14",
         "epoch_date_close_approach":-884709960000,
         "relative_velocity":{
            "kilometers_per_second":"17.8682409134",
            "kilometers_per_hour":"64325.6672883667",
            "miles_per_hour":"39969.4680992632"
         },
         "miss_distance":{
            "astronomical":"0.3472021514",
            "lunar":"135.0616368946",
            "kilometers":"51940702.308857518",
            "miles":"32274455.8283210284"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1943-03-20",
         "close_approach_date_full":"1943-Mar-20 04:38",
         "epoch_date_close_approach":-845320920000,
         "relative_velocity":{
            "kilometers_per_second":"42.3702278585",
            "kilometers_per_hour":"152532.8202905467",
            "miles_per_hour":"94777.9626966455"
         },
         "miss_distance":{
            "astronomical":"0.4724572119",
            "lunar":"183.7858554291",
            "kilometers":"70678592.566378653",
            "miles":"43917640.9326772914"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1944-07-16",
         "close_approach_date_full":"1944-Jul-16 10:11",
         "epoch_date_close_approach":-803483340000,
         "relative_velocity":{
            "kilometers_per_second":"17.8052753034",
            "kilometers_per_hour":"64098.9910922969",
            "miles_per_hour":"39828.6203262108"
         },
         "miss_distance":{
            "astronomical":"0.0580555009",
            "lunar":"22.5835898501",
            "kilometers":"8684979.276423083",
            "miles":"5396595.8788932254"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"1944-12-19",
         "close_approach_date_full":"1944-Dec-19 03:07",
         "epoch_date_close_approach":-790030380000,
         "relative_velocity":{
            "kilometers_per_second":"17.875780716",
            "kilometers_per_hour":"64352.810577641",
            "miles_per_hour":"39986.3338836459"
         },
         "miss_distance":{
            "astronomical":"0.3478789981",
            "lunar":"135.3249302609",
            "kilometers":"52041957.133494047",
            "miles":"32337372.6588579686"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1946-03-20",
         "close_approach_date_full":"1946-Mar-20 00:24",
         "epoch_date_close_approach":-750641760000,
         "relative_velocity":{
            "kilometers_per_second":"42.359027663",
            "kilometers_per_hour":"152492.4995866294",
            "miles_per_hour":"94752.9089792587"
         },
         "miss_distance":{
            "astronomical":"0.4721574131",
            "lunar":"183.6692336959",
            "kilometers":"70633743.304470097",
            "miles":"43889772.8935854586"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1946-04-11",
         "close_approach_date_full":"1946-Apr-11 05:33",
         "epoch_date_close_approach":-748722420000,
         "relative_velocity":{
            "kilometers_per_second":"42.7044026436",
            "kilometers_per_hour":"153735.8495168923",
            "miles_per_hour":"95525.4782734268"
         },
         "miss_distance":{
            "astronomical":"0.076976968",
            "lunar":"29.944040552",
            "kilometers":"11515590.45185816",
            "miles":"7155456.103876208"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1947-10-30",
         "close_approach_date_full":"1947-Oct-30 20:52",
         "epoch_date_close_approach":-699678480000,
         "relative_velocity":{
            "kilometers_per_second":"30.2029367719",
            "kilometers_per_hour":"108730.5723788353",
            "miles_per_hour":"67560.9492650602"
         },
         "miss_distance":{
            "astronomical":"0.0359541779",
            "lunar":"13.9861752031",
            "kilometers":"5378668.431441073",
            "miles":"3342149.5857618874"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1947-12-19",
         "close_approach_date_full":"1947-Dec-19 20:14",
         "epoch_date_close_approach":-695360760000,
         "relative_velocity":{
            "kilometers_per_second":"17.8202350245",
            "kilometers_per_hour":"64152.8460880974",
            "miles_per_hour":"39862.0837262403"
         },
         "miss_distance":{
            "astronomical":"0.3499645336",
            "lunar":"136.1362035704",
            "kilometers":"52353948.802103432",
            "miles":"32531235.2922020816"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1949-03-19",
         "close_approach_date_full":"1949-Mar-19 13:17",
         "epoch_date_close_approach":-655987380000,
         "relative_velocity":{
            "kilometers_per_second":"42.5141834582",
            "kilometers_per_hour":"153051.0604494206",
            "miles_per_hour":"95099.9769775858"
         },
         "miss_distance":{
            "astronomical":"0.4761752139",
            "lunar":"185.2321582071",
            "kilometers":"71234797.746234393",
            "miles":"44263250.8052969034"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1949-05-21",
         "close_approach_date_full":"1949-May-21 22:06",
         "epoch_date_close_approach":-650512440000,
         "relative_velocity":{
            "kilometers_per_second":"32.8260227261",
            "kilometers_per_hour":"118173.6818138689",
            "miles_per_hour":"73428.5302359565"
         },
         "miss_distance":{
            "astronomical":"0.0396636097",
            "lunar":"15.4291441733",
            "kilometers":"5933591.527631339",
            "miles":"3686962.8085329182"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1950-12-19",
         "close_approach_date_full":"1950-Dec-19 15:14",
         "epoch_date_close_approach":-600684360000,
         "relative_velocity":{
            "kilometers_per_second":"17.7945884059",
            "kilometers_per_hour":"64060.5182612969",
            "miles_per_hour":"39804.7148051931"
         },
         "miss_distance":{
            "astronomical":"0.3514025813",
            "lunar":"136.6956041257",
            "kilometers":"52569077.674981831",
            "miles":"32664910.1752220278"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1952-03-19",
         "close_approach_date_full":"1952-Mar-19 12:27",
         "epoch_date_close_approach":-561295980000,
         "relative_velocity":{
            "kilometers_per_second":"42.4192520769",
            "kilometers_per_hour":"152709.3074767345",
            "miles_per_hour":"94887.6249707521"
         },
         "miss_distance":{
            "astronomical":"0.4733661304",
            "lunar":"184.1394247256",
            "kilometers":"70814564.837982248",
            "miles":"44002130.1844331024"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1953-12-19",
         "close_approach_date_full":"1953-Dec-19 08:33",
         "epoch_date_close_approach":-506014020000,
         "relative_velocity":{
            "kilometers_per_second":"17.8175823835",
            "kilometers_per_hour":"64143.2965804412",
            "miles_per_hour":"39856.1500335525"
         },
         "miss_distance":{
            "astronomical":"0.3490878665",
            "lunar":"135.7951800685",
            "kilometers":"52222801.271244355",
            "miles":"32449743.995327899"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1955-03-20",
         "close_approach_date_full":"1955-Mar-20 06:00",
         "epoch_date_close_approach":-466624800000,
         "relative_velocity":{
            "kilometers_per_second":"42.4277881159",
            "kilometers_per_hour":"152740.0372172263",
            "miles_per_hour":"94906.7192364482"
         },
         "miss_distance":{
            "astronomical":"0.4733751131",
            "lunar":"184.1429189959",
            "kilometers":"70815908.630769097",
            "miles":"44002965.1785516586"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1956-12-19",
         "close_approach_date_full":"1956-Dec-19 04:48",
         "epoch_date_close_approach":-411333120000,
         "relative_velocity":{
            "kilometers_per_second":"17.8391259222",
            "kilometers_per_hour":"64220.8533200366",
            "miles_per_hour":"39904.3407754417"
         },
         "miss_distance":{
            "astronomical":"0.3484268685",
            "lunar":"135.5380518465",
            "kilometers":"52123917.378370095",
            "miles":"32388300.393473511"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1958-03-20",
         "close_approach_date_full":"1958-Mar-20 02:28",
         "epoch_date_close_approach":-371943120000,
         "relative_velocity":{
            "kilometers_per_second":"42.3914963078",
            "kilometers_per_hour":"152609.3867079644",
            "miles_per_hour":"94825.538090846"
         },
         "miss_distance":{
            "astronomical":"0.4727717668",
            "lunar":"183.9082172852",
            "kilometers":"70725649.309416716",
            "miles":"43946880.6369380408"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1958-03-27",
         "close_approach_date_full":"1958-Mar-27 13:04",
         "epoch_date_close_approach":-371300160000,
         "relative_velocity":{
            "kilometers_per_second":"26.9993517927",
            "kilometers_per_hour":"97197.6664537564",
            "miles_per_hour":"60394.8500251132"
         },
         "miss_distance":{
            "astronomical":"0.0816493201",
            "lunar":"31.7615855189",
            "kilometers":"12214564.373908187",
            "miles":"7589778.3592475006"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1959-10-11",
         "close_approach_date_full":"1959-Oct-11 15:31",
         "epoch_date_close_approach":-322648140000,
         "relative_velocity":{
            "kilometers_per_second":"31.6261146333",
            "kilometers_per_hour":"113854.0126797475",
            "miles_per_hour":"70744.4558231465"
         },
         "miss_distance":{
            "astronomical":"0.0426649467",
            "lunar":"16.5966642663",
            "kilometers":"6382585.149983529",
            "miles":"3965954.5084455402"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1959-12-19",
         "close_approach_date_full":"1959-Dec-19 22:08",
         "epoch_date_close_approach":-316662720000,
         "relative_velocity":{
            "kilometers_per_second":"17.8430166965",
            "kilometers_per_hour":"64234.8601072772",
            "miles_per_hour":"39913.0440483246"
         },
         "miss_distance":{
            "astronomical":"0.347650883",
            "lunar":"135.236193487",
            "kilometers":"52007831.60041921",
            "miles":"32316168.035876698"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1961-03-19",
         "close_approach_date_full":"1961-Mar-19 22:15",
         "epoch_date_close_approach":-277263900000,
         "relative_velocity":{
            "kilometers_per_second":"42.3270760481",
            "kilometers_per_hour":"152377.4737732086",
            "miles_per_hour":"94681.4364120251"
         },
         "miss_distance":{
            "astronomical":"0.4708603266",
            "lunar":"183.1646670474",
            "kilometers":"70439701.926864342",
            "miles":"43769201.1725262396"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1962-12-19",
         "close_approach_date_full":"1962-Dec-19 18:15",
         "epoch_date_close_approach":-221982300000,
         "relative_velocity":{
            "kilometers_per_second":"17.889573462",
            "kilometers_per_hour":"64402.4644633616",
            "miles_per_hour":"40017.1868772482"
         },
         "miss_distance":{
            "astronomical":"0.3459846702",
            "lunar":"134.5880367078",
            "kilometers":"51758569.714572474",
            "miles":"32161283.8820851812"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1964-03-19",
         "close_approach_date_full":"1964-Mar-19 18:18",
         "epoch_date_close_approach":-182583720000,
         "relative_velocity":{
            "kilometers_per_second":"42.2859387396",
            "kilometers_per_hour":"152229.3794627274",
            "miles_per_hour":"94589.4163667153"
         },
         "miss_distance":{
            "astronomical":"0.4700006764",
            "lunar":"182.8302631196",
            "kilometers":"70311100.087999268",
            "miles":"43689291.6953071784"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1965-12-19",
         "close_approach_date_full":"1965-Dec-19 12:13",
         "epoch_date_close_approach":-127309620000,
         "relative_velocity":{
            "kilometers_per_second":"17.865227574",
            "kilometers_per_hour":"64314.8192665616",
            "miles_per_hour":"39962.727560381"
         },
         "miss_distance":{
            "astronomical":"0.3470832669",
            "lunar":"135.0153908241",
            "kilometers":"51922917.440881503",
            "miles":"32263404.8238026214"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1967-03-20",
         "close_approach_date_full":"1967-Mar-20 09:13",
         "epoch_date_close_approach":-87922020000,
         "relative_velocity":{
            "kilometers_per_second":"42.3646758019",
            "kilometers_per_hour":"152512.832886808",
            "miles_per_hour":"94765.5433012502"
         },
         "miss_distance":{
            "astronomical":"0.4720846698",
            "lunar":"183.6409365522",
            "kilometers":"70622861.061733326",
            "miles":"43883010.9815028588"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1968-12-19",
         "close_approach_date_full":"1968-Dec-19 08:18",
         "epoch_date_close_approach":-32629320000,
         "relative_velocity":{
            "kilometers_per_second":"17.8452629251",
            "kilometers_per_hour":"64242.9465305022",
            "miles_per_hour":"39918.0686372445"
         },
         "miss_distance":{
            "astronomical":"0.3492524782",
            "lunar":"135.8592140198",
            "kilometers":"52247426.830941434",
            "miles":"32465045.6085784292"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1970-03-20",
         "close_approach_date_full":"1970-Mar-20 02:11",
         "epoch_date_close_approach":6747060000,
         "relative_velocity":{
            "kilometers_per_second":"42.4327644712",
            "kilometers_per_hour":"152757.9520961695",
            "miles_per_hour":"94917.8508455338"
         },
         "miss_distance":{
            "astronomical":"0.4744417199",
            "lunar":"184.5578290411",
            "kilometers":"70975470.736176613",
            "miles":"44102112.4733307394"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1971-12-20",
         "close_approach_date_full":"1971-Dec-20 01:46",
         "epoch_date_close_approach":62041560000,
         "relative_velocity":{
            "kilometers_per_second":"17.7564269647",
            "kilometers_per_hour":"63923.1370728869",
            "miles_per_hour":"39719.3514773169"
         },
         "miss_distance":{
            "astronomical":"0.3536815377",
            "lunar":"137.5821181653",
            "kilometers":"52910004.698244699",
            "miles":"32876752.4042228862"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1973-03-19",
         "close_approach_date_full":"1973-Mar-19 13:30",
         "epoch_date_close_approach":101395800000,
         "relative_velocity":{
            "kilometers_per_second":"42.6289084133",
            "kilometers_per_hour":"153464.0702879995",
            "miles_per_hour":"95356.605229785"
         },
         "miss_distance":{
            "astronomical":"0.4796662347",
            "lunar":"186.5901652983",
            "kilometers":"71757047.022040089",
            "miles":"44587761.4575236682"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1973-05-21",
         "close_approach_date_full":"1973-May-21 06:42",
         "epoch_date_close_approach":106814520000,
         "relative_velocity":{
            "kilometers_per_second":"35.3337459895",
            "kilometers_per_hour":"127201.4855620538",
            "miles_per_hour":"79038.0564038217"
         },
         "miss_distance":{
            "astronomical":"0.0899205439",
            "lunar":"34.9790915771",
            "kilometers":"13451921.836681493",
            "miles":"8358636.6341828834"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1974-12-19",
         "close_approach_date_full":"1974-Dec-19 21:07",
         "epoch_date_close_approach":156719220000,
         "relative_velocity":{
            "kilometers_per_second":"17.6663005944",
            "kilometers_per_hour":"63598.68213966",
            "miles_per_hour":"39517.7477995015"
         },
         "miss_distance":{
            "astronomical":"0.3590258691",
            "lunar":"139.6610630799",
            "kilometers":"53709505.292258817",
            "miles":"33373539.0370409946"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1976-03-19",
         "close_approach_date_full":"1976-Mar-19 05:00",
         "epoch_date_close_approach":196059600000,
         "relative_velocity":{
            "kilometers_per_second":"42.7470506319",
            "kilometers_per_hour":"153889.3822749487",
            "miles_per_hour":"95620.8775585647"
         },
         "miss_distance":{
            "astronomical":"0.4829808763",
            "lunar":"187.8795608807",
            "kilometers":"72252910.345213481",
            "miles":"44895876.6390527978"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1977-12-19",
         "close_approach_date_full":"1977-Dec-19 14:49",
         "epoch_date_close_approach":251390940000,
         "relative_velocity":{
            "kilometers_per_second":"17.5645224827",
            "kilometers_per_hour":"63232.2809376923",
            "miles_per_hour":"39290.0803415344"
         },
         "miss_distance":{
            "astronomical":"0.363887619",
            "lunar":"141.552283791",
            "kilometers":"54436812.72177153",
            "miles":"33825466.917565914"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1979-03-19",
         "close_approach_date_full":"1979-Mar-19 16:16",
         "epoch_date_close_approach":290708160000,
         "relative_velocity":{
            "kilometers_per_second":"42.9439942114",
            "kilometers_per_hour":"154598.3791611674",
            "miles_per_hour":"96061.4206515598"
         },
         "miss_distance":{
            "astronomical":"0.4880632922",
            "lunar":"189.8566206658",
            "kilometers":"73013228.938307614",
            "miles":"45368316.7054645132"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1979-04-10",
         "close_approach_date_full":"1979-Apr-10 12:47",
         "epoch_date_close_approach":292596420000,
         "relative_velocity":{
            "kilometers_per_second":"41.3620447119",
            "kilometers_per_hour":"148903.3609630031",
            "miles_per_hour":"92522.7578161504"
         },
         "miss_distance":{
            "astronomical":"0.064594167",
            "lunar":"25.127130963",
            "kilometers":"9663149.79762429",
            "miles":"6004402.856383602"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1980-10-29",
         "close_approach_date_full":"1980-Oct-29 14:12",
         "epoch_date_close_approach":341676720000,
         "relative_velocity":{
            "kilometers_per_second":"32.5849392422",
            "kilometers_per_hour":"117305.7812720107",
            "miles_per_hour":"72889.2505909335"
         },
         "miss_distance":{
            "astronomical":"0.018069773",
            "lunar":"7.029141697",
            "kilometers":"2703199.55218351",
            "miles":"1679690.313452038"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1980-12-19",
         "close_approach_date_full":"1980-Dec-19 11:11",
         "epoch_date_close_approach":346072260000,
         "relative_velocity":{
            "kilometers_per_second":"17.4808037484",
            "kilometers_per_hour":"62930.8934941054",
            "miles_per_hour":"39102.8099047123"
         },
         "miss_distance":{
            "astronomical":"0.3688528056",
            "lunar":"143.4837413784",
            "kilometers":"55179594.061284072",
            "miles":"34287009.8399093136"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1982-03-19",
         "close_approach_date_full":"1982-Mar-19 04:30",
         "epoch_date_close_approach":385360200000,
         "relative_velocity":{
            "kilometers_per_second":"43.1614211352",
            "kilometers_per_hour":"155381.1160866721",
            "miles_per_hour":"96547.7829372991"
         },
         "miss_distance":{
            "astronomical":"0.494660002",
            "lunar":"192.422740778",
            "kilometers":"74000082.67339574",
            "miles":"45981519.181871612"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1982-03-25",
         "close_approach_date_full":"1982-Mar-25 23:54",
         "epoch_date_close_approach":385948440000,
         "relative_velocity":{
            "kilometers_per_second":"25.7099953667",
            "kilometers_per_hour":"92555.9833202276",
            "miles_per_hour":"57510.6886358381"
         },
         "miss_distance":{
            "astronomical":"0.1085661286",
            "lunar":"42.2322240254",
            "kilometers":"16241261.592706082",
            "miles":"10091851.9883126516"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1983-12-20",
         "close_approach_date_full":"1983-Dec-20 06:03",
         "epoch_date_close_approach":440748180000,
         "relative_velocity":{
            "kilometers_per_second":"17.3282870309",
            "kilometers_per_hour":"62381.8333114096",
            "miles_per_hour":"38761.6452595256"
         },
         "miss_distance":{
            "astronomical":"0.3771719976",
            "lunar":"146.7199070664",
            "kilometers":"56424127.464605112",
            "miles":"35060327.0375380656"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1985-07-30",
         "close_approach_date_full":"1985-Jul-30 18:22",
         "epoch_date_close_approach":491595720000,
         "relative_velocity":{
            "kilometers_per_second":"17.4815469872",
            "kilometers_per_hour":"62933.5691538836",
            "miles_per_hour":"39104.4724556451"
         },
         "miss_distance":{
            "astronomical":"0.0377261799",
            "lunar":"14.6754839811",
            "kilometers":"5643756.156276813",
            "miles":"3506867.4599054994"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"1986-12-20",
         "close_approach_date_full":"1986-Dec-20 03:33",
         "epoch_date_close_approach":535433580000,
         "relative_velocity":{
            "kilometers_per_second":"17.2260861873",
            "kilometers_per_hour":"62013.9102742688",
            "miles_per_hour":"38533.0321923644"
         },
         "miss_distance":{
            "astronomical":"0.3840341356",
            "lunar":"149.3892787484",
            "kilometers":"57450688.693051172",
            "miles":"35698202.6062112936"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1989-12-20",
         "close_approach_date_full":"1989-Dec-20 00:53",
         "epoch_date_close_approach":630118380000,
         "relative_velocity":{
            "kilometers_per_second":"17.0803078306",
            "kilometers_per_hour":"61489.1081901179",
            "miles_per_hour":"38206.940586243"
         },
         "miss_distance":{
            "astronomical":"0.3937463592",
            "lunar":"153.1673337288",
            "kilometers":"58903616.656574904",
            "miles":"36601010.1790015152"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1992-10-07",
         "close_approach_date_full":"1992-Oct-07 10:05",
         "epoch_date_close_approach":718452300000,
         "relative_velocity":{
            "kilometers_per_second":"35.3369922406",
            "kilometers_per_hour":"127213.1720662644",
            "miles_per_hour":"79045.317943063"
         },
         "miss_distance":{
            "astronomical":"0.0261631041",
            "lunar":"10.1774474949",
            "kilometers":"3913944.645948267",
            "miles":"2432012.4290774046"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1992-12-20",
         "close_approach_date_full":"1992-Dec-20 00:43",
         "epoch_date_close_approach":724812180000,
         "relative_velocity":{
            "kilometers_per_second":"16.9728875785",
            "kilometers_per_hour":"61102.395282721",
            "miles_per_hour":"37966.6522244218"
         },
         "miss_distance":{
            "astronomical":"0.4030973021",
            "lunar":"156.8048505169",
            "kilometers":"60302497.796906527",
            "miles":"37470234.6131309926"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1993-02-03",
         "close_approach_date_full":"1993-Feb-03 18:59",
         "epoch_date_close_approach":728765940000,
         "relative_velocity":{
            "kilometers_per_second":"15.9408648785",
            "kilometers_per_hour":"57387.1135627181",
            "miles_per_hour":"35658.12064679"
         },
         "miss_distance":{
            "astronomical":"0.0757835237",
            "lunar":"29.4797907193",
            "kilometers":"11337053.726614519",
            "miles":"7044518.5270536022"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"1994-04-28",
         "close_approach_date_full":"1994-Apr-28 03:57",
         "epoch_date_close_approach":767505420000,
         "relative_velocity":{
            "kilometers_per_second":"42.3380165737",
            "kilometers_per_hour":"152416.859665397",
            "miles_per_hour":"94705.9092737574"
         },
         "miss_distance":{
            "astronomical":"0.0532145295",
            "lunar":"20.7004519755",
            "kilometers":"7960780.266252165",
            "miles":"4946599.480583277"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"1995-12-21",
         "close_approach_date_full":"1995-Dec-21 00:31",
         "epoch_date_close_approach":819505860000,
         "relative_velocity":{
            "kilometers_per_second":"16.8259053794",
            "kilometers_per_hour":"60573.2593656787",
            "miles_per_hour":"37637.8677430796"
         },
         "miss_distance":{
            "astronomical":"0.4155186256",
            "lunar":"161.6367453584",
            "kilometers":"62160701.335087472",
            "miles":"38624868.7506602336"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"1997-05-17",
         "close_approach_date_full":"1997-May-17 17:37",
         "epoch_date_close_approach":863890620000,
         "relative_velocity":{
            "kilometers_per_second":"34.19364",
            "kilometers_per_hour":"123097.1040000169",
            "miles_per_hour":"76487.7533160105"
         },
         "miss_distance":{
            "astronomical":"0.0669293673",
            "lunar":"26.0355238797",
            "kilometers":"10012490.788527651",
            "miles":"6221473.2824415438"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"1998-12-21",
         "close_approach_date_full":"1998-Dec-21 01:22",
         "epoch_date_close_approach":914203320000,
         "relative_velocity":{
            "kilometers_per_second":"16.7154445134",
            "kilometers_per_hour":"60175.600248407",
            "miles_per_hour":"37390.7778321283"
         },
         "miss_distance":{
            "astronomical":"0.4264652622",
            "lunar":"165.8949869958",
            "kilometers":"63798294.854111514",
            "miles":"39642422.1788023332"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2001-12-21",
         "close_approach_date_full":"2001-Dec-21 00:52",
         "epoch_date_close_approach":1008895920000,
         "relative_velocity":{
            "kilometers_per_second":"16.6061932279",
            "kilometers_per_hour":"59782.2956206168",
            "miles_per_hour":"37146.3936315993"
         },
         "miss_distance":{
            "astronomical":"0.4368143111",
            "lunar":"169.9207670179",
            "kilometers":"65346490.526077357",
            "miles":"40604426.3606352466"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2004-12-21",
         "close_approach_date_full":"2004-Dec-21 02:32",
         "epoch_date_close_approach":1103596320000,
         "relative_velocity":{
            "kilometers_per_second":"16.5226801218",
            "kilometers_per_hour":"59481.6484383569",
            "miles_per_hour":"36959.5831643779"
         },
         "miss_distance":{
            "astronomical":"0.4465534999",
            "lunar":"173.7093114611",
            "kilometers":"66803452.426085213",
            "miles":"41509740.5053254194"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2006-03-21",
         "close_approach_date_full":"2006-Mar-21 14:09",
         "epoch_date_close_approach":1142950140000,
         "relative_velocity":{
            "kilometers_per_second":"27.7511577707",
            "kilometers_per_hour":"99904.1679745146",
            "miles_per_hour":"62076.5648172755"
         },
         "miss_distance":{
            "astronomical":"0.0660608063",
            "lunar":"25.6976536507",
            "kilometers":"9882555.912962581",
            "miles":"6140735.4946263778"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2006-04-05",
         "close_approach_date_full":"2006-Apr-05 14:06",
         "epoch_date_close_approach":1144245960000,
         "relative_velocity":{
            "kilometers_per_second":"31.8466203555",
            "kilometers_per_hour":"114647.833279796",
            "miles_per_hour":"71237.7050732155"
         },
         "miss_distance":{
            "astronomical":"0.0410376176",
            "lunar":"15.9636332464",
            "kilometers":"6139140.182834512",
            "miles":"3814684.8203277856"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2007-12-22",
         "close_approach_date_full":"2007-Dec-22 03:10",
         "epoch_date_close_approach":1198293000000,
         "relative_velocity":{
            "kilometers_per_second":"16.4375191984",
            "kilometers_per_hour":"59175.0691143797",
            "miles_per_hour":"36769.0866949878"
         },
         "miss_distance":{
            "astronomical":"0.456616386",
            "lunar":"177.623774154",
            "kilometers":"68308838.75269782",
            "miles":"42445144.193437116"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2010-12-22",
         "close_approach_date_full":"2010-Dec-22 04:07",
         "epoch_date_close_approach":1292990820000,
         "relative_velocity":{
            "kilometers_per_second":"16.3935468677",
            "kilometers_per_hour":"59016.7687238341",
            "miles_per_hour":"36670.724988429"
         },
         "miss_distance":{
            "astronomical":"0.4634399212",
            "lunar":"180.2781293468",
            "kilometers":"69329625.084487844",
            "miles":"43079431.4077224872"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2013-12-22",
         "close_approach_date_full":"2013-Dec-22 07:09",
         "epoch_date_close_approach":1387696140000,
         "relative_velocity":{
            "kilometers_per_second":"16.3371322455",
            "kilometers_per_hour":"58813.6760837492",
            "miles_per_hour":"36544.5311199274"
         },
         "miss_distance":{
            "astronomical":"0.4736746138",
            "lunar":"184.2594247682",
            "kilometers":"70860713.297552606",
            "miles":"44030805.5075177228"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2016-12-22",
         "close_approach_date_full":"2016-Dec-22 11:24",
         "epoch_date_close_approach":1482405840000,
         "relative_velocity":{
            "kilometers_per_second":"16.3147766454",
            "kilometers_per_hour":"58733.1959234162",
            "miles_per_hour":"36494.5238780805"
         },
         "miss_distance":{
            "astronomical":"0.4827969491",
            "lunar":"187.8080131999",
            "kilometers":"72225395.227858417",
            "miles":"44878779.5379314746"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2019-10-04",
         "close_approach_date_full":"2019-Oct-04 01:36",
         "epoch_date_close_approach":1570152960000,
         "relative_velocity":{
            "kilometers_per_second":"27.8693617808",
            "kilometers_per_hour":"100329.7024108469",
            "miles_per_hour":"62340.9753674509"
         },
         "miss_distance":{
            "astronomical":"0.0777618188",
            "lunar":"30.2493475132",
            "kilometers":"11633002.459805956",
            "miles":"7228412.5425799528"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2019-12-23",
         "close_approach_date_full":"2019-Dec-23 16:54",
         "epoch_date_close_approach":1577120040000,
         "relative_velocity":{
            "kilometers_per_second":"16.2890378109",
            "kilometers_per_hour":"58640.5361191745",
            "miles_per_hour":"36436.9486791615"
         },
         "miss_distance":{
            "astronomical":"0.4945926382",
            "lunar":"192.3965362598",
            "kilometers":"73990005.192400634",
            "miles":"45975257.3255473892"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2021-05-13",
         "close_approach_date_full":"2021-May-13 08:55",
         "epoch_date_close_approach":1620896100000,
         "relative_velocity":{
            "kilometers_per_second":"32.0571041702",
            "kilometers_per_hour":"115405.5750127229",
            "miles_per_hour":"71708.5363183222"
         },
         "miss_distance":{
            "astronomical":"0.0243409506",
            "lunar":"9.4686297834",
            "kilometers":"3641354.363535222",
            "miles":"2262632.6818291836"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2022-12-23",
         "close_approach_date_full":"2022-Dec-23 16:05",
         "epoch_date_close_approach":1671811500000,
         "relative_velocity":{
            "kilometers_per_second":"16.2841170427",
            "kilometers_per_hour":"58622.8213537628",
            "miles_per_hour":"36425.9414128422"
         },
         "miss_distance":{
            "astronomical":"0.499320415",
            "lunar":"194.235641435",
            "kilometers":"74697270.53151605",
            "miles":"46414731.62857949"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2025-12-23",
         "close_approach_date_full":"2025-Dec-23 09:21",
         "epoch_date_close_approach":1766481660000,
         "relative_velocity":{
            "kilometers_per_second":"16.2790748948",
            "kilometers_per_hour":"58604.6696212307",
            "miles_per_hour":"36414.6626321475"
         },
         "miss_distance":{
            "astronomical":"0.4991579997",
            "lunar":"194.1724618833",
            "kilometers":"74672973.548580639",
            "miles":"46399634.1834612582"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2027-04-21",
         "close_approach_date_full":"2027-Apr-21 06:02",
         "epoch_date_close_approach":1808287320000,
         "relative_velocity":{
            "kilometers_per_second":"27.3025112457",
            "kilometers_per_hour":"98289.0404843814",
            "miles_per_hour":"61072.9874054202"
         },
         "miss_distance":{
            "astronomical":"0.0702810694",
            "lunar":"27.3393359966",
            "kilometers":"10513898.283562178",
            "miles":"6533033.4526189364"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2028-12-23",
         "close_approach_date_full":"2028-Dec-23 02:23",
         "epoch_date_close_approach":1861150980000,
         "relative_velocity":{
            "kilometers_per_second":"16.2773356012",
            "kilometers_per_hour":"58598.4081642314",
            "miles_per_hour":"36410.7720062693"
         },
         "miss_distance":{
            "astronomical":"0.4974803119",
            "lunar":"193.5198413291",
            "kilometers":"74421995.027175653",
            "miles":"46243683.3617958914"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2030-03-18",
         "close_approach_date_full":"2030-Mar-18 19:37",
         "epoch_date_close_approach":1900093020000,
         "relative_velocity":{
            "kilometers_per_second":"27.9154597328",
            "kilometers_per_hour":"100495.6550382506",
            "miles_per_hour":"62444.0918764063"
         },
         "miss_distance":{
            "astronomical":"0.0626412494",
            "lunar":"24.3674460166",
            "kilometers":"9370997.484378778",
            "miles":"5822867.8268240164"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2031-12-23",
         "close_approach_date_full":"2031-Dec-23 19:13",
         "epoch_date_close_approach":1955819580000,
         "relative_velocity":{
            "kilometers_per_second":"16.266661218",
            "kilometers_per_hour":"58559.9803848612",
            "miles_per_hour":"36386.8944785822"
         },
         "miss_distance":{
            "astronomical":"0.4973244553",
            "lunar":"193.4592131117",
            "kilometers":"74398679.211790211",
            "miles":"46229195.5859224718"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2034-12-23",
         "close_approach_date_full":"2034-Dec-23 10:27",
         "epoch_date_close_approach":2050482420000,
         "relative_velocity":{
            "kilometers_per_second":"16.2704931757",
            "kilometers_per_hour":"58573.7754324408",
            "miles_per_hour":"36395.4661846741"
         },
         "miss_distance":{
            "astronomical":"0.4934671054",
            "lunar":"191.9587040006",
            "kilometers":"73821627.882905498",
            "miles":"45870632.5169439524"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2037-12-23",
         "close_approach_date_full":"2037-Dec-23 04:44",
         "epoch_date_close_approach":2145156240000,
         "relative_velocity":{
            "kilometers_per_second":"16.2646653635",
            "kilometers_per_hour":"58552.7953086828",
            "miles_per_hour":"36382.4299516646"
         },
         "miss_distance":{
            "astronomical":"0.4934261173",
            "lunar":"191.9427596297",
            "kilometers":"73815496.150450151",
            "miles":"45866822.4350720438"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2039-04-03",
         "close_approach_date_full":"2039-Apr-03 07:38",
         "epoch_date_close_approach":2185429080000,
         "relative_velocity":{
            "kilometers_per_second":"33.7105319175",
            "kilometers_per_hour":"121357.9149030493",
            "miles_per_hour":"75407.0888462864"
         },
         "miss_distance":{
            "astronomical":"0.0296233388",
            "lunar":"11.5234787932",
            "kilometers":"4431588.386768356",
            "miles":"2753661.3345650728"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2040-10-22",
         "close_approach_date_full":"2040-Oct-22 05:32",
         "epoch_date_close_approach":2234496720000,
         "relative_velocity":{
            "kilometers_per_second":"47.8213495691",
            "kilometers_per_hour":"172156.8584488309",
            "miles_per_hour":"106971.5768511639"
         },
         "miss_distance":{
            "astronomical":"0.0903047245",
            "lunar":"35.1285378305",
            "kilometers":"13509394.436136815",
            "miles":"8394348.451505447"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2040-12-22",
         "close_approach_date_full":"2040-Dec-22 22:12",
         "epoch_date_close_approach":2239827120000,
         "relative_velocity":{
            "kilometers_per_second":"16.2727115559",
            "kilometers_per_hour":"58581.7616013725",
            "miles_per_hour":"36400.428479475"
         },
         "miss_distance":{
            "astronomical":"0.4911986612",
            "lunar":"191.0762792068",
            "kilometers":"73482273.462371644",
            "miles":"45659767.4579669272"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2043-12-23",
         "close_approach_date_full":"2043-Dec-23 17:56",
         "epoch_date_close_approach":2334506160000,
         "relative_velocity":{
            "kilometers_per_second":"16.2812915076",
            "kilometers_per_hour":"58612.6494273744",
            "miles_per_hour":"36419.6209733594"
         },
         "miss_distance":{
            "astronomical":"0.4919491496",
            "lunar":"191.3682191944",
            "kilometers":"73594544.928471352",
            "miles":"45729529.7120825776"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2045-05-13",
         "close_approach_date_full":"2045-May-13 08:09",
         "epoch_date_close_approach":2378275740000,
         "relative_velocity":{
            "kilometers_per_second":"35.3332343066",
            "kilometers_per_hour":"127199.6435039335",
            "miles_per_hour":"79036.9118205414"
         },
         "miss_distance":{
            "astronomical":"0.0897214106",
            "lunar":"34.9016287234",
            "kilometers":"13422131.919155422",
            "miles":"8340126.0377799436"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2046-12-23",
         "close_approach_date_full":"2046-Dec-23 12:49",
         "epoch_date_close_approach":2429182140000,
         "relative_velocity":{
            "kilometers_per_second":"16.2918842897",
            "kilometers_per_hour":"58650.7834429643",
            "miles_per_hour":"36443.3159676574"
         },
         "miss_distance":{
            "astronomical":"0.491472866",
            "lunar":"191.182944874",
            "kilometers":"73523293.91639542",
            "miles":"45685256.386159996"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2047-12-30",
         "close_approach_date_full":"2047-Dec-30 23:29",
         "epoch_date_close_approach":2461361340000,
         "relative_velocity":{
            "kilometers_per_second":"16.0914949905",
            "kilometers_per_hour":"57929.3819659519",
            "miles_per_hour":"35995.0651443438"
         },
         "miss_distance":{
            "astronomical":"0.0779289167",
            "lunar":"30.3143485963",
            "kilometers":"11657999.949727429",
            "miles":"7243945.2625553602"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"2049-12-23",
         "close_approach_date_full":"2049-Dec-23 07:22",
         "epoch_date_close_approach":2523856920000,
         "relative_velocity":{
            "kilometers_per_second":"16.2991511487",
            "kilometers_per_hour":"58676.9441354042",
            "miles_per_hour":"36459.5712045794"
         },
         "miss_distance":{
            "astronomical":"0.4919346423",
            "lunar":"191.3625758547",
            "kilometers":"73592374.667291901",
            "miles":"45728181.1743181938"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2052-12-23",
         "close_approach_date_full":"2052-Dec-23 00:06",
         "epoch_date_close_approach":2618525160000,
         "relative_velocity":{
            "kilometers_per_second":"16.3057345868",
            "kilometers_per_hour":"58700.6445123446",
            "miles_per_hour":"36474.2976971288"
         },
         "miss_distance":{
            "astronomical":"0.489824459",
            "lunar":"190.541714551",
            "kilometers":"73276695.74030233",
            "miles":"45532027.384858954"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2054-03-18",
         "close_approach_date_full":"2054-Mar-18 22:54",
         "epoch_date_close_approach":2657487240000,
         "relative_velocity":{
            "kilometers_per_second":"24.6821767531",
            "kilometers_per_hour":"88855.836311309",
            "miles_per_hour":"55211.561179102"
         },
         "miss_distance":{
            "astronomical":"0.1301647531",
            "lunar":"50.6340889559",
            "kilometers":"19472369.812835897",
            "miles":"12099569.5372014986"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2055-07-07",
         "close_approach_date_full":"2055-Jul-07 08:49",
         "epoch_date_close_approach":2698562940000,
         "relative_velocity":{
            "kilometers_per_second":"17.383597508",
            "kilometers_per_hour":"62580.9510286985",
            "miles_per_hour":"38885.3692655821"
         },
         "miss_distance":{
            "astronomical":"0.0367741073",
            "lunar":"14.3051277397",
            "kilometers":"5501328.123231451",
            "miles":"3418366.7840019838"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"2055-12-23",
         "close_approach_date_full":"2055-Dec-23 18:42",
         "epoch_date_close_approach":2713200120000,
         "relative_velocity":{
            "kilometers_per_second":"16.302163049",
            "kilometers_per_hour":"58687.7869764475",
            "miles_per_hour":"36466.3085243376"
         },
         "miss_distance":{
            "astronomical":"0.4908937575",
            "lunar":"190.9576716675",
            "kilometers":"73436660.518296525",
            "miles":"45631424.888781045"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2058-10-02",
         "close_approach_date_full":"2058-Oct-02 18:36",
         "epoch_date_close_approach":2800809360000,
         "relative_velocity":{
            "kilometers_per_second":"40.4729184489",
            "kilometers_per_hour":"145702.5064160256",
            "miles_per_hour":"90533.8712783355"
         },
         "miss_distance":{
            "astronomical":"0.0570898983",
            "lunar":"22.2079704387",
            "kilometers":"8540527.184196621",
            "miles":"5306837.5109345298"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2058-12-23",
         "close_approach_date_full":"2058-Dec-23 12:28",
         "epoch_date_close_approach":2807872080000,
         "relative_velocity":{
            "kilometers_per_second":"16.2942854237",
            "kilometers_per_hour":"58659.4275253722",
            "miles_per_hour":"36448.687064307"
         },
         "miss_distance":{
            "astronomical":"0.4902193683",
            "lunar":"190.6953342687",
            "kilometers":"73335773.330425521",
            "miles":"45568736.4971373498"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2060-04-22",
         "close_approach_date_full":"2060-Apr-22 19:01",
         "epoch_date_close_approach":2849886060000,
         "relative_velocity":{
            "kilometers_per_second":"33.6592208404",
            "kilometers_per_hour":"121173.1950255401",
            "miles_per_hour":"75292.3110979529"
         },
         "miss_distance":{
            "astronomical":"0.0108679276",
            "lunar":"4.2276238364",
            "kilometers":"1625818.820274212",
            "miles":"1010236.9696076456"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2061-12-23",
         "close_approach_date_full":"2061-Dec-23 12:15",
         "epoch_date_close_approach":2902565700000,
         "relative_velocity":{
            "kilometers_per_second":"16.2697712833",
            "kilometers_per_hour":"58571.1766200136",
            "miles_per_hour":"36393.8513836968"
         },
         "miss_distance":{
            "astronomical":"0.4962815981",
            "lunar":"193.0535416609",
            "kilometers":"74242669.995956047",
            "miles":"46132255.9543535686"
         },
         "orbiting_body":"Earth"
      },
      {
         "close_approach_date":"2067-09-19",
         "close_approach_date_full":"2067-Sep-19 12:47",
         "epoch_date_close_approach":3083662020000,
         "relative_velocity":{
            "kilometers_per_second":"37.8282738933",
            "kilometers_per_hour":"136181.786015966",
            "miles_per_hour":"84618.0658719762"
         },
         "miss_distance":{
            "astronomical":"0.139779251",
            "lunar":"54.374128639",
            "kilometers":"20910678.21979537",
            "miles":"12993292.938781306"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2069-05-11",
         "close_approach_date_full":"2069-May-11 18:35",
         "epoch_date_close_approach":3135522900000,
         "relative_velocity":{
            "kilometers_per_second":"36.6829792935",
            "kilometers_per_hour":"132058.7254564992",
            "miles_per_hour":"82056.1563815675"
         },
         "miss_distance":{
            "astronomical":"0.1166836181",
            "lunar":"45.3899274409",
            "kilometers":"17455620.731653447",
            "miles":"10846419.7674816886"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2072-03-31",
         "close_approach_date_full":"2072-Mar-31 17:38",
         "epoch_date_close_approach":3226671480000,
         "relative_velocity":{
            "kilometers_per_second":"34.4634287675",
            "kilometers_per_hour":"124068.343563063",
            "miles_per_hour":"77091.2438100599"
         },
         "miss_distance":{
            "astronomical":"0.0267642346",
            "lunar":"10.4112872594",
            "kilometers":"4003872.488340302",
            "miles":"2487890.9992160876"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2073-10-20",
         "close_approach_date_full":"2073-Oct-20 10:03",
         "epoch_date_close_approach":3275719380000,
         "relative_velocity":{
            "kilometers_per_second":"44.284387672",
            "kilometers_per_hour":"159423.7956193631",
            "miles_per_hour":"99059.7467835981"
         },
         "miss_distance":{
            "astronomical":"0.0660691611",
            "lunar":"25.7009036679",
            "kilometers":"9883805.773246857",
            "miles":"6141512.1217943466"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2078-03-15",
         "close_approach_date_full":"2078-Mar-15 21:12",
         "epoch_date_close_approach":3414604320000,
         "relative_velocity":{
            "kilometers_per_second":"25.1382224467",
            "kilometers_per_hour":"90497.6008081747",
            "miles_per_hour":"56231.6897910572"
         },
         "miss_distance":{
            "astronomical":"0.1207351958",
            "lunar":"46.9659911662",
            "kilometers":"18061728.125712946",
            "miles":"11223037.4381568148"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2085-09-28",
         "close_approach_date_full":"2085-Sep-28 13:38",
         "epoch_date_close_approach":3652522680000,
         "relative_velocity":{
            "kilometers_per_second":"30.1780383757",
            "kilometers_per_hour":"108640.93815243",
            "miles_per_hour":"67505.2540425474"
         },
         "miss_distance":{
            "astronomical":"0.055310069",
            "lunar":"21.515616841",
            "kilometers":"8274268.51195303",
            "miles":"5141392.043810614"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2093-05-07",
         "close_approach_date_full":"2093-May-07 08:08",
         "epoch_date_close_approach":3892522080000,
         "relative_velocity":{
            "kilometers_per_second":"34.4249937258",
            "kilometers_per_hour":"123929.977412921",
            "miles_per_hour":"77005.2684652675"
         },
         "miss_distance":{
            "astronomical":"0.0713069902",
            "lunar":"27.7384191878",
            "kilometers":"10667373.850030874",
            "miles":"6628398.7474751012"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2096-07-18",
         "close_approach_date_full":"2096-Jul-18 18:29",
         "epoch_date_close_approach":3993474540000,
         "relative_velocity":{
            "kilometers_per_second":"17.0493453752",
            "kilometers_per_hour":"61377.6433505972",
            "miles_per_hour":"38137.6806697086"
         },
         "miss_distance":{
            "astronomical":"0.0140390764",
            "lunar":"5.4612007196",
            "kilometers":"2100215.926207268",
            "miles":"1305013.6622575784"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"2099-03-29",
         "close_approach_date_full":"2099-Mar-29 06:32",
         "epoch_date_close_approach":4078449120000,
         "relative_velocity":{
            "kilometers_per_second":"26.9630348748",
            "kilometers_per_hour":"97066.9255493408",
            "miles_per_hour":"60313.6127114779"
         },
         "miss_distance":{
            "astronomical":"0.0895793867",
            "lunar":"34.8463814263",
            "kilometers":"13400885.446226329",
            "miles":"8326924.0916841802"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2102-03-12",
         "close_approach_date_full":"2102-Mar-12 09:56",
         "epoch_date_close_approach":4171600560000,
         "relative_velocity":{
            "kilometers_per_second":"27.249862116",
            "kilometers_per_hour":"98099.5036177696",
            "miles_per_hour":"60955.2165673858"
         },
         "miss_distance":{
            "astronomical":"0.0766739271",
            "lunar":"29.8261576419",
            "kilometers":"11470256.178695277",
            "miles":"7127286.6927657426"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2106-10-13",
         "close_approach_date_full":"2106-Oct-13 14:21",
         "epoch_date_close_approach":4316422860000,
         "relative_velocity":{
            "kilometers_per_second":"27.1596947913",
            "kilometers_per_hour":"97774.9012485979",
            "miles_per_hour":"60753.521278608"
         },
         "miss_distance":{
            "astronomical":"0.0752258195",
            "lunar":"29.2628437855",
            "kilometers":"11253622.366204465",
            "miles":"6992676.683633017"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2117-05-04",
         "close_approach_date_full":"2117-May-04 17:04",
         "epoch_date_close_approach":4649591040000,
         "relative_velocity":{
            "kilometers_per_second":"33.2021391729",
            "kilometers_per_hour":"119527.701022404",
            "miles_per_hour":"74269.8651158376"
         },
         "miss_distance":{
            "astronomical":"0.0467662441",
            "lunar":"18.1920689549",
            "kilometers":"6996130.505260067",
            "miles":"4347193.9139082446"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2118-09-23",
         "close_approach_date_full":"2118-Sep-23 07:31",
         "epoch_date_close_approach":4693361460000,
         "relative_velocity":{
            "kilometers_per_second":"40.0456490219",
            "kilometers_per_hour":"144164.3364787507",
            "miles_per_hour":"89578.1122970326"
         },
         "miss_distance":{
            "astronomical":"0.0534979082",
            "lunar":"20.8106862898",
            "kilometers":"8003173.116175534",
            "miles":"4972941.1760450092"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2120-04-13",
         "close_approach_date_full":"2120-Apr-13 08:26",
         "epoch_date_close_approach":4742439960000,
         "relative_velocity":{
            "kilometers_per_second":"34.3213798977",
            "kilometers_per_hour":"123556.967631864",
            "miles_per_hour":"76773.4946932546"
         },
         "miss_distance":{
            "astronomical":"0.0075851052",
            "lunar":"2.9506059228",
            "kilometers":"1134715.581645924",
            "miles":"705079.5674607912"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2126-03-09",
         "close_approach_date_full":"2126-Mar-09 06:04",
         "epoch_date_close_approach":4928709840000,
         "relative_velocity":{
            "kilometers_per_second":"27.8538309273",
            "kilometers_per_hour":"100273.791338123",
            "miles_per_hour":"62306.2344011798"
         },
         "miss_distance":{
            "astronomical":"0.0641894644",
            "lunar":"24.9697016516",
            "kilometers":"9602607.150680828",
            "miles":"5966783.4000103064"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2132-03-23",
         "close_approach_date_full":"2132-Mar-23 09:34",
         "epoch_date_close_approach":5119320840000,
         "relative_velocity":{
            "kilometers_per_second":"32.0884188555",
            "kilometers_per_hour":"115518.3078798965",
            "miles_per_hour":"71778.5841379279"
         },
         "miss_distance":{
            "astronomical":"0.0393344643",
            "lunar":"15.3011066127",
            "kilometers":"5884352.076871041",
            "miles":"3656366.8325847258"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2141-05-02",
         "close_approach_date_full":"2141-May-02 15:48",
         "epoch_date_close_approach":5406796080000,
         "relative_velocity":{
            "kilometers_per_second":"33.9518080945",
            "kilometers_per_hour":"122226.5091403253",
            "miles_per_hour":"75946.7995266649"
         },
         "miss_distance":{
            "astronomical":"0.0618145288",
            "lunar":"24.0458517032",
            "kilometers":"9247321.843533656",
            "miles":"5746019.3471142128"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2150-03-07",
         "close_approach_date_full":"2150-Mar-07 22:29",
         "epoch_date_close_approach":5685978540000,
         "relative_velocity":{
            "kilometers_per_second":"26.2896586995",
            "kilometers_per_hour":"94642.7713181557",
            "miles_per_hour":"58807.337544884"
         },
         "miss_distance":{
            "astronomical":"0.0967883749",
            "lunar":"37.6506778361",
            "kilometers":"14479334.725801463",
            "miles":"8997041.4002596694"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2151-09-21",
         "close_approach_date_full":"2151-Sep-21 17:50",
         "epoch_date_close_approach":5734605000000,
         "relative_velocity":{
            "kilometers_per_second":"40.9389399204",
            "kilometers_per_hour":"147380.1837133752",
            "miles_per_hour":"91576.3147079025"
         },
         "miss_distance":{
            "astronomical":"0.0607344298",
            "lunar":"23.6256931922",
            "kilometers":"9085741.333744526",
            "miles":"5645617.8740094188"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2153-04-12",
         "close_approach_date_full":"2153-Apr-12 00:20",
         "epoch_date_close_approach":5783703600000,
         "relative_velocity":{
            "kilometers_per_second":"33.810947686",
            "kilometers_per_hour":"121719.4116695096",
            "miles_per_hour":"75631.7088787573"
         },
         "miss_distance":{
            "astronomical":"0.0101712427",
            "lunar":"3.9566134103",
            "kilometers":"1521596.243173049",
            "miles":"945476.0632001162"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2158-12-20",
         "close_approach_date_full":"2158-Dec-20 12:45",
         "epoch_date_close_approach":5963287500000,
         "relative_velocity":{
            "kilometers_per_second":"16.313111993",
            "kilometers_per_hour":"58727.2031747834",
            "miles_per_hour":"36490.8002171314"
         },
         "miss_distance":{
            "astronomical":"0.063905315",
            "lunar":"24.859167535",
            "kilometers":"9560099.00567905",
            "miles":"5940370.06350889"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"2165-03-22",
         "close_approach_date_full":"2165-Mar-22 11:49",
         "epoch_date_close_approach":6160621740000,
         "relative_velocity":{
            "kilometers_per_second":"31.6046271338",
            "kilometers_per_hour":"113776.6576815209",
            "miles_per_hour":"70696.3904354983"
         },
         "miss_distance":{
            "astronomical":"0.0431329446",
            "lunar":"16.7787154494",
            "kilometers":"6452596.638988002",
            "miles":"4009457.6304463476"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2165-05-01",
         "close_approach_date_full":"2165-May-01 13:43",
         "epoch_date_close_approach":6164084580000,
         "relative_velocity":{
            "kilometers_per_second":"35.9234716208",
            "kilometers_per_hour":"129324.4978349387",
            "miles_per_hour":"80357.213668604"
         },
         "miss_distance":{
            "astronomical":"0.1015160515",
            "lunar":"39.4897440335",
            "kilometers":"15186585.075210305",
            "miles":"9436506.389120009"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2166-06-26",
         "close_approach_date_full":"2166-Jun-26 12:32",
         "epoch_date_close_approach":6200454720000,
         "relative_velocity":{
            "kilometers_per_second":"17.7346074305",
            "kilometers_per_hour":"63844.5867499714",
            "miles_per_hour":"39670.5433613919"
         },
         "miss_distance":{
            "astronomical":"0.0540162392",
            "lunar":"21.0123170488",
            "kilometers":"8080714.329730504",
            "miles":"5021123.0519247952"
         },
         "orbiting_body":"Mars"
      },
      {
         "close_approach_date":"2174-03-06",
         "close_approach_date_full":"2174-Mar-06 13:42",
         "epoch_date_close_approach":6443242920000,
         "relative_velocity":{
            "kilometers_per_second":"24.8158705891",
            "kilometers_per_hour":"89337.1341207823",
            "miles_per_hour":"55510.6209207717"
         },
         "miss_distance":{
            "astronomical":"0.1276461581",
            "lunar":"49.6543555009",
            "kilometers":"19095593.365443247",
            "miles":"11865451.5089889286"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2184-09-19",
         "close_approach_date_full":"2184-Sep-19 00:01",
         "epoch_date_close_approach":6775833660000,
         "relative_velocity":{
            "kilometers_per_second":"42.3342808799",
            "kilometers_per_hour":"152403.4111677354",
            "miles_per_hour":"94697.5529003076"
         },
         "miss_distance":{
            "astronomical":"0.0730429905",
            "lunar":"28.4137233045",
            "kilometers":"10927075.797230235",
            "miles":"6789770.054577843"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2186-04-09",
         "close_approach_date_full":"2186-Apr-09 14:25",
         "epoch_date_close_approach":6824874300000,
         "relative_velocity":{
            "kilometers_per_second":"30.3598057068",
            "kilometers_per_hour":"109295.300544327",
            "miles_per_hour":"67911.8493854459"
         },
         "miss_distance":{
            "astronomical":"0.0351846815",
            "lunar":"13.6868411035",
            "kilometers":"5263553.409028405",
            "miles":"3270620.427685789"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2187-09-07",
         "close_approach_date_full":"2187-Sep-07 02:31",
         "epoch_date_close_approach":6869413860000,
         "relative_velocity":{
            "kilometers_per_second":"38.0546327068",
            "kilometers_per_hour":"136996.6777444674",
            "miles_per_hour":"85124.4079018331"
         },
         "miss_distance":{
            "astronomical":"0.1441107247",
            "lunar":"56.0590719083",
            "kilometers":"21558657.459276389",
            "miles":"13395928.5677326082"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2189-04-29",
         "close_approach_date_full":"2189-Apr-29 09:07",
         "epoch_date_close_approach":6921277620000,
         "relative_velocity":{
            "kilometers_per_second":"36.490318766",
            "kilometers_per_hour":"131365.1475576943",
            "miles_per_hour":"81625.194047724"
         },
         "miss_distance":{
            "astronomical":"0.1128548087",
            "lunar":"43.9005205843",
            "kilometers":"16882839.000777469",
            "miles":"10490509.7036843122"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2198-03-03",
         "close_approach_date_full":"2198-Mar-03 18:16",
         "epoch_date_close_approach":7200382560000,
         "relative_velocity":{
            "kilometers_per_second":"24.9879301676",
            "kilometers_per_hour":"89956.5486035249",
            "miles_per_hour":"55895.5009920069"
         },
         "miss_distance":{
            "astronomical":"0.1241451419",
            "lunar":"48.2924601991",
            "kilometers":"18571848.799087753",
            "miles":"11540011.7262988714"
         },
         "orbiting_body":"Venus"
      },
      {
         "close_approach_date":"2198-03-18",
         "close_approach_date_full":"2198-Mar-18 20:14",
         "epoch_date_close_approach":7201685640000,
         "relative_velocity":{
            "kilometers_per_second":"36.2023203764",
            "kilometers_per_hour":"130328.3533550573",
            "miles_per_hour":"80980.9704499799"
         },
         "miss_distance":{
            "astronomical":"0.0275282474",
            "lunar":"10.7084882386",
            "kilometers":"4118167.175873038",
            "miles":"2558910.4248344044"
         },
         "orbiting_body":"Merc"
      },
      {
         "close_approach_date":"2199-10-07",
         "close_approach_date_full":"2199-Oct-07 21:50",
         "epoch_date_close_approach":7250766600000,
         "relative_velocity":{
            "kilometers_per_second":"41.6929713695",
            "kilometers_per_hour":"150094.6969300546",
            "miles_per_hour":"93263.0076563442"
         },
         "miss_distance":{
            "astronomical":"0.0481853257",
            "lunar":"18.7440916973",
            "kilometers":"7208422.089976259",
            "miles":"4479105.7878160142"
         },
         "orbiting_body":"Merc"
      }
   ],
   "orbital_data":{
      "orbit_id":"33",
      "orbit_determination_date":"2021-04-14 10:54:00",
      "first_observation_date":"1996-01-12",
      "last_observation_date":"2020-01-24",
      "data_arc_in_days":8778,
      "observations_used":104,
      "orbit_uncertainty":"0",
      "minimum_orbit_intersection":".00485783",
      "jupiter_tisserand_invariant":"4.596",
      "epoch_osculation":"2460000.5",
      "eccentricity":".7815194696566876",
      "semi_major_axis":"1.310369832543624",
      "inclination":"2.539640396087575",
      "ascending_node_longitude":"90.94551424797716",
      "orbital_period":"547.8848052624642",
      "perihelion_distance":".2862902959600085",
      "perihelion_argument":"238.3328396738608",
      "aphelion_distance":"2.33444936912724",
      "perihelion_time":"2459868.396339320817",
      "mean_anomaly":"86.80167324903887",
      "mean_motion":".6570724293540903",
      "equinox":"J2000",
      "orbit_class":{
         "orbit_class_type":"APO",
         "orbit_class_description":"Near-Earth asteroid orbits which cross the Earth’s orbit similar to that of 1862 Apollo",
         "orbit_class_range":"a (semi-major axis) > 1.0 AU; q (perihelion) < 1.017 AU"
      }
   },
   "is_sentry_object":false
}
