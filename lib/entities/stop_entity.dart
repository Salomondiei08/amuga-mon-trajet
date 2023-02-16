

class Stop {
  String name;
  String id;
  double lon;
  int parent;
  double lat;
  int type;

  Stop({this.name,
    this.lon,
    this.lat,
    this.parent,
    this.type,
    this.id
  });

  get typesAsStrings => null;

  Map<String, dynamic>toMap() {
    return {
      'stop_name': name,
      'stop_lon': lon,
      'stop_lat': lat,
      'parent_station': parent,
      'location_type': type,
      'stop_id': id
    };
  }
}