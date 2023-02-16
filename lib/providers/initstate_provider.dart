import 'package:flutter/foundation.dart';

class InitStateProvider extends ChangeNotifier {
  double percentage = 0;
  bool appInitialized = false;

  void updatePercentage(double newPercentage) {
    percentage = newPercentage;
  }

  void finishInitialization() {
    appInitialized = true;
    notifyListeners();
  }
}