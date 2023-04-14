import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracking_location_app/model/process_status.dart';

import 'location_permission_event.dart';
import 'location_permission_state.dart';

class LocationPermissionBloc
    extends Bloc<LocationPermissionEvent, LocationPermissionState> {
  LocationPermissionBloc() : super(LocationPermissionState()) {
    on<RequestLocationPermissionEvent>(_requestPermission);
    on<CheckLocationPermissionEvent>(_checkPermission);
  }

  Future<void> _checkPermission(
      CheckLocationPermissionEvent event, Emitter emit) async {
    try {
      emit(state.copyWith(status: ProcessStatus.loading));
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        emit(state.copyWith(
          message: 'Location services are disabled.',
          status: ProcessStatus.failure,
        ));
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        emit(state.copyWith(
          message: 'Location permissions success',
          status: ProcessStatus.success,
          permission: permission,
        ));
        return;
      }
      emit(state.copyWith(
        message: 'Location services are disabled.',
        status: ProcessStatus.failure,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProcessStatus.failure));
    }
  }

  Future<void> _requestPermission(
      RequestLocationPermissionEvent event, Emitter emit) async {
    try {
      emit(state.copyWith(status: ProcessStatus.loading));
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        emit(state.copyWith(
          message: 'Location services are disabled.',
          status: ProcessStatus.failure,
          permission: LocationPermission.unableToDetermine,
        ));
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          emit(state.copyWith(
            message: 'Location permissions are denied',
            status: ProcessStatus.failure,
            permission: LocationPermission.denied,
          ));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        const msg =
            'Location permissions are permanently denied, we cannot request permissions.';
        emit(state.copyWith(
          message: msg,
          status: ProcessStatus.failure,
          permission: LocationPermission.denied,
        ));
        return;
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      emit(state.copyWith(status: ProcessStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ProcessStatus.failure));
    }
  }
}
