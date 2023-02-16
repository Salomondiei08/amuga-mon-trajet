

import 'package:amuga/db/routes_handler.dart';
import 'package:amuga/db/shapes_hanlder.dart';
import 'package:amuga/entities/route_map_entity.dart';
import 'package:flutter/material.dart';
import 'package:amuga/db/nosql_db_handler.dart';
import "package:latlong/latlong.dart" as latLng;

class RoutesProvider extends ChangeNotifier {
  double percentage = 0;

  Future<void> initRoutesPaths() async {
    // Check first if the database exist normally the creation is done only
    // at the first start of the application
    bool created = await NoSqlDbHandler.db.isCreated();

    if (!created) {
      List<RouteMap> routes = await RouteHandler().getRoutes();
      int nbRoutes = routes.length;
      var shapes = ShapesHandler();
      routes.forEach((route) async {
        // here we will get the shape of the route
        List<Point> shape = await RouteHandler().getRouteShape(route.id);
        // now store the result in a nosql database
        shapes.putShape(route.id, shape);
        percentage += 1/(nbRoutes * 2);
        notifyListeners();
      });
    } else {
      print("Nosql database exists");
      percentage = 0.5;
      notifyListeners();
    }

  }
}