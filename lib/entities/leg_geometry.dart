import "package:latlong/latlong.dart" as latLng;
import 'package:polyline/polyline.dart' as plt;

class LegGeometry {
  final String points;
  final int length;

  LegGeometry(
      this.points,
      this.length
      );

  LegGeometry.from(Map<String, dynamic> json):
      points = json['points'],
      length = json['length'];

  List<latLng.LatLng> getArrayOfPoints() {
    List<latLng.LatLng> pts = <latLng.LatLng>[];
    plt.Polyline polyline = plt.Polyline.Decode(
      encodedString: this.points,
      precision: 5
    );
    polyline.decodedCoords.forEach((element) {
      pts.add(latLng.LatLng(element[0], element[1]));
    });

    return pts;
  }
}