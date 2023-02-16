

class StepInItinerary {
  final double distance;
  final String relativeDirection;
  final String streetName;
  final String absoluteDirection;
  final bool stayOn;
  final bool area;
  final bool bogusName;
  final double lon;
  final double lat;

  StepInItinerary(
      this.distance,
      this.relativeDirection,
      this.streetName,
      this.absoluteDirection,
      this.stayOn,
      this.area,
      this.bogusName,
      this.lon,
      this.lat);

  StepInItinerary.from(Map<String, dynamic> json):
      distance = json['distance'],
      relativeDirection = json['relativeDirection'],
      streetName = json['streetName'],
      absoluteDirection = json['absoluteDirection'],
      stayOn = json['stayOn'],
      area = json['area'],
      bogusName = json['bogusName'],
      lon = json['lon'],
      lat = json['lat'];
}