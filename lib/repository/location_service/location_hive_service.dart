import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracking_location_app/model/location.dart';

class LocationHiveService {
  Box<Location>? _hiveBox;
  Box? _settingBox;

  LocationHiveService._privateConstructor();

  static final LocationHiveService _instance =
      LocationHiveService._privateConstructor();

  static LocationHiveService get instance => _instance;

  Box<Location>? get box => _hiveBox;

  Future<void> reset() async {
    _hiveBox?.deleteAll(_hiveBox?.keys ?? []);
  }

  Future<bool> onInit() async {
    if (_hiveBox != null) return true;
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive
      ..init(appDocumentDirectory.path)
      ..registerAdapter(LocationAdapter());
    _hiveBox ??= await Hive.openBox<Location>('location_hive_box');
    _settingBox ??= await Hive.openBox('setting_hive_box');
    return _hiveBox != null;
  }

  void onDispose() {
    _hiveBox?.close();
    _hiveBox = null;

    _settingBox?.close();
    _settingBox = null;
  }

  Future<void> setBgServiceStopStatus(bool isStop) async {
    await _settingBox?.put("is_bgservice_stop", isStop);
    await _settingBox?.flush();
  }

  bool get isBgServiceStop => _settingBox?.get("is_bgservice_stop") ?? false;

  Future<Location> add({required double lat, required double lng}) async {
    var location = Location.create(lat: lat, lng: lng);
    await _hiveBox?.add(location);
    await location.save();
    return location;
  }

  List<Location>? get all => box?.values.toList();
}
