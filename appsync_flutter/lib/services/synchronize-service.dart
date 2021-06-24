import 'package:appsync_flutter/utils/datetime-formatter.dart';
import 'package:flutter/material.dart';

import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:appsync_flutter/exceptions/graphql-exception.dart';
import 'package:appsync_flutter/models/person.dart';
import 'package:appsync_flutter/services/person-service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SynchronizeService {
  SynchronizeService._privateConstructor();

  static final SynchronizeService instance =
      SynchronizeService._privateConstructor();

  static final PersonService _personService = PersonService.instance;

  synchronize() async {
    await sendOfflinePerson();
    await deleteOfflinePerson();
  }

  Future<void> getOnlinePerson() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime lastSynchronize;
      if (prefs.getString('lastSynchronize') != null) {
        lastSynchronize =
            iso8601ToDateTime(prefs.getString('lastSynchronize').toString());
      }
      if (await _isConnected()) {
        await _doGetOnlinePerson(lastSynchronize: lastSynchronize);
      }
    } on GraphQLException catch (err) {
      _showToast(err.message);
    } catch (err) {
      print(err);
      _showToast(err.toString());
    }
  }

  Future<void> _doGetOnlinePerson({DateTime lastSynchronize}) async {
    await Future.delayed(Duration(seconds: 1));
    var people = await _personService.getPersonGraphQL(datetime: lastSynchronize);
    for (var person in people) {
      person.sync = true;
      var localePeople = await _personService.list(
        Person(),
        where: "id = ?",
        whereArgs: [person.id],
        includeDeleteds: true,
        ignoreOnlinePerson: true,
      );
      if (localePeople.length > 0) {
        if (person.deleted && !localePeople[0].deleted) {
          localePeople[0].deleted = true;
        }
        await _personService.update(person);
      } else {
        await _personService.insert(person);
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lastSynchronize', DateTime.now().toUtc().toIso8601String());
  }

  Future<void> sendOfflinePerson() async {
    try {
      if (await _isConnected()) {
        var people = await _personService
            .list(Person(), where: "sync = ?", whereArgs: [0], ignoreOnlinePerson: true);
        for (var person in people) {
          await _personService.savePerson(person);
          person.sync = true;
          await _personService.update(person);
        }
      }
    } on GraphQLException catch (err) {
      _showToast(err.message);
    } catch (err) {
      print(err);
      _showToast("Ocorreu um erro inesperado!");
    }
  }

  Future<void> deleteOfflinePerson() async {
    try {
      if (await _isConnected()) {
        var people = await _personService.list(Person(),
            where: "deleted = ?",
            whereArgs: [1],
            includeDeleteds: true,
            ignoreOnlinePerson: true);
        for (var person in people) {
          await _personService.savePerson(person);
          await _personService.remove(person);
        }
      }
    } on GraphQLException catch (err) {
      _showToast(err.message);
    } catch (err) {
      print(err);
      _showToast("Ocorreu um erro inesperado!");
    }
  }

  Future<bool> _isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void _showToast(String message) async {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
