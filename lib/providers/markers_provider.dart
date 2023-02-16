import 'dart:async';
import 'package:amuga/data/marker_data.dart';
import 'package:amuga/db/places_handler.dart';
import 'package:amuga/db/stop_handler.dart';
import 'package:amuga/entities/legs_itinerary_entity.dart';
import 'package:amuga/entities/route_map_entity.dart';
import 'package:amuga/entities/stop_entity.dart';
import 'package:amuga/entities/travel_itinerary_entity.dart';
import 'package:amuga/helper/distances.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;
import 'package:vibration/vibration.dart';

const PERMISSION_FILE = "permission.in";

class MarkersProvider extends ChangeNotifier {
  MarkerData actualPosition;
  MarkerData selectedPoint;
  MarkerData selectedStart;
  MarkerData selectedEnd;
  MarkerData selectedMarker;
  MarkerData nearestPlaceMarker;
  Stop nearestStop;
  Place nearestPlace;
  List<RouteMap> routePassingBy;
  Map places;
  latLng.LatLng myPosition; //= latLng.LatLng(5.338628, -3.9784693000000004);
  String infoMarker = "Position actuelle";
  bool positionGaranted = false;
  bool inTrackingMode = false;
  bool inAbidjan = false;
  bool gpsActivated = false;
  Stream<Position> positionStream;
  StreamSubscription<Position> positionStreamSub;

  List<MarkerData> stops = [];
  List<Marker> stopsMarkers = [];
  List<MarkerData> favorits = [];
  List<Marker> favoritsMarkers = [];
  //List<Marker> eventsMarkers = [];
  int nbStops;
  double percentage = 0;
  bool initFinished = false;

  List<LegInItinerary> stepsInItinerary = <LegInItinerary>[];
  int stepLevelInTravel = 0;
  bool inStepArrivalZone = false;

  Future<bool> isLocationPermissionAsked() async {
    final directory = await getApplicationDocumentsDirectory();
    return io.File(path.join(directory.path, PERMISSION_FILE)).exists();
  }

