import 'package:amuga/entities/legs_itinerary_entity.dart';
import 'package:amuga/entities/travel_itinerary_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:flutter/foundation.dart';
import 'package:amuga/themes/default.dart';
import 'package:amuga/db/shapes_hanlder.dart';

class PathProvider extends ChangeNotifier {
  List<Polyline> paths = <Polyline>[];

  void updateMarkers(List<latLng.LatLng> points) {
    paths.clear();
    paths.add(Polyline(
      points: points,
      color: Colors.indigo,
      strokeWidth: 5,
      isDotted: false
    ));
    notifyListeners();
  }

  void displayRoutePath(String routeId) async {
    paths.clear();
    List<Point> points = await ShapesHandler().getShape(routeId);
    /* from list of points to list of LatLng */
    List<latLng.LatLng> pts = <latLng.LatLng>[];
    points.forEach((pt) {
      pts.add(latLng.LatLng(pt.lat, pt.lon));
    });

    paths.add(Polyline(
      points: pts,
      color: kIconsColor.withOpacity(0.5),
      strokeWidth: 7,
      isDotted: false
    ));
  }

  Future<void> displayPathForTravel(TravelItinerary itinerary) async {
    paths.clear();
    if (itinerary != null
        && itinerary.legs != null && itinerary.legs.isNotEmpty) {

      itinerary.legs.forEach((leg) {
        // collecting the points here
        paths.add(Polyline(
            points: leg.legGeometry.getArrayOfPoints(),
            color: kIconsColor.withOpacity(0.5),
            strokeWidth: 7,
            isDotted: leg.mode == "WALK"
        ));
      });

      notifyListeners();
    }

  }

  void clearPath() {
    paths.clear();
    notifyListeners();
  }
}