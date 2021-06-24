import 'dart:io';

import 'package:appsync_flutter/models/crud-model.dart';
import 'package:appsync_flutter/services/synchronize-service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class CrudService<T extends CrudModel> {
  static Database _database;
  String tableName;

  static final SynchronizeService _synchronizeService = SynchronizeService.instance;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  String getTableName();

  _initDatabase() async {
    Directory tempDir = await getTemporaryDirectory();
    return await openDatabase("${tempDir.path}/local_database.db", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE people (id String PRIMARY KEY, name TEXT, last_modified TEXT, deleted INTEGER, sync INTEGER)');
    });
  }

  Future<void> insert(CrudModel entity) async {
    Database db = await database;
    await db.insert(getTableName(), entity.toMap(isSqlite: true));
    if (!entity.sync) {
      _synchronizeService.sendOfflinePerson();
    }
  }

  Future<void> update(CrudModel entity) async {
    Database db = await database;
    await db.update(
      getTableName(),
      entity.toMap(isSqlite: true),
      where: "id = ?",
      whereArgs: [entity.id],
    );
    if (!entity.sync) {
      _synchronizeService.sendOfflinePerson();
    }
  }

  Future<void> delete(CrudModel entity) async {
    Database db = await database;
    entity.deleted = true;
    await db.update(
      getTableName(),
      entity.toMap(isSqlite: true),
      where: "id = ?",
      whereArgs: [entity.id],
    );
    _synchronizeService.deleteOfflinePerson();
  }

  Future<void> remove(CrudModel entity) async {
    Database db = await database;
    entity.deleted = true;
    await db.delete(
      getTableName(),
      where: "id = ?",
      whereArgs: [entity.id],
    );
  }

  Future<List<T>> list(CrudModel type,
      {String where, List<dynamic> whereArgs, includeDeleteds = false, ignoreOnlinePerson = false}) async {
    Database db = await database;
    if (!ignoreOnlinePerson) {
      await _synchronizeService.getOnlinePerson();
    }
    if (!includeDeleteds) {
      where = where == null ? "deleted = ?" : "$where and deleted = ?";
      if (whereArgs == null) {
        whereArgs = [0];
      } else {
        whereArgs.add(0);
      }
    }
    List<Map> maps = await db.query(
      getTableName(),
      columns: type.dbColumns(),
      where: where,
      whereArgs: whereArgs,
    );

    List<T> entities = [];
    if (maps.length > 0) {
      for (var map in maps) {
        entities.add(type.fromMap(map));
      }
    }
    return entities;
  }
}