  Future<void> setLocationPermission() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = await io.File(path.join(directory.path, PERMISSION_FILE));
    file.writeAsString("done");
  }

  Future<void> updateMyPosition() async {
    if (positionGaranted == true) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      myPosition = latLng.LatLng(position.latitude, position.longitude);
    }
  }

  Future<void> _initActualPosition() async {
    bool goForSettings = await isLocationPermissionAsked();
    LocationPermission permission;
    if (!goForSettings) {
      // ask the user to go to the settings for applying the permissions
      permission = await Geolocator.requestPermission();
      await setLocationPermission();
    } else {
      permission = await Geolocator.checkPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      gpsActivated = true;
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // calculate the distance between the center of Abidjan and the
      // actual position
      var dist = distanceBetweenPos(
          position.longitude, position.latitude, -3.9784693000000004, 5.338628);

      // If the distance from the center of Abidjan is greater than 150 Km
      // we set the center of the of Abidjan as the actual position
      if (dist > 150000) {
        myPosition = latLng.LatLng(5.338628, -3.9784693000000004);
        positionGaranted = false;
        inAbidjan = false;
      } else {
        myPosition = latLng.LatLng(position.latitude, position.longitude);
        positionGaranted = true;
        inAbidjan = true;
      }

      Marker marker = new Marker(
          width: 3.0,
          height: 3.0,
          point: myPosition,
          builder: (ctx) =>
              MarkerData.getBuilder(MarkerType.MY_POSITION_MARKER));
      actualPosition = MarkerData(
          type: MarkerType.MY_POSITION_MARKER,
          id: "MY_POS",
          name: "Ma Position",
          marker: marker);
      selectedMarker = actualPosition;
      infoMarker = "Position actuelle";
      notifyListeners();
    } else {
      positionGaranted = false;
      gpsActivated = false;
      myPosition = latLng.LatLng(5.338628, -3.9784693000000004);
    }
  }

  void updateSelectedMarker(MarkerType type) {
    switch (type) {
      case MarkerType.MY_POSITION_MARKER:
        selectedMarker = actualPosition;
        infoMarker = "Position actuelle";
        break;
      case MarkerType.TEMPORARY_MARKER:
        selectedMarker = selectedPoint;
        infoMarker = "Position choisie";
        break;
      case MarkerType.INSTANT_DEPARTURE_MARKER:
        selectedMarker = selectedStart;
        infoMarker = "Départ choisi";
        break;
      case MarkerType.INSTANT_ARRIVAL_MARKER:
        selectedMarker = selectedStart;
        infoMarker = "Arrivée choisie";
        break;
      case MarkerType.FAVORITE_PLACE_MARKER:
        if (nearestPlace == null) {
          selectedMarker = favorits[favorits.length - 1];
          infoMarker = selectedMarker.name;
        } else {
          selectedMarker = nearestPlaceMarker;
          infoMarker = nearestPlace.name;
          print("nearest place : ${nearestPlace.name}");
        }
        break;
      case MarkerType.STOP_MARKER:
        selectedMarker = null;
        infoMarker = "";
        break;
    }

    notifyListeners();
  }

  Future<void> _initFavMarkers() async {
    List<Place> favPlaces = await PlacesHandler().getPlaces();
    favPlaces.forEach((element) {
      places[element.name] = latLng.LatLng(element.lat, element.lon);
      // now create a marker
      Marker marker = new Marker(
          width: 3.0,
          height: 3.0,
          point: latLng.LatLng(element.lat, element.lon),
          builder: (ctx) =>
              MarkerData.getBuilder(MarkerType.FAVORITE_PLACE_MARKER));
      favoritsMarkers.add(marker);
      favorits.add(MarkerData(
          type: MarkerType.FAVORITE_PLACE_MARKER,
          id: "FAV", //all the favorites have the same id
          name: element.name,
          marker: marker));
    });
    notifyListeners();
  }

  Future<void> _initStopsMarkers() async {
    places = new Map<String, latLng.LatLng>();
    List<Stop> listStops = await StopHandler().getStops();
    nbStops = listStops.length;
    listStops.forEach((element) {
      // add the stop in the list of places
      places[element.name] = latLng.LatLng(element.lat, element.lon);
      // now create a marker
      Marker marker = new Marker(
          width: 3.0,
          height: 3.0,
          point: latLng.LatLng(element.lat, element.lon),
          builder: (ctx) => MarkerData.getBuilder(MarkerType.STOP_MARKER));
      stopsMarkers.add(marker);
      stops.add(MarkerData(
          type: MarkerType.STOP_MARKER,
          id: element.id,
          name: element.name,
          marker: marker));
      percentage += 1 / (nbStops * 2);
      notifyListeners();
    });
  }

  List<String> getPlaces() {
    return places.keys.toList(growable: false);
  }

  void addPlace(String name, latLng.LatLng pos) {
    places[name] = pos;
    notifyListeners();
  }

  Future<void> addFavorite(String name, latLng.LatLng pos) async {
    // First add the favorite to the database
    await PlacesHandler().putPlace(name, pos);
    // Second add the place in the list of suggestions
    places[name] = pos;
    // Third add the place marker
    Marker marker = new Marker(
        width: 3.0,
        height: 3.0,
        point: latLng.LatLng(pos.latitude, pos.longitude),
        builder: (ctx) =>
            MarkerData.getBuilder(MarkerType.FAVORITE_PLACE_MARKER));
    favoritsMarkers.add(marker);
    // Finally add the marker data for search in the map
    favorits.add(MarkerData(
        type: MarkerType.FAVORITE_PLACE_MARKER,
        id: "FAV",
        name: name,
        marker: marker));
    // delete the the actual marker
    selectedPoint = null;
    // now notify all the listeners
    notifyListeners();
  }

  Future<List<RouteMap>> getRoutePassingBy(String stopId) async {
    List<RouteMap> routes = await StopHandler().getRoutesPassingBy(stopId);
    routePassingBy = routes;
    notifyListeners();
    return routes;
  }

  Place findNearestFavorit(latLng.LatLng from, double precision) {
    if (favorits == null || favorits.length == 0) return null;
    double min = distanceBetweenPos(from.longitude, from.latitude,
        favorits[0].marker.point.longitude, favorits[0].marker.point.latitude);
    int idxMin = 0;
    for (int i = 1; i < favorits.length; i++) {
      double dist = distanceBetweenPos(
          from.longitude,
          from.latitude,
          favorits[i].marker.point.longitude,
          favorits[i].marker.point.latitude);
      if (dist < min) {
        idxMin = i;
        min = dist;
      }
    }

    if (min <= precision) {
      nearestPlace = Place(
          name: favorits[idxMin].name,
          lon: favorits[idxMin].marker.point.longitude,
          lat: favorits[idxMin].marker.point.latitude);
      nearestPlaceMarker = favorits[idxMin];
    } else {
      nearestPlace = null;
    }
    notifyListeners();
    return nearestPlace;
  }

  Stop findNearesStop(latLng.LatLng from, double precision) {
    double min = distanceBetweenPos(from.longitude, from.latitude,
        stops[0].marker.point.longitude, stops[0].marker.point.latitude);
    int idxMin = 0;
    for (int i = 1; i < stops.length; i++) {
      double dist = distanceBetweenPos(from.longitude, from.latitude,
          stops[i].marker.point.longitude, stops[i].marker.point.latitude);
      if (dist < min) {
        idxMin = i;
        min = dist;
      }
    }

    if (min <= precision) {
      nearestStop = Stop(
          name: stops[idxMin].name,
          id: stops[idxMin].id,
          lat: stops[idxMin].marker.point.latitude,
          lon: stops[idxMin].marker.point.longitude);
    } else
      nearestStop = null;
    notifyListeners();
    return nearestStop;
  }

  Future<void> initMarkers() async {
    await _initStopsMarkers();
    await _initFavMarkers();
    await _initActualPosition();
    initFinished = true;
    print("initFinished !!! ");
  }

  void _updateMarker(MarkerType type, latLng.LatLng pos) {
    MarkerData data = new MarkerData(
        type: type,
        id: "",
        name: "",
        marker: Marker(
            width: 3.0,
            height: 3.0,
            point: pos,
            builder: (ctd) => MarkerData.getBuilder(type)));

    switch (type) {
      case MarkerType.MY_POSITION_MARKER:
        actualPosition = data;
        break;
      case MarkerType.TEMPORARY_MARKER:
        selectedPoint = data;
        break;
      case MarkerType.INSTANT_DEPARTURE_MARKER:
        selectedStart = data;
        break;
      case MarkerType.INSTANT_ARRIVAL_MARKER:
        selectedEnd = data;
        break;
    }
    notifyListeners();
  }

  void _deleteMarker(MarkerType type) {
    switch (type) {
      case MarkerType.MY_POSITION_MARKER:
        actualPosition = null;
        break;
      case MarkerType.TEMPORARY_MARKER:
        selectedPoint = null;
        break;
      case MarkerType.INSTANT_DEPARTURE_MARKER:
        selectedStart = null;
        break;
      case MarkerType.INSTANT_ARRIVAL_MARKER:
        selectedEnd = null;
        break;
    }
    notifyListeners();
  }

  void updateActualPosition(latLng.LatLng pos) {
    _updateMarker(MarkerType.MY_POSITION_MARKER, pos);
  }

  void deleteActualPosition() {
    _deleteMarker(MarkerType.MY_POSITION_MARKER);
  }

  void updateSelectedStart(latLng.LatLng pos) {
    _updateMarker(MarkerType.INSTANT_DEPARTURE_MARKER, pos);
  }

  void deleteSelectedStart() {
    _deleteMarker(MarkerType.INSTANT_DEPARTURE_MARKER);
  }

  void updateSelectedEnd(latLng.LatLng pos) {
    _updateMarker(MarkerType.INSTANT_ARRIVAL_MARKER, pos);
  }

  void deleteSelectedEnd() {
    _deleteMarker(MarkerType.INSTANT_ARRIVAL_MARKER);
  }

  void updateTemporaryMarker(latLng.LatLng pos) {
    _updateMarker(MarkerType.TEMPORARY_MARKER, pos);
  }

  void deleteTemporaryMarker() {
    _deleteMarker(MarkerType.TEMPORARY_MARKER);
  }

  void deleteRoutePassingBy() {
    routePassingBy = null;
    notifyListeners();
  }

  void changePointToDeparture() {
    // here the selected departure is not the actual point
    if (selectedMarker != null) {
      latLng.LatLng pos = selectedMarker.marker.point;
      MarkerData data = new MarkerData(
        type: MarkerType.INSTANT_DEPARTURE_MARKER,
        id: selectedMarker.id,
        name: selectedMarker.name,
        marker: Marker(
          width: 3.0,
          height: 3.0,
          point: pos,
          builder: (ctd) =>
              MarkerData.getBuilder(MarkerType.INSTANT_DEPARTURE_MARKER),
        ),
      );

      selectedStart = data;
      if (selectedPoint != null) selectedPoint = null;

      // now add the departure to the places
      places['Départ choisi'] = selectedStart.marker.point;
    }

    notifyListeners();
  }

  void changePointToArrival() {
    if (selectedMarker != null) {
      latLng.LatLng pos = selectedMarker.marker.point;
      MarkerData data = new MarkerData(
        type: MarkerType.INSTANT_DEPARTURE_MARKER,
        id: selectedMarker.id,
        name: selectedMarker.name,
        marker: Marker(
          width: 3.0,
          height: 3.0,
          point: pos,
          builder: (ctd) =>
              MarkerData.getBuilder(MarkerType.INSTANT_ARRIVAL_MARKER),
        ),
      );

      selectedEnd = data;
      if (selectedPoint != null) selectedPoint = null;

      // now add the arrival to the places
      places['Arrivée choisie'] = selectedEnd.marker.point;
    }

    notifyListeners();
  }

  void startTrackingPosition() async {
    inTrackingMode = true;

    positionStream = Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.best, distanceFilter: 10);

    positionStreamSub = positionStream.listen((position) async {
      myPosition = latLng.LatLng(position.latitude, position.longitude);
      print("tracked position : $myPosition");
      // calculate the distance between my actual position and the end of the actual step

      var dist = distanceBetweenPos(
          position.longitude,
          position.latitude,
          stepsInItinerary[stepLevelInTravel].to.lon,
          stepsInItinerary[stepLevelInTravel].to.lat);

      if (dist <= 50 && !inStepArrivalZone) {
        inStepArrivalZone = true;
        // vibrate the phone as the client asked for !
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate();
        }

        if (stepLevelInTravel == stepsInItinerary.length - 1) {
          // here we arrived to the destination
          inTrackingMode = false;
          positionStreamSub.cancel();
          stepsInItinerary.clear();
          stepLevelInTravel = 0;
        } else {
          // go to the next step
          stepLevelInTravel++;
        }
      } else {
        inStepArrivalZone = false;
      }
      notifyListeners();
    });
  }

  void endTrackingPosition() {
    inTrackingMode = false;
    positionStreamSub.cancel();
    notifyListeners();
  }

  Future<void> storeStepsInTheTravel(TravelItinerary itinerary) async {
    if (itinerary != null &&
        itinerary.legs != null &&
        itinerary.legs.isNotEmpty) {
      itinerary.legs.forEach((leg) {
        stepsInItinerary.add(LegInItinerary.clone(leg));
      });
      notifyListeners();
    }
  }

  void clearStepsInTheTravel() {
    stepLevelInTravel = 0;
    stepsInItinerary.clear();
    notifyListeners();
  }
}
