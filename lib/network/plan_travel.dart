/**
 * This is an example of a request for planning a travel
 * https://otp.metroservices.io/otp/routers/default/plan?arriveBy=false&
 * date=04-07-2021&fromPlace=34.223492,-119.20025&
 * maxWalkDistance=2253.0759999999996&mode=BUS,RAIL,TRAM,SUBWAY,WALK&numItineraries=2&
 * optimize=QUICK&showIntermediateStops=true&
 * time=11:13pm&toPlace=34.057836,-118.38038&
 * wheelchair=false
 * */

import 'package:amuga/entities/plan_response_entity.dart';
import 'dart:convert';

/**
 * An example of the response request is given by the planResponse.json file
 * */

import "network_params.dart" as nParams;
import "package:latlong/latlong.dart" as latLng;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class TravelHttpRequests {
  final String travelRoutingUrl = nParams.SERVER_URL +
      nParams.ROUTERS_ROUTE + nParams.PLAN_ROUTE;
  final String fixedOptions = "&searchWindow=3600&mode=TRANSIT,WALK&walkReluctance=10&"
      "arriveBy=false&wheelchair=false&debugItineraryFilter=false&locale=en";

  String _getPlanRequestUrl(latLng.LatLng from, latLng.LatLng to) {
    // date format for the url is MM-DD-YYYY
    final DateTime now = DateTime.now();
    String dateFormatted = DateFormat('MM-dd-yyy').format(now);
    String timeFormatted = DateFormat('hh:mma').format(now);
    String whereUrl = "?fromPlace=${from.latitude},${from.longitude}&"
        "toPlace=${to.latitude},${to.longitude}&"
        "time=$timeFormatted&date=$dateFormatted";
    return travelRoutingUrl + whereUrl + fixedOptions;

  }

  Future<PlanResponseEntity> getTravelResults(latLng.LatLng from, latLng.LatLng to) async {
    final String url = _getPlanRequestUrl(from, to);
    print("connection to $url");
    var client = http.Client();
    try {
      http.Response uriResponse = await client.get(Uri.parse(url));
      print("STATUS CODE : ${uriResponse.statusCode}");
      print("HTTP RESPONSE : ${uriResponse.body}");
      if (uriResponse.statusCode == 200) {
        try {
          //Map<String, dynamic> jsonResponse = jsonDecode(uriResponse.body);
          Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(uriResponse.bodyBytes));
          PlanResponseEntity planResponseEntity = PlanResponseEntity.from(jsonResponse["plan"]);
          client.close();
          return planResponseEntity;
        } catch (e) {
          client.close();
          return null;
        }
      }
    } catch (e) {
      print(e);
      client.close();
      return null;
    }
  }
}