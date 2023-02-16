

class StartingPointInItinerary {
  final String name;
  final double lon;
  final double lat;
  final int departure;
  final String vertexType;

  StartingPointInItinerary(
      this.name,
      this.lon,
      this.lat,
      this.departure,
      this.vertexType);

  StartingPointInItinerary.from(Map<String, dynamic> json):
      name = json['name'],
      lon = json['lon'],
      lat = json['lat'],
      departure = json['departure'],
      vertexType = json['vertexType'];

  StartingPointInItinerary.copy(StartingPointInItinerary start):
      name = start.name,
      lon = start.lon,
      lat = start.lat,
      departure = start.departure,
      vertexType = start.vertexType;
}

class EndingPointInItinerary {
  final String name;
  final double lon;
  final double lat;
  final int arrival;
  final String vertexType;

  EndingPointInItinerary(
      this.name,
      this.lon,
      this.lat,
      this.arrival,
      this.vertexType);

  EndingPointInItinerary.from(Map<String, dynamic> json):
        name = json['name'],
        lon = json['lon'],
        lat = json['lat'],
        arrival = json['arrival'],
        vertexType = json['vertexType'];

  EndingPointInItinerary.copy(EndingPointInItinerary end) :
      name = end.name,
      lon = end.lon,
      lat = end.lat,
      arrival = end.arrival,
      vertexType = end.vertexType;
}