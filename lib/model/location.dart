import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

part 'location.g.dart';

@HiveType(typeId: 0)
class Location extends HiveObject {
  /// ID
  @HiveField(0)
  final String id;

  /// Latitute
  @HiveField(1)
  double? lat;

  /// Longitude
  @HiveField(2)
  double? lng;

  /// CREATED AT TIME
  @HiveField(3)
  DateTime createdAtTime;

  Location({
    required this.id,
    required this.lat,
    required this.lng,
    required this.createdAtTime,
  });

  Map<String, dynamic> get toJson => {
        "id": id,
        "lat": lat,
        "lng": lng,
        "createdAtTime": createdAtTime.toIso8601String(),
      };

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      lat: json['lat'] as double,
      lng: json['lng'] as double,
      createdAtTime: DateTime.tryParse(json['createdAtTime']) ?? DateTime.now(),
    );
  }

  factory Location.create({
    required double? lat,
    required double? lng,
    DateTime? createdAtTime,
  }) =>
      Location(
        id: const Uuid().v1(),
        lat: lat,
        lng: lng,
        createdAtTime: createdAtTime ?? DateTime.now(),
      );
}
