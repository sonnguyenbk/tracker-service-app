import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_location_app/model/location.dart';

abstract class LocationTrackerEvent {}

class LoadAllLocationTrackerEvent extends LocationTrackerEvent {}

class ResetLocationTrackerEvent extends LocationTrackerEvent {}

class AddLocationTrackerEvent extends LocationTrackerEvent {
  final Location location;
  AddLocationTrackerEvent({required this.location});
}