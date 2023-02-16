import 'package:amuga/params/default.dart';
import 'package:flutter/foundation.dart';

class MapProvider extends ChangeNotifier {
  double zoom = kStartZoom;

  void updateZoom(double newZoom) {
    zoom = newZoom;
    notifyListeners();
  }
}