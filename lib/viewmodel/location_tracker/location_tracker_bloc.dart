import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking_location_app/model/process_status.dart';
import 'package:tracking_location_app/repository/location_service/location_hive_service.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_event.dart';
import 'package:tracking_location_app/viewmodel/location_tracker/location_tracker_state.dart';

class LocationTrackerBloc
    extends Bloc<LocationTrackerEvent, LocationTrackerState> {
  LocationTrackerBloc() : super(LocationTrackerState(locations: [])) {
    on<AddLocationTrackerEvent>(_addLocation);
    on<ResetLocationTrackerEvent>(_resetLocation);
    on<LoadAllLocationTrackerEvent>(_loadAllLocation);
  }

  Future<void> _addLocation(AddLocationTrackerEvent event, Emitter emit) async {
    try {
      final location = await LocationHiveService.instance.add(
        lat: event.location.lat ?? 0.0,
        lng: event.location.lng ?? 0.0,
      );
      state.locations.add(location);
      emit(state.copyWith(
        locations: state.locations,
        status: ProcessStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProcessStatus.failure));
    }
  }

  Future<void> _resetLocation(
      ResetLocationTrackerEvent event, Emitter emit) async {
    LocationHiveService.instance.reset();
    emit(state.copyWith(
      locations: [],
      status: ProcessStatus.success,
    ));
  }

  Future<void> _loadAllLocation(
      LoadAllLocationTrackerEvent event, Emitter emit) async {
    var locations = LocationHiveService.instance.all;
    emit(state.copyWith(locations: locations, status: ProcessStatus.success));
  }
}
