// Copyright (C) 2022 by Voidari LLC or its subsidiaries.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nasa_apis/nasa_apis.dart';
import 'package:nasa_apis/src/log.dart';
import 'package:tuple/tuple.dart';

String? getApiKey() {
  return null; // Add your API key here
}

void main() async {
  bool logReceived = false;
  const String testMessage = "This is a test log message";
  await Nasa.init(
      apiKey: getApiKey(),
      apodSupport: true,
      apodCacheSupport: false,
      marsRoverSupport: true,
      marsRoverCacheSupport: false,
      logReceiver: (String msg, String name) {
        if (msg == testMessage) {
          logReceived = true;
        }
      });
  test('verifies the logging function works', () async {
    Log.out(testMessage);
    expect(logReceived, true);
    Log.setLogFunction((String msg, String name) {});
  });

  test('APOD requests', () async {
    // Request by date
    Tuple2<int, ApodItem?> itemPair =
        await NasaApod.requestByDate(DateTime(2015, 11, 8));
    expect(itemPair.item1, HttpStatus.ok);
    expect(itemPair.item2, isNot(null));
    expect(itemPair.item2?.title, "A Quadruple Sky Over Great Salt Lake");
    // Request by month
    Tuple2<int, List<ApodItem>?> itemsPair =
        await NasaApod.requestByMonth(2012, 10);
    expect(itemsPair.item1, HttpStatus.ok);
    expect(itemsPair.item2?.length, 31);
    // Request by random
    const int count = 7;
    itemsPair = await NasaApod.requestByRandom(count);
    expect(itemsPair.item1, HttpStatus.ok);
    expect(itemsPair.item2?.length, count);
  });

  test('Mars Rover requests', () async {
    // Request a manifest
    Tuple2<int, MarsRoverManifest?> manifestItemPair =
        await NasaMarsRover.requestManifest(NasaMarsRover.roverPerseverance);
    expect(manifestItemPair.item1, HttpStatus.ok);
    expect(manifestItemPair.item2, isNot(null));
    expect(manifestItemPair.item2!.name, NasaMarsRover.roverPerseverance);
    // Request photos for the earth date
    Tuple2<int, List<MarsRoverPhotoItem>?> earthDayInfoItemsPair =
        await NasaMarsRover.requestByEarthDate(
            NasaMarsRover.roverPerseverance, DateTime(2023, 1, 15));
    expect(earthDayInfoItemsPair.item1, HttpStatus.ok);
    expect(earthDayInfoItemsPair.item2, isNot(null));
    expect(earthDayInfoItemsPair.item2![0].id, 1085674);
    // Request photos for the martian sol
    Tuple2<int, List<MarsRoverPhotoItem>?> martianSolInfoItemsPair =
        await NasaMarsRover.requestByMartianSol(
            NasaMarsRover.roverPerseverance, 15);
    expect(martianSolInfoItemsPair.item1, HttpStatus.ok);
    expect(martianSolInfoItemsPair.item2, isNot(null));
    expect(martianSolInfoItemsPair.item2![0].id, 813597);
  });
}
