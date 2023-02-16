import 'package:amuga/data/marker_data.dart';
import 'package:amuga/db/places_handler.dart';
import 'package:amuga/entities/route_map_entity.dart';
import 'package:amuga/entities/stop_entity.dart';
import 'package:amuga/helper/distances.dart';
import 'package:amuga/providers/events_provider.dart';
import 'package:amuga/providers/markers_provider.dart';
import 'package:amuga/providers/path_provider.dart';
import 'package:amuga/widgets/info_banner_widget.dart';
import 'package:amuga/widgets/search_path_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:amuga/themes/default.dart' as defaultTheme;
import 'package:amuga/params/default.dart';
import 'package:vibration/vibration.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}

class AmugaMap extends StatefulWidget {
  @override
  _AmugaMapState createState() => _AmugaMapState();
}

enum WidgetToDisplay { STOP_INFO, PATH_SEARCH }

class _AmugaMapState extends State<AmugaMap> with TickerProviderStateMixin {
  bool activateSearchWidget = false;
  double mapZoom = kStartZoom;
  double maxZoom = kMaxZoom;
  MapController mapController;
  WidgetToDisplay widgetToDisplay;

  AnimationController _animationController;
  Animation<double> _heightFactorAnimation;
  final double collapsedHeightFactor = 0.7;
  final double expandedHeightFactor = 0.15;
  bool isAnimationCompleted = false;

  void onBottomPartTap() {
    setState(() {
      if (isAnimationCompleted) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      isAnimationCompleted = !isAnimationCompleted;
    });
  }

