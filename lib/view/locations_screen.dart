import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_bloc.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_state.dart';

class LocationsScreen extends StatelessWidget {
  static const routeName = "/LocationsScreen";

  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Locations"),
      ),
      body: BlocBuilder<LocationTrackerBloc, LocationTrackerState>(
        builder: (context, state) {
          return ListView.builder(
            itemBuilder: (context, index) {
              final title = "${state.locations[index].lat}; ${state.locations[index].lng}";
              final subtitle = state.locations[index].createdAtTime.toIso8601String();
              return ListTile(
                title: Text(title),
                subtitle: Text(subtitle),
              );
            },
            itemCount: state.locations.length,
          );
        },
      ),
    );
  }
}
