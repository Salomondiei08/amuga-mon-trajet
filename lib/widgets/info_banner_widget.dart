import 'dart:math';

import 'package:amuga/data/marker_data.dart';
import 'package:amuga/entities/legs_itinerary_entity.dart';
import 'package:amuga/entities/stop_entity.dart';
import 'package:amuga/network/events_requests.dart';
import 'package:amuga/providers/events_provider.dart';
import 'package:amuga/providers/markers_provider.dart';
import 'package:amuga/providers/path_provider.dart';
import 'package:amuga/themes/default.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import 'custom_show_dialog.dart';

class _EmptyContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      height: 10.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        color: Color(0xffe6e7e9),
      ),
    );
  }
}

class InfoBannerWidget extends StatefulWidget {
  const InfoBannerWidget({Key key}) : super(key: key);

  @override
  _InfoBannerWidgetState createState() => _InfoBannerWidgetState();
}

class _InfoBannerWidgetState extends State<InfoBannerWidget> {
  Map<String, EventRepr> events;
  List<String> eventList;
  String value;

  String getStationDescription(BuildContext context) {
    if (Provider.of<MarkersProvider>(context).routePassingBy != null) {
      return "${Provider.of<MarkersProvider>(context).routePassingBy.length} passent par là";
    } else
      return "";
  }

  String getRouteName(BuildContext context) {
    if (Provider.of<MarkersProvider>(context).routePassingBy != null) {
      return "${Provider.of<MarkersProvider>(context).routePassingBy[0].longName}";
    } else
      return "";
  }

  void selectDeparture(BuildContext context) {
    Provider.of<MarkersProvider>(context, listen: false)
        .changePointToDeparture();
  }

  void selectArrival(BuildContext context) {
    Provider.of<MarkersProvider>(context, listen: false).changePointToArrival();
  }