  void goToFirstPointIntheTravel(BuildContext context) async {
    onBottomPartTap();
    _animatedMapMove(
        Provider.of<PathProvider>(context, listen: false).paths[0].points[0],
        mapZoom);

    // start the tracking here
    if (Provider.of<MarkersProvider>(context, listen: false).positionGaranted) {
      // here we need to check if the first position is not far from
      // my actual position
      var firstPos =
          Provider.of<PathProvider>(context, listen: false).paths[0].points[0];
      var myPos =
          Provider.of<MarkersProvider>(context, listen: false).myPosition;
      var dist = distanceBetweenPos(firstPos.longitude, firstPos.latitude,
          myPos.longitude, myPos.latitude);
      // if the first position in the path is in 200 m of my current position
      // then I can listen to the change of my current position
      if (dist <= 200) {
        // vibrate the phone as the client asked for !
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate();
        }
        Provider.of<MarkersProvider>(context, listen: false)
            .startTrackingPosition();
      }
    }
  }

  void _animatedMapMove(latLng.LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    final _rotationTween = Tween<double>(begin: mapController.rotation, end: 0);

    // rotate the map to be in the first rotation value
    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.moveAndRotate(
          latLng.LatLng(
              _latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation),
          _rotationTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    widgetToDisplay = WidgetToDisplay.STOP_INFO;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _heightFactorAnimation =
        Tween<double>(begin: collapsedHeightFactor, end: expandedHeightFactor)
            .animate(_animationController);
  }

  void displayPathSearchWidget() {
    setState(() {
      widgetToDisplay = WidgetToDisplay.PATH_SEARCH;
    });
  }

  void displayInfoBusWidget() {
    setState(() {
      widgetToDisplay = WidgetToDisplay.STOP_INFO;
    });
  }

  List<Marker> getStopsMarkers(BuildContext context, zoom) {
    if (zoom >= kMinZoomStationDisplay) {
      return Provider.of<MarkersProvider>(context).stopsMarkers;
    } else
      return [];
  }

  List<Marker> getSelectedPointMarker(BuildContext context) {
    if (Provider.of<MarkersProvider>(context).selectedPoint != null) {
      return [Provider.of<MarkersProvider>(context).selectedPoint.marker];
    } else
      return [];
  }

  List<Marker> getSelectedStartMarker(BuildContext context) {
    if (Provider.of<MarkersProvider>(context).selectedStart != null) {
      return [Provider.of<MarkersProvider>(context).selectedStart.marker];
    } else
      return [];
  }

  List<Marker> getSelectedEndMarker(BuildContext context) {
    if (Provider.of<MarkersProvider>(context).selectedEnd != null) {
      return [Provider.of<MarkersProvider>(context).selectedEnd.marker];
    } else
      return [];
  }

  List<Marker> getMyPositionMarker(BuildContext context) {
    if (Provider.of<MarkersProvider>(context).actualPosition != null) {
      return [Provider.of<MarkersProvider>(context).actualPosition.marker];
    } else
      return [];
  }

  List<Marker> getFavoritsMarkers(BuildContext context) {
    return Provider.of<MarkersProvider>(context).favoritsMarkers;
  }

  List<Marker> getEventsMarkers(BuildContext context) {
    return Provider.of<EventProvider>(context).eventsMarkers;
  }

  Widget getWidget(BuildContext context) {
    double zoom = mapZoom;
    return Stack(
      fit: StackFit.expand,
      children: [
        FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: _heightFactorAnimation.value,
          child: Stack(
            children: [
              Provider.of<MarkersProvider>(context, listen: false)
                          .initFinished ==
                      false
                  ? Container(
                      child: Center(
                        child: Text("Chargement..."),
                      ),
                    )
                  : FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        center:
                            Provider.of<MarkersProvider>(context, listen: false)
                                .myPosition,
                        zoom: mapZoom,
                        maxZoom: maxZoom,
                        onPositionChanged: (pos, flag) {
                          if ((pos.zoom >= kMinZoomStationDisplay &&
                                  zoom <= kMinZoomStationDisplay) ||
                              (pos.zoom <= kMinZoomStationDisplay &&
                                  zoom >= kMinZoomStationDisplay)) {
                            setState(() {
                              mapZoom = pos.zoom;
                            });
                          }
                          zoom = pos.zoom;

                          //mapController.rotate(mapController.rotation);
                        },
                        onTap: (pos) async {
                          // first check if we are in tracking mode
                          if (!Provider.of<MarkersProvider>(context,
                                  listen: false)
                              .inTrackingMode) {
                            Stop nearest = Provider.of<MarkersProvider>(context,
                                    listen: false)
                                .findNearesStop(pos, 30.0);

                            if (nearest != null) {
                              // update selected marker
                              Provider.of<MarkersProvider>(context,
                                      listen: false)
                                  .updateSelectedMarker(MarkerType.STOP_MARKER);
                              // delete the temporary position in the map
                              Provider.of<MarkersProvider>(context,
                                      listen: false)
                                  .deleteTemporaryMarker();
                              // delete the start marker
                              Provider.of<MarkersProvider>(context,
                                      listen: false)
                                  .deleteSelectedStart();
                              // delete the end marker
                              Provider.of<MarkersProvider>(context,
                                      listen: false)
                                  .deleteSelectedEnd();
                              // get all the road passing by this stop
                              List<RouteMap> routes =
                                  await Provider.of<MarkersProvider>(context,
                                          listen: false)
                                      .getRoutePassingBy(nearest.id);
                              // now display the first route
                              if (routes != null && routes.length > 0) {
                                Provider.of<PathProvider>(context,
                                        listen: false)
                                    .displayRoutePath(routes[0].id);
                              }
                            } else {
                              // get nearest place
                              Place nearestPlace = Provider.of<MarkersProvider>(
                                      context,
                                      listen: false)
                                  .findNearestFavorit(pos, 30);
                              if (nearestPlace != null) {
                                Provider.of<MarkersProvider>(context,
                                        listen: false)
                                    .updateSelectedMarker(
                                        MarkerType.FAVORITE_PLACE_MARKER);
                              } else {
                                // add temporary position in the map
                                Provider.of<MarkersProvider>(context,
                                        listen: false)
                                    .updateTemporaryMarker(pos);
                                // update the marker in the map
                                Provider.of<MarkersProvider>(context,
                                        listen: false)
                                    .updateSelectedMarker(
                                        MarkerType.TEMPORARY_MARKER);
                                // delete the selected routes
                                Provider.of<MarkersProvider>(context,
                                        listen: false)
                                    .deleteRoutePassingBy();
                                // delete the displayed route
                                Provider.of<PathProvider>(context,
                                        listen: false)
                                    .clearPath();
                              }
                            }
                          }
                        },
                      ),
                      layers: [
                        TileLayerOptions(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            //subdomains: ['a', 'b', 'c'],
                            subdomains: ['a'],
                            tileProvider: const CachedTileProvider()),
                        PolylineLayerOptions(
                            polylines: Provider.of<PathProvider>(context).paths,
                            polylineCulling: true),
                        MarkerLayerOptions(
                            markers: getStopsMarkers(context, zoom)),
                        MarkerLayerOptions(
                            markers: getSelectedPointMarker(context)),
                        MarkerLayerOptions(
                            markers: getFavoritsMarkers(context)),
                        MarkerLayerOptions(
                            markers: getMyPositionMarker(context)),
                        MarkerLayerOptions(
                            markers: getSelectedStartMarker(context)),
                        MarkerLayerOptions(
                            markers: getSelectedEndMarker(context)),
                        MarkerLayerOptions(markers: getEventsMarkers(context))
                      ],
                    ),
              Positioned(
                bottom: 100.0,
                right: 10.0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white70, shape: BoxShape.circle),
                  child: TextButton(
                    onPressed: () async {
                      setState(() {
                        mapZoom = maxZoom;
                      });

                      await Provider.of<MarkersProvider>(context, listen: false)
                          .updateMyPosition();

                      _animatedMapMove(
                          Provider.of<MarkersProvider>(context, listen: false)
                              .myPosition,
                          mapZoom);
                      // update the selected marker
                      Provider.of<MarkersProvider>(context, listen: false)
                          .updateSelectedMarker(MarkerType.MY_POSITION_MARKER);
                    },
                    child: Icon(
                      FontAwesomeIcons.mapMarkerAlt,
                      color: defaultTheme.kIconsColor,
                      size: 30.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 150.0,
                right: 10.0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white70, shape: BoxShape.circle),
                  child: TextButton(
                    onPressed: () {
                      if (mapZoom + 1 < kMaxZoom) {
                        setState(() {
                          mapZoom = mapZoom + 1;
                        });
                        //mapController.center
                        _animatedMapMove(mapController.center, mapZoom);
                      }
                    },
                    child: Icon(FontAwesomeIcons.searchPlus,
                        color: defaultTheme.kIconsColor, size: 25.0),
                  ),
                ),
              ),
              Positioned(
                bottom: 200.0,
                right: 10.0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white70, shape: BoxShape.circle),
                  child: TextButton(
                    onPressed: () {
                      if (mapZoom - 1 > kMinZoom) {
                        setState(() {
                          mapZoom = mapZoom - 1;
                        });
                        _animatedMapMove(mapController.center, mapZoom);
                      }
                    },
                    child: Icon(
                      FontAwesomeIcons.searchMinus,
                      color: defaultTheme.kIconsColor,
                      size: 25.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        FractionallySizedBox(
          alignment: Alignment.bottomCenter,
          //heightFactor: 1.05 - _heightFactorAnimation.value,
          heightFactor: 1 - _heightFactorAnimation.value,
          child: Container(
            child: this.isAnimationCompleted
                ? SearchPathWidget(
                    myPos: Provider.of<MarkersProvider>(context, listen: false)
                        .myPosition,
                    startTravel: this.goToFirstPointIntheTravel,
                    fromString:
                        Provider.of<MarkersProvider>(context, listen: false)
                                    .selectedStart !=
                                null
                            ? "Départ choisi"
                            : null,
                    arrivalString:
                        Provider.of<MarkersProvider>(context, listen: false)
                                    .selectedEnd !=
                                null
                            ? "Arrivée choisie"
                            : null,
                  )
                : InfoBannerWidget(),
            //Container(color: Colors.red),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
          ),
        ),
        FractionallySizedBox(
          alignment: Alignment.bottomCenter,
          heightFactor: 0.09,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            height: 70,
            child: Stack(
              children: [
                Center(
                  child: Divider(
                    height: 20,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.teal,
                  ),
                ),
                Center(
                  child: TextButton(
                      onPressed: () {
                        // check if we are in tracking mode before
                        if (Provider.of<MarkersProvider>(context, listen: false)
                            .inTrackingMode) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Information'),
                              content: const Text(
                                  'Vous devez arrêter le suivi du trajet en cours avant de démarrer un nouveau'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          onBottomPartTap();
                        }
                      },
                      child: Container(
                        height: 30,
                        width: 200,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            color: Colors.teal),
                        child: Center(
                          child: Text(
                            this.isAnimationCompleted
                                ? "Annuler"
                                : "Nouveau trajet",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, widget) {
        return getWidget(context);
      },
    );
  }
}
