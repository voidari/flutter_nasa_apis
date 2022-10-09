// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

/// The base class that all models should implement for table creation.
abstract class BaseModel {
  /// Retrieves the string used to create the SQL table.
  String createTable();

  /// Retrieves the list of strings used to upgrade an existing table
  /// to the current state of the table.
  List<String> upgradeTable(int oldVersion, int newVersion);
}
