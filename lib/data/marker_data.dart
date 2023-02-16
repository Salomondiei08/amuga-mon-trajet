import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:amuga/themes/default.dart';


enum MarkerType {
  INSTANT_DEPARTURE_MARKER,
  INSTANT_ARRIVAL_MARKER,
  TEMPORARY_MARKER,
  STOP_MARKER,
  FAVORITE_PLACE_MARKER,
  MY_POSITION_MARKER
}

Widget createIconWidget(IconData icon, Color color, double size) {
  return Container(
    child: Icon(icon, color: color, size: size)
  );
}

class MarkerData {
  MarkerType type;     // type of the marker defined byt the MarkerType enum
  Marker marker;        // the marker to be displayed on the map
  String id;            // identifier used to link the marker to the database fields
  String name;

  MarkerData({this.type, this.marker, this.id, this.name});

  static Widget getBuilder(MarkerType type) {
    switch(type) {
      case MarkerType.STOP_MARKER:
        return createIconWidget(FontAwesomeIcons.bus, kIconsColor, 16.0);
      case MarkerType.INSTANT_DEPARTURE_MARKER:
        return createIconWidget(FontAwesomeIcons.flagCheckered, Colors.green, 20.0);
      case MarkerType.INSTANT_ARRIVAL_MARKER:
        return createIconWidget(FontAwesomeIcons.flagCheckered, Colors.red, 20.0);
      case MarkerType.TEMPORARY_MARKER:
        return createIconWidget(FontAwesomeIcons.thumbtack, Colors.black, 16.0);
      case MarkerType.FAVORITE_PLACE_MARKER:
        return createIconWidget(FontAwesomeIcons.mapMarkerAlt, Colors.deepPurple, 22.0);
      case MarkerType.MY_POSITION_MARKER:
        return createIconWidget(FontAwesomeIcons.mapMarkerAlt, Colors.red, 22.0);
    }
  }

}