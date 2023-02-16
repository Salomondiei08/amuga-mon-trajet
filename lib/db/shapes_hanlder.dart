import "package:latlong/latlong.dart" as latLng;
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

import "package:amuga/db/nosql_db_handler.dart";

class Point {
  double lat;
  double lon;

  Point({this.lat, this.lon});

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lon': lon};
  }

  static Point fromMap(Map<String, dynamic> map) {
    return Point(lat: map['lat'], lon: map['lon']);
  }
}

class Shape {
  String route_id;
  List<Point> points;

  static const STORE_NAME = 'shapes';

  Shape({
    this.route_id,
    this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': route_id,
      'points': points.map((point) => point.toMap()).toList(growable: false)
    };
  }

  static Shape fromMap(Map<String, dynamic> map) {
    return Shape(
        route_id: map['id'],
        points: map['points']
            .map<Point>((mapping) => Point.fromMap(mapping))
            .toList());
  }
}

class ShapesHandler {
  Future<List<Point>> getShape(String routeId) async {
    final Database db = await NoSqlDbHandler.db.database;
    var shapes = intMapStoreFactory.store(Shape.STORE_NAME);
    Finder finder = Finder(filter: Filter.equals('id', routeId));
    final record = await shapes.find(db, finder: finder);

    if (record.isNotEmpty) {
      Shape shape = Shape.fromMap(record.first.value);
      return shape.points;
    } else {
      return null;
    }

    /*var shape =  record.map((snapshot) {
       return Shape.fromMap(snapshot.value);
    });

    print(shape);

    if (shape != null) return null;
    return null;*/
  }

  Future<void> putShape(String routeId, List<Point> list) async {
    final Database db = await NoSqlDbHandler.db.database;
    var shape = intMapStoreFactory.store(Shape.STORE_NAME);
    await shape.add(db, Shape(route_id: routeId, points: list).toMap());
  }
}
