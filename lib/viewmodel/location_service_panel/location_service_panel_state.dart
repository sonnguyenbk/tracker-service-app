class LocationServicePanelState {
  final bool isForegroundMode;
  final bool isBackgroundMode;
  final bool isRunning;

  LocationServicePanelState({
    this.isBackgroundMode = false,
    this.isForegroundMode = false,
    this.isRunning = false,
  });

  LocationServicePanelState copyWith({
    bool? isForegroundMode,
    bool? isBackgroundMode,
    bool? isRunning,
  }) {
    return LocationServicePanelState(
      isBackgroundMode: isBackgroundMode ?? this.isBackgroundMode,
      isForegroundMode: isForegroundMode ?? this.isForegroundMode,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
