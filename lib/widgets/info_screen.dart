import 'package:amuga/db/places_handler.dart';
import 'package:amuga/entities/stop_entity.dart';
import 'package:amuga/themes/default.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';


class InfoScreen extends StatelessWidget {
  const InfoScreen({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: kIconsColor,
      //   actions: [
      //     IconButton(
      //         icon: Icon(
      //           FontAwesomeIcons.bell,
      //           size: 20.0,
      //         ),
      //         onPressed: () {
      //           print('action button pressed');
      //         }),
      //   ],
      // ),
    );
  }
}


Future<Place> showPlacesSearch(BuildContext context) async =>
    await showSearch<Place>(
      context: context,
      delegate: PlacesSearchDelegate(),
    );

class PlacesSearchDelegate extends SearchDelegate<Place> {

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final notifier = Provider.of<JourneyNotifier>(context);
    return FutureBuilder(
        future: notifier.searchPlaces(query),
        builder: (context, AsyncSnapshot<List<Place>> snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: kIconsColor,
              child: ListView(
                children: snapshot.data
                    .map(
                      (p) => (p is Stop)
                          ? StopTile(
                             
                              onTap: () => close(context, p),
                            )
                          : PlaceTile(
                              place: p,
                              onTap: () => close(context, p),
                            ),
                    )
                    .toList(),
              ),
            );
          } else if (snapshot.hasError) {
            return Container(
              color: kIconsColor,
              child: Center(
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return Container(
              color: kMenuColor,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: kIconsColor,
      child: Center(
        child: Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.directions_railway,
              size: 200,
            )),
      ),
    );
  }
}

class JourneyNotifier {
  searchPlaces(String query) {}
}

/// Tile depicting a place
class PlaceTile extends StatelessWidget {
  PlaceTile({this.place, this.onTap});
  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(place.name),
      leading: Icon(Icons.home),
      onTap: onTap,
    );
  }
}

/// Tile depicting a stop
class StopTile extends StatelessWidget {
  StopTile({this.stop, this.onTap});
  final Stop stop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(stop.name),
      leading: const Icon(Icons.train),
      subtitle: Text(stop.typesAsStrings.join(', ')),
      onTap: onTap,
    );
  }
}