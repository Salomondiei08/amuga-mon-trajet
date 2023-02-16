import 'package:amuga/entities/leg_geometry.dart';
import 'package:amuga/entities/step_in_itinerary_entity.dart';

import 'point_in_itinerary_entity.dart';

class LegInItinerary {
  final int startTime;
  final int endTime;
  final int departureDelay;
  final int arrivalDelay;
  final bool realTime;
  final double distance;
  final int generalizedCost;
  final String mode;
  final StartingPointInItinerary from;
  final EndingPointInItinerary to;
  var steps = <StepInItinerary>[];
  final LegGeometry legGeometry;
  final String route;
  final String agencyName;
  final String headsign;
  final String routeId;

  LegInItinerary(
      this.startTime,
      this.endTime,
      this.departureDelay,
      this.arrivalDelay,
      this.realTime,
      this.distance,
      this.generalizedCost,
      this.mode,
      this.from,
      this.to,
      this.legGeometry,
      this.route,
      this.agencyName,
      this.headsign,
      this.routeId
      );

  LegInItinerary.from(Map<String, dynamic> json):
      startTime = json['startTime'],
      endTime = json['endTime'],
      departureDelay = json['departureDelay'],
      arrivalDelay = json['arrivalDelay'],
      realTime = json['realTime'],
      distance = json['distance'],
      generalizedCost = json['generalizedCost'],
      mode = json['mode'],
      legGeometry = LegGeometry.from(json['legGeometry']),
      from = StartingPointInItinerary.from(json['from']),
      to = EndingPointInItinerary.from(json['to']),
      route = json['route'],
      agencyName = json['agencyName'],
      headsign = json['headsign'],
      routeId = json['routeId']
  {
    for (int i = 0; i < json['steps'].length; i++) {
      this.steps.add(StepInItinerary.from(json['steps'][i]));
    }
  }

  LegInItinerary.clone(LegInItinerary leg) :
      startTime = leg.startTime,
      endTime = leg.endTime,
      departureDelay = leg.departureDelay,
      arrivalDelay = leg.arrivalDelay,
      realTime = leg.realTime,
      distance = leg.distance,
      generalizedCost = leg.generalizedCost,
      mode = leg.mode,
      legGeometry = leg.legGeometry,
      from = StartingPointInItinerary.copy(leg.from),
      to = EndingPointInItinerary.copy(leg.to),
      route = leg.route,
      agencyName = leg.agencyName,
      headsign = leg.headsign,
      routeId = leg.routeId;
}