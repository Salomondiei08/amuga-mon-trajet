import 'package:amuga/providers/events_provider.dart';
import 'package:amuga/providers/initstate_provider.dart';
import 'package:amuga/providers/markers_provider.dart';
import 'package:amuga/providers/routes_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amuga/themes/default.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isInitCalled = false;
  @override
  Widget build(BuildContext context) {
    if (!this.isInitCalled) {
      Future.delayed(Duration.zero, () {
        Provider.of<MarkersProvider>(context, listen: false).initMarkers();
        Provider.of<InitStateProvider>(context, listen: false).percentage = 0.5;
        // now initialise the routes
        Provider.of<RoutesProvider>(context, listen: false).initRoutesPaths();
        // get all the events
        Provider.of<EventProvider>(context, listen: false).getAllEvents();

        print("Future delayed finished ");
        Provider.of<InitStateProvider>(context,
            listen: false).finishInitialization();
      });
      setState(() {
        this.isInitCalled = true;
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kMenuColor, kIconsColor],
            begin: const FractionalOffset(0.0, 1.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'aMUGA',
                style: TextStyle(
                  fontFamily: 'SpaceAge',
                  fontSize: 40.0,
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0),
                child: LinearProgressIndicator(
                  value: Provider.of<MarkersProvider>(context).percentage +
                  Provider.of<RoutesProvider>(context).percentage,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
