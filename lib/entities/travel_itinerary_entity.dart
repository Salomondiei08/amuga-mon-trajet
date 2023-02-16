

import 'package:amuga/entities/legs_itinerary_entity.dart';


const WORO_ANGENCY = "Woro-woro";
const GBAKA_AGENCY = "Gbaka";

class TravelItinerary {
  final int duration;
  final int startTime;
  final int endTime;
  final int transitTime;
  final int waitingTime;
  final double walkDistance;
  var legs = <LegInItinerary>[];

  TravelItinerary(
      this.duration,
      this.startTime,
      this.endTime,
      this.transitTime,
      this.waitingTime,
      this.walkDistance);

  TravelItinerary.fromJson(Map<String, dynamic> json):
      duration = json['duration'],
      startTime = json['startTime'],
      endTime = json['endTime'],
      transitTime = json['transitTime'],
      waitingTime = json['waitingTime'],
      walkDistance = json['walkDistance'] {
    for (int i = 0; i < json['legs'].length; i++) {
      this.legs.add(LegInItinerary.from(json['legs'][i]));
    }
  }

  int getNbBus() {
    int nb = 0;
    for (int i = 0; i<legs.length; i++) {
      if (legs[i].mode == "BUS") nb++;
    }
    return nb;
  }

  int getNbWoroWoro() {
    int nb = 0;
    for (int i = 0; i < legs.length; i++) {
      if (legs[i].agencyName.contains("Woro-woro")) nb++;
    }
    return nb;
  }

  int getNbGbaka() {
    int nb = 0;
    for (int i = 0; i < legs.length; i++) {
      if (legs[i].agencyName.contains("Gbaka")) nb++;
    }
    return nb;
  }

  List<int> getNbConveyance() {
    int nbBus = 0, nbWoro = 0, nbGbaka = 0, nbFerry = 0;
    for (int i = 0; i < legs.length; i++) {
      if (legs[i].mode == "BUS") {
        nbBus++;
        if (legs[i].agencyName.contains("Woro-woro")) nbWoro++;
        if (legs[i].agencyName.contains("Gbaka")) nbGbaka++;
      }
      if (legs[i].mode == "FERRY") nbFerry++;
    }
    return [nbBus-(nbWoro+nbGbaka), nbWoro, nbGbaka, nbFerry];
  }
}