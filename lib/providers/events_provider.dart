import 'package:amuga/entities/event_entity.dart';
import 'package:amuga/network/events_requests.dart';
import 'package:amuga/themes/default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:latlong/latlong.dart" as latLng;

class EventRepr {
  String id; // event id for the network api
  IconData data;

  EventRepr({this.id, this.data});
}

class EventData {
  String name;
  latLng.LatLng pos;
}

class EventProvider extends ChangeNotifier {
  String selectedEvent = "Embouteillage";
  String favPlace = "";
  List<EventEntity> events;
  List<Marker> eventsMarkers = [];

  Future<void> getAllEvents() async {
    events = await EventsHttpRequests().getAllEvents();
    eventsMarkers = [];

    // fill all the eventsMarkers
    events.forEach((element) {
      IconData icon = getEventBycat(element.cat).data;
      print("icon : $icon");
      Marker marker = new Marker(
        width: 3.0,
        height: 3.0,
        point: latLng.LatLng(element.lat, element.lon),
        builder: (ctx) => Container(
            child: Icon(getEventBycat(element.cat).data,
                color: Colors.deepOrange,
                size: 20.0))
      );
      eventsMarkers.add(marker);
    });

    notifyListeners();
  }

  void updateFavPlace(String newFavPlace) {
    favPlace = newFavPlace;
    notifyListeners();
  }

  void updateSelectedEvent(String newValue) {
    selectedEvent = newValue;
    notifyListeners();
  }

  Map<String, EventRepr> eventsTitles = {
    "Embouteillage": EventRepr(id:"A", data: Icons.commute),
    "Accident /Incident": EventRepr(id:"B", data: FontAwesomeIcons.carCrash),
    "Feux tricolores en panne": EventRepr(id:"C", data: FontAwesomeIcons.trafficLight),
    "Manifestation": EventRepr(id:"D", data: FontAwesomeIcons.bullhorn),
    "Route dégradée": EventRepr(id:"E", data: FontAwesomeIcons.bacon),
    "Travaux routiers - déviation": EventRepr(id:"F", data: Icons.warning),
    "Nouveau sens interdit": EventRepr(id:"G", data: FontAwesomeIcons.minusCircle),
    "Route barrée": EventRepr(id:"H", data: Icons.block),
    "Pas de gbaka": EventRepr(id:"I", data: Icons.link_off),
    "Pas de bus": EventRepr(id:"J", data: Icons.link_off),
    "Pas de wôrô-wôrô": EventRepr(id:"K", data: Icons.link_off),
    "Grève en cours": EventRepr(id:"L", data: FontAwesomeIcons.fistRaised),
    "Augmentation des tarifs": EventRepr(id:"M", data: Icons.show_chart),
    "Retour avant terminus": EventRepr(id:"N", data: Icons.alt_route),
    "Conflits entre transporteurs": EventRepr(id:"O", data: FontAwesomeIcons.angry)
  };

  EventRepr getEventBycat(String cat) {
    EventRepr ret;
    eventsTitles.forEach((key, value) {
      if (value.id == cat) ret = value;
    });
    return ret;
  }

  EventRepr getEventReprByIdx(int idx) {
    if (idx >= events.length) return null;
    EventRepr ret;
    eventsTitles.forEach((key, value) {
      if (value.id == events[idx].cat) {
        ret = value;
        // NO break in foreach WTF !!!
      }
    });
    return ret;
  }

  String getEventTitleByIdx(int idx) {
    if (idx >= events.length) return "";
    String ret;
    eventsTitles.forEach((key, value) {
      if (value.id == events[idx].cat) ret = key;
    });
    return ret;
  }

  List<EventData> eventsList = <EventData>[];

  void addEvent(EventData event) {
    eventsList.add(event);
    notifyListeners();
  }

}