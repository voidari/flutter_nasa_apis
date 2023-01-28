## 0.0.6

* Add function to get previous and next day with photos given a list of rovers.
* Add function to get the range of days the rover list has photos available.
* Improve the caching to account for some missed edge cases.

## 0.0.5

* Add the mars rover API interface and database caching. Updates the database manager to correctly handle creation and upgrades.

## 0.0.4

* DateTime values provided need to be converted to the eastern timezone to make sure the date is valid. A date that is 1 day ahead of the eastern timezone will now revert back 1 day so it's the current eastern date.

## 0.0.3

* Add missing API key init in the request manager.

## 0.0.2

* Add support for setting the default cache expiration in the APOD cache update function.
* Fix the failing test suite.

## 0.0.1

* The first beta release of the NASA APIs.
* Supports the NASA Astronomy Picture of the Day APIs.
* Adds caching support for APOD.
* Assign categories to APOD items and provides a category search.
