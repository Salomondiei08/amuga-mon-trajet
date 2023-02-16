import 'package:amuga/entities/plan_response_entity.dart';
import 'package:amuga/entities/travel_itinerary_entity.dart';
import 'package:amuga/providers/markers_provider.dart';
import 'package:amuga/providers/path_provider.dart';
import 'package:amuga/widgets/custom_show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:amuga/themes/default.dart' as defaultTheme;
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

class PlanResponseWidget extends StatefulWidget {
  @override
  _PlanResponseWidgetState createState() => _PlanResponseWidgetState();
  final PlanResponseEntity responseEntity;
  Function startTravel;

  PlanResponseWidget({Key key, this.responseEntity, this.startTravel});
}

class _PlanResponseWidgetState extends State<PlanResponseWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.responseEntity == null) {
      return Container();
    } else {
      return Container(
        child: Column(
          children: [
            Text(
                "${widget.responseEntity.itineraries.length} résultat(s) trouvés"),
            SizedBox(
              height: 20.0,
            ),
            ListView.builder(
                primary: false,
                //physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.responseEntity.itineraries.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return ListViewItemWidget(
                    widget: widget,
                    itinerary: widget.responseEntity.itineraries[index],
                    index: index,
                    startTravel: widget.startTravel,
                  );
                }),
            /*ListView(
              shrinkWrap: true,

              children: [
                ListViewItemWidget(widget: widget, itinerary: widget.responseEntity.itineraries[0],)
              ],
            ),*/
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    for (int i = 0; i < widget.responseEntity.itineraries.length; i++) {
      if (widget.responseEntity.itineraries[i].getNbBus() == 0) {
        widget.responseEntity.itineraries.removeAt(i);
      }
    }
  }
}

class ListViewItemWidget extends StatelessWidget {
  const ListViewItemWidget({
    Key key,
    @required this.widget,
    @required this.itinerary,
    @required this.index,
    @required this.startTravel
  }) : super(key: key);

  final PlanResponseWidget widget;
  final TravelItinerary itinerary;
  final int index;
  final Function startTravel;

  Widget _getConveyanceIcon(int idx) {
    if (itinerary.legs[idx].mode == "WALK") return Icon(FontAwesomeIcons.walking);
    else if (itinerary.legs[idx].mode == "FERRY") return Icon(FontAwesomeIcons.ship);

    else if (itinerary.legs[idx].agencyName.contains("Woro-woro")) {
      return Icon(FontAwesomeIcons.car, color: Colors.yellow);
    }
    else if (itinerary.legs[idx].agencyName.contains("Gbaka")) {
      return Icon(FontAwesomeIcons.bus, color: Colors.deepPurple);
    }
    else if (itinerary.legs[idx].mode == "BUS") return Icon(FontAwesomeIcons.busAlt);
  }

  String _getStepDuration(int idx) {
    var t = itinerary.legs[idx].endTime - itinerary.legs[idx].startTime;
    return "${(t / 60000).truncate()} mins";
  }

