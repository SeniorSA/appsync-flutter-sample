import 'package:flutter/material.dart';

import 'package:connectivity/connectivity.dart';

import 'package:appsync_flutter/features/people/form.dart';
import 'package:appsync_flutter/features/people/list.dart';
import 'package:appsync_flutter/services/synchronize-service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  static final SynchronizeService _synchronizeService = SynchronizeService.instance;

  @override
  Widget build(BuildContext context) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _synchronizeService.synchronize();
      }
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PeopleList(),
      routes: <String, WidgetBuilder>{
        '/register': (BuildContext context) =>
            PeopleForm(person: ModalRoute.of(context).settings.arguments),
      },
    );
  }
}