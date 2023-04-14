import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_location_app/repository/location_service/location_hive_service.dart';

import 'location_service_panel_event.dart';
import 'location_service_panel_state.dart';

class LocationServicePanelBloc
    extends Bloc<LocationServicePanelEvent, LocationServicePanelState> {
  LocationServicePanelBloc({bool isRunning = false})
      : super(LocationServicePanelState(
          isRunning: isRunning,
        )) {
    on<BackgroundModeLocationServicePanelEvent>(_backgroundMode);
    on<ForegroundModeLocationServicePanelEvent>(_foregroundMode);
    on<ExecuteServiceLocationServicePanelEvent>(_executeService);
  }

  Future<void> _backgroundMode(
    BackgroundModeLocationServicePanelEvent event,
    Emitter emit,
  ) async {
    final service = FlutterBackgroundService();
    service.invoke("setAsBackground");
    emit(state.copyWith(
      isBackgroundMode: false,
      isForegroundMode: true,
    ));
  }

  Future<void> _foregroundMode(
    ForegroundModeLocationServicePanelEvent event,
    Emitter emit,
  ) async {
    final service = FlutterBackgroundService();
    service.invoke("setAsForeground");
    emit(state.copyWith(
      isBackgroundMode: true,
      isForegroundMode: false,
    ));
  }

  Future<void> _executeService(
    ExecuteServiceLocationServicePanelEvent event,
    Emitter emit,
  ) async {
    final service = FlutterBackgroundService();
    final SharedPreferences sp = await SharedPreferences.getInstance();
    if (await service.isRunning()) {
      await sp.setBool("stop", true);
      print(sp.getBool('stop'));
      service.invoke("stopService");
      emit(state.copyWith(isRunning: false));
    } else {
      await sp.setBool("stop", false);
      await service.startService();
      emit(state.copyWith(isRunning: true));
    }
  }
}
