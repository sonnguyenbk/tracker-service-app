import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_location_app/model/process_status.dart';
import 'package:tracking_location_app/view/locations_screen.dart';
import 'package:tracking_location_app/viewmodel/location_permission/location_permission_bloc.dart';
import 'package:tracking_location_app/viewmodel/location_permission/location_permission_event.dart';
import 'package:tracking_location_app/viewmodel/location_permission/location_permission_state.dart';
import 'package:tracking_location_app/viewmodel/location_service_panel/location_service_panel_bloc.dart';
import 'package:tracking_location_app/viewmodel/location_service_panel/location_service_panel_event.dart';
import 'package:tracking_location_app/viewmodel/location_service_panel/location_service_panel_state.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_bloc.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_event.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_state.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/HomeScreen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.036311, 108.220556),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    final event = LoadAllLocationTrackerEvent();
    context.read<LocationTrackerBloc>().add(event);

    final event1 = CheckLocationPermissionEvent();
    context.read<LocationPermissionBloc>().add(event1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service Location App'),
        ),
        body: Column(
          children: [
            BlocBuilder<LocationTrackerBloc, LocationTrackerState>(
              builder: (context, state) {
                return Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    markers: state.markers,
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {},
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<LocationPermissionBloc, LocationPermissionState>(
              builder: (context, state) {
                if (state.status == ProcessStatus.loading) {
                  return const CircularProgressIndicator();
                }
                if (state.status == ProcessStatus.success) {
                  return _executeServiceButton();
                } else {
                  return _requestLocationPermissionButton();
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final bloc = context.read<LocationTrackerBloc>();
            Navigator.pushNamed(
              context,
              LocationsScreen.routeName,
              arguments: bloc,
            );
          },
          child: const Icon(Icons.list_alt_outlined),
        ),
      ),
    );
  }

  Widget _executeServiceButton() {
    return BlocBuilder<LocationServicePanelBloc, LocationServicePanelState>(
      builder: (context, state) {
        String text = "Start Service";
        if (state.isRunning) text = "Stop Service";

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: Text(text),
                  onPressed: () async {
                    final event = ExecuteServiceLocationServicePanelEvent();
                    context.read<LocationServicePanelBloc>().add(event);
                  },
                ),
                ElevatedButton(
                  child: const Text("Reset Location"),
                  onPressed: () async {
                    final event = ResetLocationTrackerEvent();
                    context.read<LocationTrackerBloc>().add(event);
                  },
                ),
              ],
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () async {
                final event = BackgroundModeLocationServicePanelEvent();
                context.read<LocationServicePanelBloc>().add(event);
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () async {
                final event = ForegroundModeLocationServicePanelEvent();
                context.read<LocationServicePanelBloc>().add(event);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _requestLocationPermissionButton() {
    final state = context.read<LocationPermissionBloc>().state;
    Widget child = const Text("Permission Request");
    if (state.status == ProcessStatus.loading) {
      child = const CircularProgressIndicator();
    } else if (state.status == ProcessStatus.failure) {
      child = Text(state.message ?? "Something went wrong");
    }
    return ElevatedButton(
      child: child,
      onPressed: () async {
        final event = RequestLocationPermissionEvent();
        context.read<LocationPermissionBloc>().add(event);
      },
    );
  }
}
