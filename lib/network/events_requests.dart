import 'dart:convert';

import 'package:amuga/entities/event_entity.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import "package:latlong/latlong.dart" as latLng;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io;


const DEVICE_UDID_FILE = "udid.in";

class addEventResponse {
  bool ack;

  addEventResponse({this.ack});

  addEventResponse.from(Map<String, dynamic> json) :
      ack = json['ack'];

  Map<String, dynamic> toMap() {
    return {
      'ack': ack
    };
  }
}

class EventsHttpRequests {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname': data.utsname.sysname,
      'utsname.nodename': data.utsname.nodename,
      'utsname.release': data.utsname.release,
      'utsname.version': data.utsname.version,
      'utsname.machine': data.utsname.machine,
    };
  }
  
  final String eventsServiceUrl = "https://amuga-api.azurewebsites.net/api/events?code=aj4g6TTFRaD5a58Y59qfFLDjih32e7tLQsbPBjMTVHlkwI2en7i0Gg==";

  Future<List<EventEntity>> getAllEvents() async {
    print("Getting all the events from the server");
    var client = http.Client();
    try {
      var url = Uri.parse(eventsServiceUrl);
      http.Response response = await client.get(url);
      if (response.statusCode == 200) {
        print("result : ${response.body}");
        try{
          List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
          print("got the events : ");
          List<EventEntity> events = <EventEntity>[];
          jsonResponse.forEach((element) {
            events.add(EventEntity(did: "",
                lon: element["loc"]["coordinates"][0],
              lat: element["loc"]["coordinates"][1],
              cat: element["cat"]
            ));
            //print(element["cat"]);
          });
          print(jsonResponse.length);
          return events;
        } catch (e) {
          print(e);
          return <EventEntity>[];
        }
      } else {
        print("status code response = ${response.statusCode}");
        return <EventEntity>[];
      }
    } catch (e) {
      print("catching error $e");
      return <EventEntity>[];
    }
  }

  Future<bool> addEvent({latLng.LatLng pos, String event}) async {
    // getting the device info first
    Map<String, dynamic> deviceData;
    // TODO find a way to create a unique id for each device
    final directory = await getApplicationDocumentsDirectory();
    String uniqId;
    if (await io.File(path.join(directory.path, DEVICE_UDID_FILE)).exists() == false) {
      final file = await io.File(path.join(directory.path, DEVICE_UDID_FILE));
      int now = DateTime.now().millisecondsSinceEpoch;
      try {
        if (Platform.isAndroid) {
          deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
          uniqId = deviceData['androidId'] + "-" + now.toString();
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
          uniqId = deviceData['utsname.machine'] + "-" + now.toString();
        }
      } on PlatformException {
        uniqId = now.toString();
      }
      print("writing unique id for the device : $uniqId");
      file.writeAsString(uniqId);
    } else {
      final file = await io.File(path.join(directory.path, DEVICE_UDID_FILE));

      uniqId = await file.readAsString();
      print("unique id readen : $uniqId");
    }

    var client = http.Client();
    // now send the http request
    try {
      var body = EventEntity(did: uniqId,
          lon: pos.longitude,
          lat: pos.latitude,
          cat: event
      ).toMap();

      var url = Uri.parse(eventsServiceUrl);
      http.Response uriResponse = await client.post(
          url,
          headers: {'content-type': 'application/json'},
          body: jsonEncode(body),
      );

      /*if (uriResponse.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(uriResponse.body);
        return addEventResponse.from(jsonResponse).ack;
      }*/

    } catch (e) {
      print("catching error $e");
      return false;
    }
  }
}