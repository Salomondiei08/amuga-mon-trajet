import 'package:amuga/entities/stop_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:amuga/entities/route_map_entity.dart';
import 'db_handler.dart';

class StopHandler {
  Future<List<Stop>> getStops() async {
    final Database db = await DbHandler.db.database;

    final List<Map<String, dynamic>> maps = await db.query("stops");

    // converts the List<Map<String, dynamic>> into a List<Stop>
    return List.generate(maps.length, (i) {
      return Stop(
        name : maps[i]['stop_name'],
        lon : maps[i]['stop_lon'],
        lat : maps[i]['stop_lat'],
        id : maps[i]['stop_id'],
        //parent : maps[i]['parent_station'],
        //type : maps[i]['location_type']
      );
    });
  }

  Future<List<RouteMap>> getRoutesPassingBy(String stopId) async {
    final Database db = await DbHandler.db.database;

    List<Map<String, dynamic>> maps = await db.rawQuery("""SELECT DISTINCT r.route_id, r.route_long_name, r.route_short_name
        FROM stop_times st
        INNER JOIN trips t ON t.trip_id = st.trip_id
        INNER JOIN routes r ON r.route_id = t.route_id
        WHERE st.stop_id = "$stopId";
        """);
    return List.generate(maps.length, (i) {
      return RouteMap(
        id : maps[i]['route_id'],
        longName : maps[i]['route_long_name'],
        shortName : maps[i]['route_short_name']
      );
    });
  }
}
