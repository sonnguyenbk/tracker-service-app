import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_location_app/view/locations_screen.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_bloc.dart';
import 'view/home_screen.dart';

class Routes {
  static var routes = {
    HomeScreen.routeName: (BuildContext context) {
      return const HomeScreen();
    },
    LocationsScreen.routeName: (BuildContext context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      final bloc = args as LocationTrackerBloc;
      
      return BlocProvider.value(
        value: bloc,
        child: const LocationsScreen(),
      );
    },
  };

  static var initialRoute = HomeScreen.routeName;
}
