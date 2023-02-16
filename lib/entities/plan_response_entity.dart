import 'package:amuga/entities/travel_itinerary_entity.dart';

class PlanPoint {
  final String name;
  final double lon;
  final double lat;
  final String vertexType;

  PlanPoint(
      this.name,
      this.lon,
      this.lat,
      this.vertexType);

  PlanPoint.clone(PlanPoint planPoint)
      : name = planPoint.name,
        lon = planPoint.lon,
        lat = planPoint.lat,
        vertexType = planPoint.vertexType;

  PlanPoint.from(Map<String, dynamic> json) :
      name = json['name'],
      lon = json['lon'],
      lat = json['lat'],
      vertexType = json['vertexType'];
}


class PlanResponseEntity {
  final PlanPoint from;
  final PlanPoint to;
  var itineraries = <TravelItinerary>[];

  PlanResponseEntity(
      this.from,
      this.to);

  PlanResponseEntity.from(Map<String, dynamic> json):
      from = PlanPoint.from(json['from']),
      to = PlanPoint.from(json['to']) {

    for (int i = 0; i < json['itineraries'].length; i++) {
      //print("itinerary : ${json['itineraries'][i]}");
      this.itineraries.add(TravelItinerary.fromJson(json['itineraries'][i]));
    }
  }
}