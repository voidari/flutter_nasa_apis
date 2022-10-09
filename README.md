# NASA APIs

[![pub package](https://img.shields.io/pub/v/nasa_apis.svg)](https://pub.dev/packages/nasa_apis)
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

A wrapper for the NASA Open APIs. Provides an easy dart-specific way of working with the requests available and provides parsed responses, including configurable caching and management of data.

For information on NASA's APIs, see the documentation on [NASA Open APIs](https://api.nasa.gov/).

This wrapper is not affiliated with NASA or their APIs in any capacity. It was created for our own usage and made public to support the open-source community.

## Prerequisites

NASA recommends that you signup for an API key if you expect heavy API usage, such as using the API in an app you are developing. Visit [https://api.nasa.gov/](https://api.nasa.gov/) to get a free key.

## Usage
To use this plugin, add `nasa_apis` as a dependency in your pubspec.yaml file.

### Examples

Here are small examples that show you how to use the API. The examples provided do not show all of the API. Please review the documentation for additonal information.

All requests will return a tuple of data, with the first item being an integer HTTP response code, and the second will be the data items.

#### Configuration

Configure the plugin to use an API key, re-route logging, change caching durations, and more.

```dart
Nasa.init(
    apiKey: "INSERT YOUR API KEY",
    apodSupport: true,
    apodCacheSupport: true,
    apodDefaultCacheExpiration: const Duration(days: 90)
);
```

#### Astronomy Picture of the Day (APOD)

Review the documentation for an ApodItem for the fields of data. Generally the data will include a uuid, copyright, date, explanation, hdUrl, mediaType, serviceVersion, thumbnailUrl if video, title, and url.

##### Requests

Perform requests with the API to get the specified dates. If caching is enabled, all requests (except requestByRandom()) are cached, so re-requesting them will be faster and not count against the NASA API request limit.

```dart
Tuple2<int, ApodItem?> itemPair = await requestByDate(DateTime(2005, 9, 13));
...
Tuple2<int, List<ApodItem>?> itemPair = await requestByMonth(2012, 1);
...
const int count = 7;
Tuple2<int, List<ApodItem>?> itemsPair = await requestByRandom(count);
...
DateTime startDate = DateTime(2022, 10, 1);
DateTime endDate = DateTime(2022, 10, 7);
Tuple2<int, List<ApodItem>?> itemPair = await requestByRange(startDate, endDate);
```

##### Update and retrieve categories

Categories can be added to an item and saved. Categories can also be search for using a provided search function. The 'expiration' field in an ApodItem can be updated to a different expiration, or set to null to make persistent.

```dart
ApodItem apodItem = ...;
apodItem.categories.add("example");
apodItem.expiration = DateTime.now().add(const Duration(days: 3));
await updateItemCache(apodItem: apodItem);

List<ApodItem> items = await getCategory(category: "example");
```

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/voidari/flutter_nasa_apis.svg?style=for-the-badge
[contributors-url]: https://github.com/voidari/flutter_nasa_apis/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/voidari/flutter_nasa_apis.svg?style=for-the-badge
[forks-url]: https://github.com/voidari/flutter_nasa_apis/network/members
[stars-shield]: https://img.shields.io/github/stars/voidari/flutter_nasa_apis.svg?style=for-the-badge
[stars-url]: https://github.com/voidari/flutter_nasa_apis/stargazers
[issues-shield]: https://img.shields.io/github/issues/voidari/flutter_nasa_apis.svg?style=for-the-badge
[issues-url]: https://github.com/voidari/flutter_nasa_apis/issues
[license-shield]: https://img.shields.io/github/license/voidari/flutter_nasa_apis.svg?style=for-the-badge
[license-url]: https://github.com/voidari/flutter_nasa_apis/blob/main/LICENSE