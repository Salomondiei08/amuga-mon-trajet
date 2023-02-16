import 'package:amuga/db/shapes_hanlder.dart';

import 'db_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:amuga/entities/route_map_entity.dart';
import 'package:amuga/entities/stop_entity.dart';
import "package:latlong/latlong.dart" as latLng;

class RouteHandler {
  Future<List<RouteMap>> getRoutes() async {
    final Database db = await DbHandler.db.database;
    final List<Map<String, dynamic>> maps = await db.query("routes");

    return List.generate(maps.length, (i) {
      return RouteMap(
        id : maps[i]['route_id'],
        longName : maps[i]['route_long_name'],
        shortName : maps[i]['route_short_name'],
      );
    });
  }

  Future<RouteMap> getRouteById(String id) async {
    final Database db = await DbHandler.db.database;
    List<Map<String, dynamic>> res = await db.rawQuery("""
    SELECT * FROM routes WHERE route_id = ${id}
    """);

    if (res != null && res.length >= 1) return RouteMap.fromMap(res[0]);
    return null;
  }

  Future<List<Stop>> getRouteWithStops(routeId) async {
    final Database db = await DbHandler.db.database;

    List<Map<String, dynamic>> maps = await db.rawQuery("""
    SELECT DISTINCT stops.stop_id, stops.stop_name, stops.stop_lon, stops.stop_lat
          FROM trips
          INNER JOIN stop_times ON stop_times.trip_id = trips.trip_id
          INNER JOIN stops ON stops.stop_id = stop_times.stop_id
          WHERE route_id = "$routeId";
    """);

    return List.generate(maps.length, (i) {
      return Stop(
        id : maps[i]['stop_id'],
        lon : maps[i]['stop_lon'],
        lat : maps[i]['stop_lat'],
      );
    });
  }

  Future<List<Point>> getRouteShape(routeId) async {
    final Database db = await DbHandler.db.database;

    List<Map<String, dynamic>> maps = await db.rawQuery("""
    SELECT s.shape_pt_lat, shape_pt_lon 
        FROM trips t, shapes s 
        WHERE s.shape_id = t.shape_id 
          AND t.direction_id = 0 
          AND t.route_id = "$routeId" 
          ORDER BY s.shape_pt_sequence;
    """);

    return List.generate(maps.length, (i) {
      return Point(lat: maps[i]['shape_pt_lat'], lon: maps[i]['shape_pt_lon']);
    });
  }

  Future<List<RouteMap>> getRoutesWithStops() async {
    List<RouteMap> routes = await getRoutes();
    // now fill the stops list for each route
    final Database db = await DbHandler.db.database;
    
    await Future.forEach(routes, (element) async {
      List<Map<String, dynamic>> maps = await db.rawQuery("""SELECT DISTINCT stops.stop_id, stops.stop_name, stops.stop_lon, stops.stop_lat
          FROM trips
          INNER JOIN stop_times ON stop_times.trip_id = trips.trip_id
          INNER JOIN stops ON stops.stop_id = stop_times.stop_id
          WHERE route_id = ${element.id};""");

      maps.forEach((stop) {
        element.stops.add(Stop(
            name: stop['stop_name'],
            lon: stop['stop_lon'],
            lat: stop['stop_lat'],
            id: stop['stop_id']
        ));
      });
    });
    
    return routes;
  }
}