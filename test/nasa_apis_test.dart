// Copyright (C) 2022 by Voidari LLC or its subsidiaries.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nasa_apis/nasa_apis.dart';
import 'package:nasa_apis/src/log.dart';
import 'package:tuple/tuple.dart';

String? getApiKey() {
  return null; // Add your API key here
}

void main() {
  bool logReceived = false;
  test('verifies the logging function works', () {
    const String testMessage = "This is a test log message";
    Nasa.init(
        apiKey: getApiKey(),
        logReceiver: (String msg, String name) {
          logReceived = true;
          expect(msg, testMessage);
        });
    Log.out(testMessage);
    expect(logReceived, true);
    Log.setLogFunction((String msg, String name) {});
  });

  test('APOD requests', () async {
    // Request by date
    Tuple2<int, ApodItem?> itemPair =
        await NasaApod.requestByDate(DateTime(2005, 9, 13));
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
}
