import 'package:flutter/material.dart';
import 'package:nasa_apis/nasa_apis.dart';
import 'package:tuple/tuple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA Open APIs Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NASA APIs Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _widgetNasaApod = "APOD";
  static const String _widgetNasaMarsRover = "MARS ROVER";

  String _selected = _widgetNasaApod;
  String _selectedRover = NasaMarsRover.roverCuriosity;
  String _testDescription = "The parameters of the request will appear here.";
  List<ApodItem> _apodTestResults = <ApodItem>[];
  MarsRoverManifest? _manifest;
  List<MarsRoverPhotoItem>? _marsRoverPhotoItems;
  DateTime _marsRoverAvailablePhotosDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  /// The async initialization
  void init() async {
    await Nasa.init(
      logReceiver: (String msg, String name) {
        // ignore: avoid_print
        print("$name: $msg");
      },
    );
    await NasaApod.init(
      cacheSupport: true,
      cacheExpiration: const Duration(seconds: 20),
    );

    await NasaMarsRover.init(
      cacheSupport: true,
      cacheExpiration: const Duration(minutes: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    // Add the dropdown
    widgets.add(
      DropdownButton<String>(
        hint: Text(_selected),
        items: <String>[
          _widgetNasaApod,
          _widgetNasaMarsRover,
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              _selected = value;
            });
          }
        },
      ),
    );
    // If APOD is selected, add the APOD specific content
    if (_selected == _widgetNasaApod) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                _apodTestResults.clear();
                DateTime date = DateTime.now();
                Tuple2<int, ApodItem?> result =
                    await NasaApod.requestByDate(date);
                _testDescription =
                    "requestByDate()\ndate[${date.toString()}]\nhttp response code: ${result.item1.toString()}";
                if (result.item2 != null) {
                  _apodTestResults.add(result.item2!);
                }
                setState(() {});
              },
              child: const Text("requestByDate"),
            ),
            TextButton(
              onPressed: () async {
                _apodTestResults.clear();
                Tuple2<int, List<ApodItem>?> result =
                    await NasaApod.requestByMonth(1997, 3);
                _testDescription =
                    "requestByRange()\nMarch 1997\nhttp response code: ${result.item1.toString()}";
                if (result.item2 != null) {
                  _apodTestResults = result.item2!;
                }
                setState(() {});
              },
              child: const Text("requestByMonth"),
            ),
            TextButton(
              onPressed: () async {
                _apodTestResults.clear();
                Tuple2<int, List<ApodItem>?> result =
                    await NasaApod.requestByRandom(5);
                _testDescription =
                    "requestByRandom()\ncount[5]\nhttp response code: ${result.item1.toString()}";
                if (result.item2 != null) {
                  _apodTestResults = result.item2!;
                }
                setState(() {});
              },
              child: const Text("requestByRandom"),
            ),
            TextButton(
              onPressed: () async {
                _apodTestResults.clear();
                DateTime startDate = DateTime(2017, 10, 31);
                DateTime endDate = DateTime(2017, 11, 4);
                Tuple2<int, List<ApodItem>?> result =
                    await NasaApod.requestByRange(startDate, endDate);
                _testDescription =
                    "requestByRange()\n$startDate - $endDate\nhttp response code: ${result.item1.toString()}";
                if (result.item2 != null) {
                  _apodTestResults = result.item2!;
                }
                setState(() {});
              },
              child: const Text("requestByRange"),
            ),
            TextButton(
              onPressed: () async {
                _apodTestResults.clear();
                // Force a caching of the date
                DateTime date = DateTime(2017, 10, 31);
                Tuple2<int, ApodItem?> result =
                    await NasaApod.requestByDate(date);
                _testDescription =
                    "getCategory() and updateItemCache()\n$date being used.";
                if (result.item2 != null) {
                  ApodItem item = result.item2!;
                  String category = "favorite";
                  if (item.categories.contains(category)) {
                    item.categories.remove(category);
                    _testDescription +=
                        "'$category' was removed. Results should be empty.";
                  } else {
                    item.categories.add(category);
                    _testDescription +=
                        "'$category' was added. Results should show it.";
                  }
                  // Update the cache with the change
                  await NasaApod.updateItemCache(apodItem: item);
                  // Query the category
                  _apodTestResults =
                      await NasaApod.getCategory(category: category);
                }
                _testDescription +=
                    "\nhttp response code: ${result.item1.toString()}";
                setState(() {});
              },
              child: const Text("Category 'favorite' Update"),
            ),
          ],
        ),
      );
      widgets.add(Text(_testDescription));
      for (ApodItem apodItem in _apodTestResults) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              apodItem.toString(),
            ),
          ),
        );
      }
    }
    if (_selected == _widgetNasaMarsRover) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              hint: Text(_selectedRover),
              items: <String>[
                NasaMarsRover.roverSpirit,
                NasaMarsRover.roverOpportunity,
                NasaMarsRover.roverCuriosity,
                NasaMarsRover.roverPerseverance
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedRover = value;
                  });
                }
              },
            ),
            TextButton(
              onPressed: () async {
                _manifest = null;
                Tuple2<int, MarsRoverManifest?> result =
                    await NasaMarsRover.requestManifest(_selectedRover);
                _testDescription =
                    "requestManifest()\nRover[${_selectedRover.toString()}]\nhttp response code: ${result.item1.toString()}";
                _manifest = result.item2;
                setState(() {});
              },
              child: const Text("requestManifest"),
            ),
            TextButton(
              onPressed: () async {
                _manifest = null;
                Tuple2<int, List<MarsRoverPhotoItem>?> result =
                    await NasaMarsRover.requestByMartianSol(_selectedRover, 15);
                _testDescription =
                    "requestByMartianSol()\nRover[${_selectedRover.toString()}]\nsol: 15\nhttp response code: ${result.item1.toString()}";
                _marsRoverPhotoItems = result.item2;
                setState(() {});
              },
              child: const Text("requestByMartianSol"),
            ),
            TextButton(
              onPressed: () async {
                _manifest = null;
                Tuple2<int, List<MarsRoverPhotoItem>?> result =
                    await NasaMarsRover.requestByEarthDate(
                        [_selectedRover], _marsRoverAvailablePhotosDate);
                _testDescription =
                    "requestByEarthDate()\nRover[${_selectedRover.toString()}]\nEarth Date: $_marsRoverAvailablePhotosDate\nhttp response code: ${result.item1.toString()}";
                _marsRoverPhotoItems = result.item2;
                setState(() {});
              },
              child: const Text("requestByEarthDate"),
            ),
            TextButton(
              onPressed: () async {
                _manifest = null;
                Tuple2<int, DateTime?> result =
                    await NasaMarsRover.getPreviousDayWithPhotos(
                        _marsRoverAvailablePhotosDate,
                        rovers: [_selectedRover]);
                if (result.item2 != null) {
                  _marsRoverAvailablePhotosDate = result.item2!;
                }
                _testDescription =
                    "getPreviousDayWithPhotos()\nRover[${_selectedRover.toString()}]\nNew Date: $_marsRoverAvailablePhotosDate\nhttp response code: ${result.item1.toString()}";
                setState(() {});
              },
              child: const Text("Backward"),
            ),
            TextButton(
              onPressed: () async {
                _manifest = null;
                Tuple2<int, DateTime?> result =
                    await NasaMarsRover.getNextDayWithPhotos(
                        _marsRoverAvailablePhotosDate,
                        rovers: [_selectedRover]);
                if (result.item2 != null) {
                  _marsRoverAvailablePhotosDate = result.item2!;
                }
                _testDescription =
                    "getNextDayWithPhotos()\nRover[${_selectedRover.toString()}]\nNew Date: $_marsRoverAvailablePhotosDate\nhttp response code: ${result.item1.toString()}";
                setState(() {});
              },
              child: const Text("Forward"),
            ),
            TextButton(
              onPressed: () async {
                _manifest = null;
                Tuple2<int, Tuple2<DateTime, DateTime>?> result =
                    await NasaMarsRover.getValidPhotoRange(
                        rovers: [_selectedRover]);
                if (result.item2 != null) {
                  _testDescription = "getValidPhotoRange()\n";
                  _testDescription += "Rover[${_selectedRover.toString()}]\n";
                  _testDescription += "Start Date: ${result.item2!.item1}\n";
                  _testDescription += "End Date: ${result.item2!.item2}\n";
                  _testDescription +=
                      "http response code: ${result.item1.toString()}";
                }
                setState(() {});
              },
              child: const Text("Photo Date Range"),
            ),
          ],
        ),
      );
      widgets.add(Text(_testDescription));
      if (_manifest != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              _manifest.toString(),
            ),
          ),
        );
        if (_manifest!.dayInfoItems != null) {
          for (MarsRoverDayInfoItem dayInfoItem in _manifest!.dayInfoItems!) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  dayInfoItem.toString(),
                ),
              ),
            );
          }
          _manifest = null;
        }
      }
      if (_marsRoverPhotoItems != null) {
        for (MarsRoverPhotoItem marsRoverPhotoItem in _marsRoverPhotoItems!) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                marsRoverPhotoItem.toString(),
              ),
            ),
          );
        }
        _marsRoverPhotoItems = null;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: widgets,
        ),
      ),
    );
  }
}
