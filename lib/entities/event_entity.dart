

class EventEntity {
  String did;
  String cat;
  double lon;
  double lat;

  EventEntity({this.did, this.lon, this.lat, this.cat});

  Map<String, dynamic> toMap() {
    return {
      'did': did,
      'cat': cat,
      'lon': lon,
      'lat': lat
    };
  }

  EventEntity.from(Map<String, dynamic> json) :
        did = json['did'],
        lon = json['lon'],
        lat = json['lat'],
        cat = json['cat'];
}

class EventLocResult {
  String type;
  List<double> coordinates = <double>[];

  EventLocResult({this.type, this.coordinates});

  EventLocResult.from(Map<String, dynamic> json) :
      type = json['type']{
    for(int i=0; i<json['coordinates'].length; i++) {
      coordinates.add(json['coordinates'][i]);
    }
  }

}

class EventEntityResult {
  String cat;
  String til;
  EventLocResult loc;

  EventEntityResult({this.cat, this.til, this.loc});

  EventEntityResult.from(Map<String, dynamic> json) :
      til = json['til'],
      cat = json['cat'],
      loc = EventLocResult.from(json['loc']);
}