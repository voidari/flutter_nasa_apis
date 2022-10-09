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

  String _selected = _widgetNasaApod;
  String _apodTestDescription =
      "The parameters of the request will appear here.";
  List<ApodItem> _apodTestResults = <ApodItem>[];

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
        apodSupport: true,
        apodCacheSupport: true,
        apodDefaultCacheExpiration: const Duration(seconds: 20));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    // Add the dropdown
    widgets.add(
      DropdownButton<String>(
        hint: Text(_selected),
        items: <String>[_widgetNasaApod].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            _selected = value;
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
                _apodTestDescription =
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
                _apodTestDescription =
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
                DateTime date = DateTime.now();
                Tuple2<int, List<ApodItem>?> result =
                    await NasaApod.requestByRandom(5);
                _apodTestDescription =
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
                _apodTestDescription =
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
                _apodTestDescription =
                    "getCategory() and updateItemCache()\n$date being used.";
                if (result.item2 != null) {
                  ApodItem item = result.item2!;
                  String category = "favorite";
                  if (item.categories.contains(category)) {
                    item.categories.remove(category);
                    _apodTestDescription +=
                        "'$category' was removed. Results should be empty.";
                  } else {
                    item.categories.add(category);
                    _apodTestDescription +=
                        "'$category' was added. Results should show it.";
                  }
                  // Update the cache with the change
                  await NasaApod.updateItemCache(apodItem: item);
                  // Query the category
                  _apodTestResults =
                      await NasaApod.getCategory(category: category);
                }
                _apodTestDescription +=
                    "\nhttp response code: ${result.item1.toString()}";
                setState(() {});
              },
              child: const Text("Category 'favorite' Update"),
            ),
          ],
        ),
      );
      widgets.add(Text(_apodTestDescription));
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
