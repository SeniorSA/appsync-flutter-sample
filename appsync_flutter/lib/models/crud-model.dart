abstract class CrudModel {

  String id;
  DateTime lastModified;
  bool deleted;
  bool sync;

  Map<String, dynamic> toMap({isSqlite: false});
  List<String> dbColumns();
  CrudModel fromMap(Map<String, dynamic> entity);
}