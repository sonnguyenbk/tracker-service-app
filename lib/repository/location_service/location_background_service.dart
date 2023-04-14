import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_location_app/model/location.dart';

import 'location_hive_service.dart';

class LocationBackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground',
      'MY FOREGROUND SERVICE',
      description: 'This channel is used for important notifications.',
      importance: Importance.low,
    );

    final flnp = FlutterLocalNotificationsPlugin();

    final plt = flnp.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await plt?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        // auto start service
        autoStart: false,
        isForegroundMode: false,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
  }
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  StreamSubscription? streamSubscription;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// OPTIONAL when use custom notification
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    log('FLUTTER BACKGROUND SERVICE - STOP');
    streamSubscription?.cancel();
    service.stopSelf();
  });

  void updateLocation(LatLng latLng) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              actions: [AndroidNotificationAction("id", "Okoko")],
            ),
          ),
        );
      }
    }

    // final location = await LocationHiveService.instance.add(
    //   lat: latLng.latitude,
    //   lng: latLng.longitude,
    // );

    /// you can see this log in logcat

    log('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    final location = Location.create(
      lat: latLng.latitude,
      lng: latLng.longitude,
    );

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
        "location": location.toJson
      },
    );
  }

  await LocationHiveService.instance.onInit();

  const ls = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  // streamSubscription =
  //     Geolocator.getPositionStream(locationSettings: ls).listen((position) {
  //   log('${position.latitude}:${position.longitude}');
  //   updateLocation(LatLng(position.latitude, position.longitude));
  // });

  // Fake data demo
  int i = 0;
  Timer.periodic(const Duration(seconds: 4), (timer) async {
    const fakeData = [
      LatLng(16.036311, 108.220556),
      LatLng(16.037610, 108.226597),
      LatLng(16.039662, 108.226307),
      LatLng(16.043078, 108.215394),
      LatLng(16.034895, 108.218537),
      LatLng(16.031055, 108.226440),
    ];
    if (i < fakeData.length) {
      updateLocation(fakeData[i]);
      i++;
    } else {
      updateLocation(fakeData[5]);
    }
  });
}
