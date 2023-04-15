import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_location_app/model/location.dart';
import 'package:tracking_location_app/routes.dart';
import 'package:tracking_location_app/viewmodel/location_permission/location_permission_bloc.dart';
import 'package:tracking_location_app/repository/location_service/location_background_service.dart';
import 'package:tracking_location_app/repository/location_service/location_hive_service.dart';
import 'package:tracking_location_app/viewmodel/location_service_panel/location_service_panel_bloc.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_bloc.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationHiveService.instance.onInit();
  await LocationBackgroundService.initializeService();
  runApp(
    MultiBlocProvider(providers: [
      BlocProvider(create: (context) => LocationPermissionBloc()),
      BlocProvider(create: (context) => LocationTrackerBloc()),
      BlocProvider(
        create: (context) => LocationServicePanelBloc(isRunning: false),
      ),
    ], child: const LocationTrackerApp()),
  );
}

class LocationTrackerApp extends StatefulWidget {
  const LocationTrackerApp({Key? key}) : super(key: key);

  @override
  State<LocationTrackerApp> createState() => _LocationTrackerAppState();
}

class _LocationTrackerAppState extends State<LocationTrackerApp> {
  StreamSubscription? _streamSubscription;
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    _streamSubscription = service.on('update').listen((data) {
      if (data == null) return;
      final location = Location.fromJson(data['location']);
      final event = AddLocationTrackerEvent(location: location);
      context.read<LocationTrackerBloc>().add(event);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
    service.invoke("stopService");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: Routes.routes,
      initialRoute: Routes.initialRoute,
    );
  }
}
