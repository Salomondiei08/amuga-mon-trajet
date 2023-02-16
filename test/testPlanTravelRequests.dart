



import 'package:amuga/entities/plan_response_entity.dart';
import 'package:amuga/network/plan_travel.dart';
import "package:latlong/latlong.dart" as latLng;
// import 'package:http/http.dart' as http;

/**
 * http://amuga-routing.azurewebsites.net/otp/routers/amuga/plan?
 * fromPlace=5.3503594643170205%2C-3.988208770751953&
 * toPlace=5.349312618418414%2C-4.00252103805542&
 * time=11%3A18pm&date=05-03-2021&
 * mode=TRANSIT%2CWALK&maxWalkDistance=5000&arriveBy=false&wheelchair=false&
 * debugItineraryFilter=false&locale=en
 * */

Future<void> testTravelHttpRequests( ) async {
  TravelHttpRequests travelHttpRequests = TravelHttpRequests();
  latLng.LatLng from = latLng.LatLng(5.3503594643170205, -3.988208770751953);
  latLng.LatLng to = latLng.LatLng(5.349312618418414, -4.00252103805542);

  PlanResponseEntity planResponseEntity = await travelHttpRequests.getTravelResults(from, to);

  print(planResponseEntity.from.name);
}

void main() async {
  print("------ TEST TRAVEL HTTP REQUEST ------");
  await testTravelHttpRequests();
  print("End test");

}