import 'dart:convert';
import 'dart:math' as math;
import 'package:amuga/helper/distances.dart';
import 'package:amuga/providers/events_provider.dart';
import 'package:amuga/providers/markers_provider.dart';
import 'package:amuga/themes/default.dart' as defaultTheme;
import 'package:amuga/widgets/custom_show_dialog.dart';
import 'package:amuga/widgets/info_screen.dart';
import 'package:amuga/widgets/story_board_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:amuga/themes/default.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:package_info/package_info.dart';

class CustomMenuDrawer extends StatefulWidget {
  final Widget child;

  const CustomMenuDrawer({Key key, this.child}) : super(key: key);

  static CustomMenuDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<CustomMenuDrawerState>();

  @override
  CustomMenuDrawerState createState() => new CustomMenuDrawerState();
}

class CustomMenuDrawerState extends State<CustomMenuDrawer>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  //bool _canBeDragged = false;
  final double maxSlide = 300.0;
  bool _isLoading;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    _isLoading = false;
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _initPackageInfo();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  void showContentDialog(
      BuildContext context, String title, width, height, Widget content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: Center(
                child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  color: kMenuColor),
            )),
            content: Container(
              width: MediaQuery.of(context).size.width / width,
              height: MediaQuery.of(context).size.height / height,
              color: Colors.white,
              child: content,
            ),
          );
        });
  }

  void showEventsList(BuildContext context) async {
    //List<EventEntity> events = await EventsHttpRequests().getAllEvents();
    setState(() {
      _isLoading = true;
    });
    await Provider.of<EventProvider>(context, listen: false).getAllEvents();
    setState(() {
      _isLoading = false;
    });
    var eventProvider = Provider.of<EventProvider>(context, listen: false);
    Widget content;
    if (eventProvider.events.length == 0) {
      content = Container(
        child: Center(
          child: Text(
            "Pas d'incidents enregistrés",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    } else {
      content = Container(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: eventProvider.events.length,
          itemBuilder: (BuildContext ctx, int index) {
            var mypos =
                Provider.of<MarkersProvider>(context, listen: false).myPosition;

            var dist = distanceBetweenPos(
                    mypos.longitude,
                    mypos.latitude,
                    eventProvider.events[index].lon,
                    eventProvider.events[index].lat)
                .toInt();
            return Row(
              children: [
                // icon
                Expanded(
                  flex: 1,
                  child: Icon(
                    eventProvider.getEventReprByIdx(index).data,
                    color: defaultTheme.kIconsColor,
                    size: 25.0,
                  ),
                ),
                // title
                Expanded(
                  flex: 2,
                  child: Text(
                    eventProvider.getEventTitleByIdx(index),
                    style: TextStyle(
                        color: defaultTheme.kIconsColor, fontSize: 11.0),
                  ),
                ),
                // distance
                Expanded(
                  flex: 2,
                  child: Text(
                    "A $dist m de vous",
                    style: TextStyle(
                        color: defaultTheme.kIconsColor, fontSize: 11.0),
                  ),
                )
              ],
            );
          },
        ),
      );
    }

    showContentDialog(context, "Liste des évènements", 1.2, 2.4, content);
  }

  void showParams(BuildContext context) {
    showContentDialog(context, "Paramètres", 1.2, 2.4, Container());
  }

  void showContacts(BuildContext context) {
    showContentDialog(
        context,
        "Contacts",
        1.2,
        2.4,
        Container(
          padding: EdgeInsets.only(top: 40.0),
          child: Center(
              child: Column(
            children: [
              // Telephone
              ListTile(
                leading: Icon(FontAwesomeIcons.phone),
                title: Text(
                  "(+225) 27 22 52 19 46 / 27 22 59 86 15",
                  style: TextStyle(fontSize: 9.0),
                ),
                onTap: () {
                  // for future usage
                },
              ),

              SizedBox(height: 20.0),
              // email
              ListTile(
                leading: Icon(FontAwesomeIcons.at),
                title: Text(
                  "info@amuga.ci",
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () {
                  // for future usage
                },
              ),
              // web
              SizedBox(height: 20.0),
              ListTile(
                leading: Icon(FontAwesomeIcons.internetExplorer),
                title: Text(
                  "www.amuga.ci",
                  style: TextStyle(fontSize: 11.0),
                ),
                onTap: () {
                  // for future usage
                },
              ),

              SizedBox(height: 20.0),
              // address
              ListTile(
                leading: Icon(FontAwesomeIcons.addressCard),
                title: Text(
                  "II Plateaux 1ère Tranche, Rue K35, Villa 412 - 28 BP 755 Abidjan",
                  style: TextStyle(fontSize: 9.0),
                ),
                onTap: () {
                  // for future usage
                },
              )
            ],
          )),
        ));
  }

  void showMap(BuildContext context) {
    /*showContentDialog(context,
        "Carte des transports", 1.2, 2.4, Container());*/
  }

  void showUsingConditions(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    String fileHtmlContent = await rootBundle.loadString('assets/CGU.html');

    setState(() {
      _isLoading = false;
    });

    showContentDialog(
      context,
      "Conditions générales d'utilistation",
      1,
      1.5,
      WebView(
        initialUrl: '',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) async {
          webViewController.loadUrl(Uri.dataFromString(fileHtmlContent,
                  mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
              .toString());
        },
      ),
    );
  }

  void showAbout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    String fileHtmlContent = await rootBundle.loadString('assets/apropos.html');

    setState(() {
      _isLoading = false;
    });
    showContentDialog(
        context,
        "${_packageInfo.appName} v${_packageInfo.version}",
        1.2,
        2.4,
        WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) async {
            webViewController.loadUrl(Uri.dataFromString(fileHtmlContent,
                    mimeType: 'text/html',
                    encoding: Encoding.getByName('utf-8'))
                .toString());
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //onDoubleTap: toggle,
      onTapDown: (TapDownDetails details) {
        double x = details.globalPosition.dx;
        double y = details.globalPosition.dy;

        double burgerBtnHeight =
            AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
        double burgerBtnWidth = MediaQuery.of(context).size.width / 7;

        if (y <= burgerBtnHeight && x <= burgerBtnWidth) toggle();
        if (y <= burgerBtnHeight && x >= burgerBtnWidth * 6) {
          showEventsList(context);
        }
      },
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          return Material(
            color: Colors.blueGrey,
            child: Stack(
              children: <Widget>[
                Transform.translate(
                  offset: Offset(maxSlide * animationController.value, 0),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-math.pi * animationController.value / 2),
                    alignment: Alignment.centerLeft,
                    child: widget.child,
                  ),
                ),
                Transform.translate(
                  offset: Offset(maxSlide * (animationController.value - 1), 0),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(math.pi / 2 * (1 - animationController.value)),
                    alignment: Alignment.centerRight,
                    child: MyDrawer(
                      fn: toggle,
                      showAboutScreen: this.showAbout,
                      showConditionScreen: this.showUsingConditions,
                      showContacts: this.showContacts,
                      showEvents: this.showEventsList,
                      showMap: this.showMap,
                      showParams: this.showParams,
                    ),
                  ),
                ),
                // Icon menu top left
                Positioned(
                  top: 4.0 + MediaQuery.of(context).padding.top,
                  left: 4.0 + animationController.value * maxSlide,
                  child: TextButton(
                    child: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      toggle();
                    },
                  ),
                ),
                // Amuga text in the top bar
                Positioned(
                  top: 16.0 + MediaQuery.of(context).padding.top,
                  left: animationController.value *
                      MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'aMUGA',
                    style: TextStyle(
                      fontFamily: 'SpaceAge',
                      fontSize: 30.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Visibility(
                  visible: this._isLoading,
                  child: Container(
                    color: Colors.grey.withOpacity(0.6),
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: defaultTheme.kIconsColor,
                        size: 80.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  Function fn;
  Function showAboutScreen;
  Function showConditionScreen;
  Function showMap;
  Function showContacts;
  Function showParams;
  Function showEvents;

  MyDrawer(
      {this.fn,
      this.showAboutScreen,
      this.showConditionScreen,
      this.showMap,
      this.showContacts,
      this.showParams,
      this.showEvents});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [defaultTheme.kMenuColor, defaultTheme.kIconsColor],
              begin: const FractionalOffset(0.0, 1.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 60.0,
            ),
            Text(
              'aMUGA',
              style: TextStyle(
                fontFamily: 'SpaceAge',
                fontSize: 30.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 60.0,
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.bell,
                color: Colors.white,
              ),
              title: Text(
                'Notifications',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                print("displaying notifications");
                this.fn();
                this.showEvents(context);
              },
            ),

            // NO params for the application at this moment
            /*
            ListTile(
              leading: Icon(FontAwesomeIcons.cog,
                color: Colors.white,
              ),
              title: Text(
                  'Paramètres',
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              onTap: () {
                print("displaying the parameters screen");
                this.fn();
                this.showParams(context);
              },
            ),
            */

            ListTile(
              leading: Icon(
                FontAwesomeIcons.lifeRing,
                color: Colors.white,
              ),
              title: Text(
                'Aide et contact',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                this.fn();
                this.showContacts(context);
              },
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.map,
                color: Colors.white,
              ),
              title: Text(
                'Afficher la carte',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                print("displaying the pdf map");
                this.fn();
                this.showMap(context);
              },
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.readme,
                color: Colors.white,
              ),
              title: Text(
                'Conditions générales d\'utilisation',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                print("displaying conditions pages");
                this.fn();
                this.showConditionScreen(context);
              },
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.search,
                color: Colors.white,
              ),
              title: Text(
                'Rechercher un Endroit',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                this.fn();
                showPlacesSearch(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return InfoScreen();
                //     },
                //   ),
                // );
              },
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.book,
                color: Colors.white,
              ),
              title: Text(
                'StoryBoard',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                this.fn();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StoryScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.moneyCheck,
                color: Colors.white,
              ),
              title: Text(
                'A propos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                print("displaying the About screen");
                this.fn();
                this.showAboutScreen(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
