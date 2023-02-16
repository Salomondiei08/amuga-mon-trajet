import 'package:amuga/themes/default.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key key}) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kIconsColor,
        actions: [
          IconButton(
              icon: Icon(
                FontAwesomeIcons.bell,
                size: 20.0,
              ),
              onPressed: () {
                print('action button pressed');
              }),
        ],
      ),
    );
  }
}
