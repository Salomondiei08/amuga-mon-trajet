import 'dart:math';
import 'package:geolocator/geolocator.dart';

const double RADIUS = 6378.16;

double radians(double x)
{
  return x * pi / 180;
}

double distanceBetweenPos(
    double lon1,
    double lat1,
    double lon2,
    double lat2)
{
  return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
}