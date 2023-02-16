import 'stop_entity.dart';

class RouteMap {
  String longName;
  String shortName;
  String id;
  var stops = <Stop>[];
  //List<Stop> stops;

  RouteMap({this.id, this.longName, this.shortName});

  Map<String, dynamic>toMap() {
    return {
      'route_id': id,
      'route_long_name': longName,
      'route_short_name': shortName
    };
  }

  static RouteMap fromMap(Map<String, dynamic> map) {
    return RouteMap(
      longName: map['route_long_name'],
      shortName: map['route_short_name'],
      id: map['route_id']
    );
  }
}