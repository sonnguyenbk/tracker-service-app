import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'location_service_panel_event.dart';
import 'location_service_panel_state.dart';

class LocationServicePanelBloc
    extends Bloc<LocationServicePanelEvent, LocationServicePanelState> {
  LocationServicePanelBloc({bool isRunning = false})
      : super(LocationServicePanelState(isRunning: isRunning)) {
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
    if (await service.isRunning()) {
      service.invoke("stopService");

      emit(state.copyWith(isRunning: false));
    } else {
      await service.startService();
      emit(state.copyWith(isRunning: true));
    }
  }
}
