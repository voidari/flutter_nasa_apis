// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/apod/apod_item_model.dart';
import 'package:nasa_apis/src/models/base_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// The manager of the database initializations. Provides the reference for
/// the database creation, connections, and utilities.
class DatabaseManager {
  static const String _cDatabaseName = "nasa_apis.db";
  static const int _cVersion = 1;

  static late Database _database;

  /// The init function for the database manager, creating the database
  /// and the connection.
  static Future<void> init({bool isTest = false}) async {
    _database = await openDatabase(
      isTest
          ? inMemoryDatabasePath
          : join(await getDatabasesPath(), _cDatabaseName),
      version: _cVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Retrieves the list of all models so they can be created.
  static List<BaseModel> _getModels() {
    return <BaseModel>[ApodItemModel()];
  }

  /// Handles the creation of the database and all tables.
  static void _onCreate(Database db, int version) {
    for (BaseModel model in _getModels()) {
      db.execute(model.createTable());
    }
  }

  /// Handles the upgrade of the database and all tables.
  static void _onUpgrade(Database db, int oldVersion, int newVersion) {
    for (BaseModel model in _getModels()) {
      for (String command in model.upgradeTable(oldVersion, newVersion)) {
        db.execute(command);
      }
    }
  }

  /// Retrieves a connection to the database for interaction with tables.
  static Database getConnection() {
    return _database;
  }
}
