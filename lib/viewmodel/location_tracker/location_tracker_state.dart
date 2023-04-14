import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_location_app/model/location.dart';
import 'package:tracking_location_app/model/process_status.dart';

class LocationTrackerState {
  final List<Location> locations;
  final ProcessStatus status;

  LocationTrackerState({
    required this.locations,
    this.status = ProcessStatus.initialize,
  });

  Set<Marker> get markers => locations.map((point) {
        final markerId = MarkerId(point.id);
        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(point.lat ?? 0.0, point.lng ?? 0.0),
          onTap: () {},
        );
        return marker;
      }).toSet();

  LocationTrackerState copyWith({
    List<Location>? locations,
    ProcessStatus? status,
  }) {
    return LocationTrackerState(
      locations: locations ?? this.locations,
      status: status ?? this.status,
    );
  }
}
