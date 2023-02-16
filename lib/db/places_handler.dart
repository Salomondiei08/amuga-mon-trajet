import 'package:flutter/foundation.dart';
import "package:latlong/latlong.dart" as latLng;
import "package:amuga/db/nosql_db_handler.dart";
import 'package:sembast/sembast.dart';
//import 'package:flutter/cupertino.dart';

class Place {
  double lat;
  double lon;
  String name;

  static const STORE_NAME = 'places';

  Place({ this.lat,
     this.lon,
     this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lat': lat,
      'lon': lon
    };
  }

  static Place fromMap(Map<String, dynamic> map) {
    return Place(
      lat: map['lat'],
      lon: map['lon'],
      name: map['name']
    );
  }
}

class PlacesHandler {
  Future<void> putPlace(String name, latLng.LatLng point) async {
    final Database db = await NoSqlDbHandler.db.database;
    var place = intMapStoreFactory.store(Place.STORE_NAME);
    await place.add(db, Place(name: name,
        lat: point.latitude, lon: point.longitude).toMap());
  }

  Future<List<Place>> getPlaces() async {
    final Database db = await NoSqlDbHandler.db.database;
    var places = intMapStoreFactory.store(Place.STORE_NAME);
    Finder finder = Finder();
    final records = await places.find(db, finder: finder);

    return records.map((snapshot) {
      final place = Place.fromMap(snapshot.value);
      return place;
    }).toList();
  }
}