  Widget displayTravelDetails(BuildContext context) {
    //int now = itinerary.startTime - DateTime.now().millisecondsSinceEpoch;

    return ListView.builder(
      itemCount: itinerary.legs.length,
      itemBuilder: (context, idx) {
        return Center(
          child: Container(
            child: Card(
              margin: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(flex: 1,
                          child: _getConveyanceIcon(idx),
                        ),
                        Expanded(flex: 3,
                          child: Column(
                            children: [
                              Text(itinerary.legs[idx].mode != "WALK"
                                  ? itinerary.legs[idx].agencyName
                                  : ""
                                ,
                                style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
                              ),
                              Text(itinerary.legs[idx].headsign != null
                                  ? "➡️ ${itinerary.legs[idx].headsign}"
                                  : "",
                                style: TextStyle(fontSize: 9.0)
                              )
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                  Divider(height: 1.0),
                  Padding(padding: const EdgeInsets.all(10.0),
                    child: FixedTimeline.tileBuilder(
                      theme: TimelineThemeData(
                        nodePosition: 0,
                        color: Color(0xff989898),
                        indicatorTheme: IndicatorThemeData(
                          position: 0,
                          size: 20.0,
                        ),
                        connectorTheme: ConnectorThemeData(
                          thickness: 2.5,
                        ),
                      ),

                      builder: TimelineTileBuilder.connected(
                          itemCount: 2,//itinerary.legs[idx].steps.length,
                          contentsAlign: ContentsAlign.basic,

                          indicatorBuilder: (context, idx) {
                            return OutlinedDotIndicator(
                              borderWidth: 1.5,
                              size: 10.0,
                            );
                          },

                          connectorBuilder: (context, idx, type) {
                            return DashedLineConnector(

                            );
                          },
                          contentsBuilder: (context, index) {
                            if (index == 0) return Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                              child: Text(itinerary.legs[idx].from.name,
                                  style: TextStyle(fontSize: 9.0)
                              ),
                            );
                            else return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(itinerary.legs[idx].to.name,
                                  style: TextStyle(fontSize: 9.0)
                              ),
                            );
                          }

                      ),
                    ),
                  ),
                  Divider(height: 1.0),
                  Padding(padding: const EdgeInsets.all(10.0),
                    child: Row (
                      children: [
                        Text("Durée: ${_getStepDuration(idx)}",
                          style: TextStyle(fontSize: 9.0),
                        ),
                        VerticalDivider(),
                        Text("Distance: ${itinerary.legs[idx].distance.truncate()} m",
                          style: TextStyle(fontSize: 9.0),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget displayTravelTimeline(BuildContext context) {
    int now = itinerary.startTime - DateTime.now().millisecondsSinceEpoch;

    return Timeline.tileBuilder(
        theme: TimelineThemeData(
          connectorTheme: ConnectorThemeData(
            thickness: 3.0
          )
        ),
        builder: TimelineTileBuilder.connected(
            contentsAlign: ContentsAlign.alternating,
            indicatorBuilder: (context, idx) {
              if (idx == 0)
                return Icon(
                  FontAwesomeIcons.solidDotCircle,
                  color: defaultTheme.kMenuColor,
                );

              if (idx == itinerary.legs.length * 2 - 1) {
                return Icon(
                  FontAwesomeIcons.dotCircle,
                  color: defaultTheme.kIconsColor,
                );
              }
              return Icon(
                FontAwesomeIcons.circle,
                color: idx % 2 == 0
                    ? defaultTheme.kMenuColor
                    : defaultTheme.kIconsColor,
              );
            },
            connectorBuilder: (context, idx, type) {
              var gradientColors = [
                defaultTheme.kMenuColor,
                defaultTheme.kIconsColor
              ];
              //return SolidLineConnector(color: Colors.red,);
              return DecoratedLineConnector(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                ),
              );
            },
            oppositeContentsBuilder: (context, idx) {
              Widget icon;
              if (itinerary.legs[idx ~/ 2].mode == "WALK") {

                icon = Column(
                  children: [
                    Icon(FontAwesomeIcons.walking),
                    Text("${itinerary.legs[idx ~/ 2].distance.toInt()} m",
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                );
              } else {
                if (itinerary.legs[idx ~/ 2].agencyName.contains("Woro-woro")) {
                  icon = Column(
                    children: [
                      Icon(FontAwesomeIcons.car, color: Colors.yellow),
                      Text(itinerary.legs[idx ~/ 2].agencyName,
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  );
                } else if (itinerary.legs[idx ~/ 2].agencyName.contains("Gbaka")) {
                  icon = Column(
                    children: [
                      Icon(FontAwesomeIcons.bus, color: Colors.deepPurple),
                      Text(itinerary.legs[idx ~/ 2].agencyName,
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  );
                } else {
                  //var bus_num = await RouteHandler().getRouteById(itinerary.legs[idx ~/ 2].route)
                  icon = Column(
                    children: [
                      Icon(FontAwesomeIcons.busAlt),
                      Text(itinerary.legs[idx ~/ 2].agencyName,
                        style: TextStyle(fontSize: 10),
                      ),

                    ],
                  );
                }
              }
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                    child: icon),
              );
            },
            contentsBuilder: (context, idx) {
              Widget txt;
              if (idx == 0) {
                txt = Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Départ",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text("dans ${(now / 60000).truncate()} mins",
                      style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                    )
                  ],
                );
              }
              else if (idx % 2 == 0) {
                txt = Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("🚏 ${itinerary.legs[idx ~/ 2].from.name}",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(itinerary.legs[idx ~/ 2].headsign != null
                        ? "➡️ ${itinerary.legs[idx ~/ 2].headsign}"
                        : ""
                      ,
                      style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                    )
                  ],
                );
              } else {
                txt = Text(itinerary.legs[idx ~/ 2].to.name,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
              }
              return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: txt
                  );
                //Text('Timeline Event $index'),
            },
            itemCount: itinerary.legs.length * 2));
  }

  void showRouteDetailDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 1.5,
              color: Colors.white,
              child: Column(
                children: [
                  /* header of the dialog */
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Center(
                        child: Text(
                          "Détail du trajet ${index + 1}",
                          style: TextStyle(
                              color: defaultTheme.kIconsColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  /* body of the dialog */
                  Expanded(
                    flex: 7,
                    child: Container(
                      color: Colors.white,
                      //child: displayTravelTimeline(context),
                      child: displayTravelDetails(context),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  /* bottom of the dialog */
                  Expanded(
                    flex: 1,
                    child: Container(
                        child: Row(
                      children: [
                        Expanded(child: Container(), flex: 1),
                        Expanded(
                          child: Container(
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: Colors.teal[200]),
                              child: Center(
                                child: TextButton(
                                  onPressed: ()  {
                                    Navigator.pop(context);
                                  },
                                  child: Text("annuler",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: 5.0, left: 5.0)),
                        Expanded(
                            child: Container(
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    color: Colors.teal),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      if (Provider.of<MarkersProvider>(context,
                                        listen: false).gpsActivated == false) {
                                        // gps not activated
                                        Navigator.pop(context);
                                        await Provider.of<PathProvider>(context,
                                            listen: false).displayPathForTravel(itinerary);
                                        showDialog(context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                            title: const Text('Information'),
                                            content: const Text('Vous devez activer le GPS pour suivre le trajet en temps réel'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, 'OK'),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (Provider.of<MarkersProvider>(context,
                                        listen: false).gpsActivated == true &&
                                          Provider.of<MarkersProvider>(context,
                                            listen: false).positionGaranted == false) {
                                        Navigator.pop(context);
                                        await Provider.of<PathProvider>(context,
                                            listen: false).displayPathForTravel(itinerary);
                                        showDialog(context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                            title: const Text('Information'),
                                            content: const Text('Vous devez être à Abidjan afin de suivre le trajet en temps réel'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, 'OK'),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );

                                      }
                                      else {
                                        await Provider.of<PathProvider>(context,
                                            listen: false).displayPathForTravel(itinerary);
                                        await Provider.of<MarkersProvider>(context,
                                            listen: false).storeStepsInTheTravel(itinerary);
                                        Navigator.pop(context);
                                        this.startTravel(context);
                                      }
                                    },
                                    child: Text("démarrer",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11.0)),
                                  ),
                                ),
                              ),
                            ),
                            flex: 1)
                      ],
                    )),
                  )
                ],
              ),
            ),
          );
        });
  }

  List<Widget> displayConveyances(BuildContext context) {
    List<int> nbConveyance = itinerary.getNbConveyance();
    int nbBus = nbConveyance[0],
        nbWoro = nbConveyance[1],
        nbGbaka = nbConveyance[2],
        nbFerry = nbConveyance[3];

    List<Widget> widgets = [];

    if (nbBus > 0) {
      widgets.add(
          ItineraryInfo(
            widget: widget,
            infoText: "$nbBus bus",
            icon: FontAwesomeIcons.busAlt)
      );
    }

    if (nbWoro > 0) {
      widgets.add(
          ItineraryInfo(
            widget: widget,
            infoText: "$nbWoro Woro",
            icon: FontAwesomeIcons.car,
            iconColor: Colors.yellow,
          )
      );
    }

    if (nbGbaka > 0) {
      widgets.add(
          ItineraryInfo(
            widget: widget,
            infoText: "$nbGbaka Gbaka",
            icon: FontAwesomeIcons.bus,
            iconColor: Colors.deepPurple,
          )
      );
    }

    if (nbFerry > 0) {
      widgets.add(
          ItineraryInfo(
              widget: widget,
              infoText: "$nbFerry ferry",
              icon: FontAwesomeIcons.ship)
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> conveyances = displayConveyances(context);

    return Container(
      padding: EdgeInsets.all(15.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            /* itinerary duration */
            Expanded(
              child: ItineraryInfo(
                widget: widget,
                infoText: "${(itinerary.duration / 60).truncate()} mins",
                icon: FontAwesomeIcons.clock,
              ),
              flex: 1,
            ),
            /* itinerary walk distance */
            VerticalDivider(
              color: Colors.grey,
            ),
            Expanded(
              child: ItineraryInfo(
                widget: widget,
                infoText: "${itinerary.walkDistance.toInt()} m",
                icon: FontAwesomeIcons.walking,
              ),
              flex: 1,
            ),
            VerticalDivider(
              color: Colors.grey,
            ),
            Expanded(
              child: (conveyances != null && conveyances.length > 0)
                  ? conveyances[0] : Container(),
              flex: 1,
            ),
            Expanded(
              child: (conveyances != null && conveyances.length > 1)
                  ? conveyances[1] : Container(),
              flex: 1,
            ),
            /* itinerary */
            Expanded(
              child: (conveyances != null && conveyances.length > 2)
                  ? conveyances[2] : Container(),
              flex: 1,
            ),
            Expanded(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Colors.teal),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      print("display details of the plan");
                      showRouteDetailDialog(context);
                    },
                    child: Text("détails",
                        style: TextStyle(color: Colors.white, fontSize: 11.0)),
                  ),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class ItineraryInfo extends StatelessWidget {
  const ItineraryInfo(
      {Key key,
      @required this.widget,
      @required this.infoText,
      @required this.icon,
        this.iconColor = defaultTheme.kIconsColor
      })
      : super(key: key);

  final PlanResponseWidget widget;
  final String infoText;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          //FontAwesomeIcons.clock,
          this.icon,
          color: this.iconColor,
          size: 25.0,
        ),
        Padding(padding: EdgeInsets.only(top: 5)),
        Center(
          child: Text(
            this.infoText,
            style: TextStyle(
                color: defaultTheme.kIconsColor,
                fontWeight: FontWeight.bold,
                fontSize: 10.0),
          ),
        )
      ],
    );
  }
}
