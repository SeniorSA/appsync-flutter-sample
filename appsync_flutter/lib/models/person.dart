import 'package:appsync_flutter/models/crud-model.dart';
import 'package:uuid/uuid.dart';

class Person extends CrudModel {
  String name;

  Person({this.name, String id, bool deleted = false, sync = false}) {
    this.id = id != null ? id : (Uuid()).v4();
    this.deleted = deleted;
    this.sync = sync;
  }

  Map<String, dynamic> toMap({isSqlite: false}) {
    Map<String, dynamic> map = {
      "id": id,
      "name": name,
      "last_modified": DateTime.now().toUtc().toIso8601String(),
      "deleted": deleted
    };
    if (isSqlite) {
      map["deleted"] = deleted ? 1 : 0;
      map["sync"] = sync ? 1 : 0;
    }
    return map;
  }

  List<String> dbColumns() {
    return ["id", "name", "last_modified", "deleted", "sync"];
  }

  CrudModel fromMap(Map<String, dynamic> entity) {
    var person = Person(
      name: entity["name"],
      id: entity["id"],

      sync: entity["sync"] == 1
    );
    if (entity["deleted"] is int) {
      person.deleted = entity["deleted"] == 1;
    } else {
      person.deleted = entity["deleted"];
    }
    return person;
  }
}
