import 'package:amuga/entities/plan_response_entity.dart';
import 'package:amuga/network/plan_travel.dart';
import 'package:amuga/providers/markers_provider.dart';
import 'package:amuga/widgets/plan_response_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import "package:latlong/latlong.dart" as latLng;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:amuga/themes/default.dart';
import 'package:provider/provider.dart';

class SearchPathWidget extends StatefulWidget {
  @override
  _SearchPathWidgetState createState() => _SearchPathWidgetState();
  ScrollController scrollController;

  Function startTravel;
  latLng.LatLng myPos;
  String fromString;
  String arrivalString;

  SearchPathWidget(
      {Key key, this.scrollController,
        this.myPos,
        this.startTravel,
        this.fromString,
        this.arrivalString
      })
      : super(key: key);
}

class _SearchPathWidgetState extends State<SearchPathWidget> {
  var _fromSuggestionTextFieldController; //= new TextEditingController();
  var _toSuggestionTextFieldController; //= new TextEditingController();
  PlanResponseEntity _planResponseEntity;
  bool _isLoading;
  bool _resultFound = false;

  @override
  void initState() {
    setState(() {
      _isLoading = false;
      _fromSuggestionTextFieldController =
      new TextEditingController(text: widget.fromString);
      _toSuggestionTextFieldController = new TextEditingController(
        text: widget.arrivalString
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0))),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                            child: TextButton(
                              onPressed: () {},
                              child: Icon(FontAwesomeIcons.dotCircle,
                                  color: kIconsColor),
                            ),
                          ),
                          flex: 1),
                      Expanded(
                        child: AutoCompleteTextField(
                          controller: _fromSuggestionTextFieldController,
                          clearOnSubmit: false,
                          suggestions: Provider.of<MarkersProvider>(context).getPlaces(),
                          itemFilter: (item, query) {
                            return item
                                .toLowerCase()
                                .contains(query.toLowerCase());
                          },
                          itemSubmitted: (item) {
                            _fromSuggestionTextFieldController.text = item;
                          },
                          itemBuilder: (context, item) {
                            return Text(item, style: TextStyle(fontSize: 10), maxLines: 2);
                          },
                          style: TextStyle(fontSize: 11.0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Départ',
                          ),
                        ),
                        flex: 3,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(0),
                          child: TextButton(
                            onPressed: () {
                              _fromSuggestionTextFieldController.text =
                                  "Ma position";
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.crosshairs,
                                    color: kIconsColor),
                                SizedBox(height: 5.0),
                                Text("Ma position",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: kIconsColor
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        flex: 1,
                      )
                    ],
                  ),
                  // vertical ellipse icon
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                            child: Icon(FontAwesomeIcons.ellipsisV,
                                color: kIconsColor, size: 10,),
                          ),
                          flex: 1),
                      Expanded(child: Container(), flex: 4)
                    ],
                  ),
                  // second row for the input
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                            child: TextButton(
                                onPressed: () {},
                                child: Icon(FontAwesomeIcons.solidDotCircle,
                                    color: kIconsColor)),
                          ),
                          flex: 1),
                      Expanded(
                        child: AutoCompleteTextField(
                          controller: _toSuggestionTextFieldController,
                          clearOnSubmit: false,
                          suggestions: Provider.of<MarkersProvider>(context).getPlaces(),
                          itemFilter: (item, query) {
                            return item
                                .toLowerCase()
                                .contains(query.toLowerCase());
                          },
                          itemSubmitted: (item) {
                            _toSuggestionTextFieldController.text = item;
                          },
                          itemBuilder: (context, item) {
                            return Text(item, style: TextStyle(fontSize: 10.0), maxLines: 2);
                          },
                          style: TextStyle(fontSize: 11.0),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Arrivée',
                          ),
                        ),
                        flex: 3,
                      ),
                      // send icon
                      Expanded(
                        child: Container(),
                        flex: 1,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(padding: EdgeInsets.only(right: 20)),
                      Container(
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0)),
                              color: kIconsColor),
                          child: Center(
                            child: TextButton(
                              onPressed: () async {
                                if (_fromSuggestionTextFieldController.text == ""
                                    || _toSuggestionTextFieldController.text == "") {
                                  return;
                                }
                                print("Getting the path from the server");
                                print(
                                    "from ${_fromSuggestionTextFieldController.text}");
                                print(
                                    "to ${_toSuggestionTextFieldController.text}");
                                TravelHttpRequests travelHttpRequests =
                                TravelHttpRequests();
                                latLng.LatLng start =
                                _fromSuggestionTextFieldController.text ==
                                    "Ma position"
                                    ? widget.myPos
                                    : Provider.of<MarkersProvider>(context, listen: false).places[
                                _fromSuggestionTextFieldController
                                    .text];

                                setState(() {
                                  _isLoading = true;
                                });
                                PlanResponseEntity planResponseEntity =
                                await travelHttpRequests.getTravelResults(
                                    start,
                                    Provider.of<MarkersProvider>(context, listen: false).places[
                                    _toSuggestionTextFieldController
                                        .text]);
                                setState(() {
                                  _planResponseEntity = planResponseEntity;
                                  _isLoading = false;
                                });

                                if (_planResponseEntity != null &&
                                    _planResponseEntity.itineraries != null) {
                                  setState(() {
                                    _resultFound = true;
                                  });
                                }
                              },
                              child: Text("Lancer la recherche",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11.0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(right: 20)),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 60,
                    endIndent: 60,
                  ),
                  Visibility(
                    visible: this._resultFound,
                    child: PlanResponseWidget(
                      responseEntity: _planResponseEntity,
                      startTravel: widget.startTravel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: this._isLoading,
          child: Container(
            color: Colors.grey.withOpacity(0.6),
            child: Center(
              //child: SpinKitCubeGrid(
              child: SpinKitFadingCircle(
                color: kIconsColor,
                size: 120.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
