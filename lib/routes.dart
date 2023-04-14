import 'package:flutter/material.dart';
import 'view/home_screen.dart';

class Routes {
  static var routes = {
    HomeScreen.routeName: (BuildContext context) {
      return const HomeScreen();
    },

  };

  static var initialRoute = HomeScreen.routeName;
}