  void selectFavorite(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Text("Favori"),
            content: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 11.0,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Entrez un nom"),
                      onChanged: (newValue) {
                        Provider.of<EventProvider>(context, listen: false)
                            .favPlace = newValue;
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 5.0, left: 5.0)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.teal),
                        child: Center(
                          child: TextButton(
                            onPressed: () async {
                              // add favorite
                              String name = Provider.of<EventProvider>(context,
                                      listen: false)
                                  .favPlace;
                              var pos = Provider.of<MarkersProvider>(context,
                                      listen: false)
                                  .selectedPoint
                                  .marker
                                  .point;
                              await Provider.of<MarkersProvider>(context,
                                      listen: false)
                                  .addFavorite(name, pos);
                              // update the selected marker
                              Provider.of<MarkersProvider>(context,
                                      listen: false)
                                  .updateSelectedMarker(
                                      MarkerType.FAVORITE_PLACE_MARKER);
                              Navigator.pop(context);
                            },
                            child: Text("Ok",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11.0)),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  void selectReport(BuildContext context) {
    events = Provider.of<EventProvider>(context, listen: false).eventsTitles;
    eventList = events.keys.toList(growable: false);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Text("Signalement"),
            content: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 11.0,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: kIconsColor, width: 1),
                            borderRadius: BorderRadius.circular(15.0)),
                        child: DropdownButton(
                          underline: SizedBox(),
                          onChanged: (newValue) {
                            setState(() {
                              Provider.of<EventProvider>(context, listen: false)
                                  .updateSelectedEvent(newValue);
                            });
                          },
                          items: eventList.map((event) {
                            return DropdownMenuItem(
                              value: event,
                              child: Row(
                                children: [
                                  Icon(events[event].data, size: 15),
                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  VerticalDivider(color: kIconsColor),
                                  Text(
                                    event,
                                    style: TextStyle(fontSize: 11.0),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          value:
                              Provider.of<EventProvider>(context).selectedEvent,
                        ),
                      )),
                  Padding(padding: EdgeInsets.only(right: 5.0, left: 5.0)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.teal),
                        child: Center(
                          child: TextButton(
                            onPressed: () async {
                              print("adding new event !");
                              await EventsHttpRequests().addEvent(
                                  pos: Provider.of<MarkersProvider>(context,
                                          listen: false)
                                      .selectedMarker
                                      .marker
                                      .point,
                                  event: Provider.of<EventProvider>(context,
                                          listen: false)
                                      .eventsTitles[Provider.of<EventProvider>(
                                              context,
                                              listen: false)
                                          .selectedEvent]
                                      .id);
                              Navigator.pop(context);
                            },
                            child: Text("Ok",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11.0)),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget createPointInfoBanner(BuildContext context, double height) {
    var width = MediaQuery.of(context).size.width / 6;
    var myWidth = min(width, height + 10) - 20;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First we have the icon
        Container(
          width: myWidth,
          height: myWidth,
          child: Icon(
            FontAwesomeIcons.thumbtack,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 30),
        // Start button
        MenuButton(
          width: myWidth,
          fn: this.selectDeparture,
          icon: FontAwesomeIcons.solidFlag,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Départ",
        ),
        // end button
        SizedBox(width: 30),
        MenuButton(
          width: myWidth,
          fn: this.selectArrival,
          icon: FontAwesomeIcons.flagCheckered,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Arrivée",
        ),
        SizedBox(width: 30),
        // Favorite button
        MenuButton(
          width: myWidth,
          fn: this.selectFavorite,
          icon: FontAwesomeIcons.solidHeart,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Favori",
        ),
        SizedBox(width: 30),
        // complain button
        MenuButton(
          width: myWidth,
          fn: this.selectReport,
          icon: FontAwesomeIcons.exclamation,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Signaler",
        )
      ],
    );
  }

  Widget createStopInfoBanner(BuildContext context, double height) {
    var width = MediaQuery.of(context).size.width / 6;
    var myWidth = min(width, height + 10) - 20;
    return Row(
      children: [
        // First we have the icon
        Container(
          width: myWidth,
          height: myWidth,
          child: Icon(
            FontAwesomeIcons.busAlt,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 30),
        // Start button
        MenuButton(
          width: myWidth,
          fn: this.selectDeparture,
          icon: FontAwesomeIcons.solidFlag,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Départ",
        ),
        // end button
        SizedBox(width: 30),
        MenuButton(
          width: myWidth,
          fn: this.selectArrival,
          icon: FontAwesomeIcons.flagCheckered,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Arrivée",
        ),
        SizedBox(width: 30),
        // Favorite button
        MenuButton(
          width: myWidth,
          fn: this.selectFavorite,
          icon: FontAwesomeIcons.solidHeart,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Favori",
        ),
        SizedBox(width: 30),
        // complain button
        MenuButton(
          width: myWidth,
          fn: this.selectReport,
          icon: FontAwesomeIcons.exclamation,
          primaryColor: Colors.white,
          secondaryColor: kIconsColor,
          text: "Signaler",
        )
      ],
    );
  }

  Widget _getConveyanceIcon() {
    int step = Provider.of<MarkersProvider>(context,
        listen: false).stepLevelInTravel;
    List<LegInItinerary> stepsInItinerary = Provider.of<MarkersProvider>(context,
        listen: false).stepsInItinerary;

    if (stepsInItinerary[step].mode == "WALK") return Icon(FontAwesomeIcons.walking);
    else if (stepsInItinerary[step].mode == "FERRY") return Icon(FontAwesomeIcons.ship);

    else if (stepsInItinerary[step].agencyName.contains("Woro-woro")) {
      return Icon(FontAwesomeIcons.car, color: Colors.yellow);
    }
    else if (stepsInItinerary[step].agencyName.contains("Gbaka")) {
      return Icon(FontAwesomeIcons.bus, color: Colors.deepPurple);
    }
    else if (stepsInItinerary[step].mode == "BUS") return Icon(FontAwesomeIcons.busAlt);
  }

  Widget createFollowPathBanner(BuildContext context, double height) {
    var width = MediaQuery.of(context).size.width / 6;
    var myWidth = min(width, height + 10) - 10;
    return Row(
      children: [
        // First we have the icon
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _getConveyanceIcon(),
              SizedBox(height: 10.0),
              Icon(FontAwesomeIcons.mapMarkedAlt,
                color: Colors.grey,
              )
            ],
          )
        ),
        Expanded(
          flex: 2,
          child: Center (
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FixedTimeline.tileBuilder(
                  theme: TimelineThemeData(
                    direction: Axis.horizontal,
                    nodePosition: 0,
                    color: Color(0xff989898),
                    connectorTheme: ConnectorThemeData(
                      thickness: 3.0,
                      color: Color(0xffd3d3d3)
                    ),
                    indicatorTheme: IndicatorThemeData(
                      position: 0,
                      size: 20.0,
                    )
                  ),

                  builder: TimelineTileBuilder.connected(
                    itemCount: 2,
                    contentsAlign: ContentsAlign.basic,
                    indicatorBuilder: (context, idx) {
                      if (idx == 0) {
                        return DotIndicator(
                          size: 30.0,
                          color: Color(0xff6ad192),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        );
                      } else {
                        return DotIndicator(
                          size: 30.0,
                          color: Colors.grey,
                          child: Icon(
                            FontAwesomeIcons.circle,
                            color: Colors.white,
                            size: 20.0,
                          )
                        );
                      }
                    },
                    contentsBuilder: (context, index) {
                      int step = Provider.of<MarkersProvider>(context,
                          listen: false).stepLevelInTravel;
                      List<LegInItinerary> stepsInItinerary = Provider.of<MarkersProvider>(context,
                          listen: false).stepsInItinerary;

                      if (index == 0) {
                        return Text(stepsInItinerary[step].from.name.contains("Origin") ?
                            "Départ" : stepsInItinerary[step].from.name, maxLines: 2,
                        style: TextStyle(fontSize: 11.0, color: Color(0xff6ad192)));
                      } else {
                        return Text(stepsInItinerary[step].to.name, maxLines: 2,
                              style: TextStyle(fontSize: 11.0, color: Colors.grey)
                          );
                      }
                    },
                    itemExtentBuilder: (_, __) => 80,
                    connectorBuilder: (_, index, __) {
                      if (index == 0) {
                        return SolidLineConnector(color: Color(0xff6ad192));
                      } else {
                        return SolidLineConnector(color: Colors.grey,);
                      }
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container (
            padding: EdgeInsets.only(right: 20.0),
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: Colors.red
              ),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Provider.of<MarkersProvider>(context,
                        listen: false).endTrackingPosition();
                    // delete the displayed route
                    Provider.of<PathProvider>(context,
                        listen: false).clearPath();
                    // clear all the steps in the itinerary
                    Provider.of<MarkersProvider>(context,
                        listen: false).clearStepsInTheTravel();
                  },
                  child: Text("Stop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.0
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        // Start button

      ],
    );
  }

  String getInfoTitle(BuildContext context) {
    if (Provider.of<MarkersProvider>(context,
        listen: false).inTrackingMode) {
      return "Suivi itinéraire";
    }
    bool isPosSelected =
        Provider.of<MarkersProvider>(context).selectedMarker != null;

    if (isPosSelected) {
      return Provider.of<MarkersProvider>(context).infoMarker;
    } else {
      Stop stop = Provider.of<MarkersProvider>(context).nearestStop;
      if (stop != null)
        return stop.name;
      else
        return "";
    }
  }

  Widget displayContent(BuildContext context, bool isPosSelected, double height) {
    if (Provider.of<MarkersProvider>(context,
        listen: false).inTrackingMode) {
      return createFollowPathBanner(context, height);
    } else {
      if (isPosSelected == true) return createPointInfoBanner(context, height);
      else return createStopInfoBanner(context, height);
    }
  }
  
  Widget displaySubtitle(BuildContext, bool isPosSelected, double width, double height) {
    if (Provider.of<MarkersProvider>(context,
        listen: false).inTrackingMode) {
      int step = Provider.of<MarkersProvider>(context,
          listen: false).stepLevelInTravel;
      List<LegInItinerary> stepsInItinerary = Provider.of<MarkersProvider>(context,
          listen: false).stepsInItinerary;
      String text;
      if (stepsInItinerary[step].headsign != null) {
        text = stepsInItinerary[step].headsign;
      } else {
        text = stepsInItinerary[step].to.name;
      }
      return Text("vers : $text", style: TextStyle(color: kIconsColor,
          fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),);
    } else {
      if (isPosSelected == true) return null;
      else return RouteName(
        width: width,
        height: height * 0.15,
        text: getRouteName(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.2;
    var width = MediaQuery.of(context).size.width;
    bool isPosSelected =
        Provider.of<MarkersProvider>(context).selectedMarker != null;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // margine zone
        Container(height: height * 0.05, color: Colors.transparent),
        // Title color
        Container(
          height: height * 0.15,
          color: Colors.transparent,
          child: Center(
            child: Text(
              getInfoTitle(context),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: kMenuColor),
            ),
          ),
        ),
        SizedBox(height: height * 0.05),
        Container(
          height: height * 0.20,
          color: Colors.white,
          child: displaySubtitle(context, isPosSelected, width, height)
        ),
        // Icons zone
        Container(
            height: height * 0.60,
            color: Colors.white,
            child: displayContent(context, isPosSelected, height)
                ),
      ],
    );
  }
}

class RouteName extends StatelessWidget {
  const RouteName(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.text})
      : super(key: key);

  final double width;
  final double height;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height - 5,
      width: this.width - 50,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular((this.height - 5) / 2)),
          border: Border.all(color: kMenuColor, width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                color: kMenuColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular((this.height - 5) / 2),
                    bottomLeft: Radius.circular((this.height - 5) / 2)),
              ),
              child: Center(
                child: Text(
                  "Route",
                  style: TextStyle(
                      backgroundColor: Colors.transparent,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: Text(
                this.text,
                style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: kIconsColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  const MenuButton(
      {Key key,
      @required this.width,
      @required this.icon,
      @required this.primaryColor,
      @required this.secondaryColor,
      @required this.fn,
      @required this.text})
      : super(key: key);

  final double width;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final Function fn;
  final String text;

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  Color primary;
  Color secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        OutlinedButton(
          onPressed: () {
            widget.fn(context);
            //flipColors();
          },
          child: Icon(
            widget.icon,
            color: primary,
            size: 14.0,
          ),
          style: OutlinedButton.styleFrom(
              minimumSize: Size(widget.width, widget.width),
              side: BorderSide(color: primary),
              shape: CircleBorder(),
              backgroundColor: secondary),
        ),
        //Padding(padding: EdgeInsets.only(top: 5)),
        Center(
          child: Text(
            widget.text,
            style: TextStyle(
                color: kIconsColor,
                fontWeight: FontWeight.bold,
                fontSize: 9.0),
          ),
        )
      ],
    ));
  }

  @override
  void initState() {
    primary = widget.primaryColor;
    secondary = widget.secondaryColor;
  }

  void flipColors() {
    Color temp = primary;
    setState(() {
      primary = secondary;
      secondary = temp;
    });
  }
}
