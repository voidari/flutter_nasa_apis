// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

/// The base class that all models should implement for table creation.
abstract class BaseModel {
  String createTable();
  List<String> upgradeTable(int oldVersion, int newVersion);
}
