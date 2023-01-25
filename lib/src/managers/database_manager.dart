// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library nasa_apis;

import 'package:nasa_apis/src/apod/apod_item_model.dart';
import 'package:nasa_apis/src/mars_rovers/day_info_item_model.dart';
import 'package:nasa_apis/src/mars_rovers/manifest_model.dart';
import 'package:nasa_apis/src/mars_rovers/photo_item_model.dart';
import 'package:nasa_apis/src/models/base_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// The manager of the database initializations. Provides the reference for
/// the database creation, connections, and utilities.
class DatabaseManager {
  static const String _cDatabaseName = "nasa_apis.db";
  static const int _cVersion = 2;

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
      onConfigure: _onConfigure,
    );
  }

  /// Configures the database before it's used.
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Retrieves the list of all models so they can be created.
  static List<BaseModel> _getModels(int oldVersion, int newVersion) {
    List<BaseModel> modelList = <BaseModel>[];
    if (oldVersion < 1 && 1 <= newVersion) {
      modelList.add(ApodItemModel());
    }
    if (oldVersion < 2 && 2 <= newVersion) {
      modelList.add(MarsRoverManifestModel());
      modelList.add(MarsRoverDayInfoItemModel());
      modelList.add(MarsRoverPhotoItemModel());
    }
    return modelList;
  }

  /// Handles the creation of the database and all tables.
  static Future<void> _onCreate(Database db, int newVersion,
      {int? oldVersion = 0}) async {
    for (BaseModel model in _getModels(0, newVersion)) {
      await db.execute(model.createTable());
    }
  }

  /// Handles the upgrade of the database and all tables.
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    _onCreate(db, newVersion, oldVersion: oldVersion);
    for (BaseModel model in _getModels(0, newVersion)) {
      for (String command in model.upgradeTable(oldVersion, newVersion)) {
        await db.execute(command);
      }
    }
  }

  /// Retrieves a connection to the database for interaction with tables.
  static Database getConnection() {
    return _database;
  }
}
