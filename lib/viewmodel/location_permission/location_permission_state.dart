import 'package:geolocator/geolocator.dart';
import 'package:tracking_location_app/model/process_status.dart';

class LocationPermissionState {
  final ProcessStatus status;
  final String? message;
  final LocationPermission? permission;

  LocationPermissionState({
    this.status = ProcessStatus.initialize,
    this.message,
    this.permission,
  });

  LocationPermissionState copyWith({
    ProcessStatus? status,
    String? message,
    LocationPermission? permission,

  }) {
    return LocationPermissionState(
      status: status ?? this.status,
      message: message ?? this.message,
      permission: permission ?? this.permission,
    );
  }
}
