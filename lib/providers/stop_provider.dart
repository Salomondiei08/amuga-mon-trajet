


import 'package:amuga/db/db_handler.dart';
import 'package:amuga/db/stop_handler.dart';
import 'package:amuga/entities/stop_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

class StopProvider extends ChangeNotifier {
  var stopsToDisplay = <Stop>[];
  var allStops = <Stop>[];
  bool dbCopied = false;

  Future<void> createDb() async {
    final Database db = await DbHandler.db.database;
    dbCopied = true;
    notifyListeners();
  }


  Future<void> getAllStops() async {
    List<Stop> stops = await StopHandler().getStops();
    stops.forEach((element) {
      allStops.add(element);
    });
    notifyListeners();
  }
}