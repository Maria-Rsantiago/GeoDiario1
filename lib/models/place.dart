class Place {
  final String id;
  final String title;
  final String imagePath;
  final double latitude;
  final double longitude;
  final DateTime dateTime;

  const Place({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.dateTime,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'image_path': imagePath,
        'loc_lat': latitude,
        'loc_lng': longitude,
        'date_time': dateTime.toIso8601String(),
      };

  factory Place.fromMap(Map<String, Object?> map) => Place(
        id: map['id'] as String,
        title: (map['title'] as String?) ?? '',
        imagePath: map['image_path'] as String,
        latitude: (map['loc_lat'] as num).toDouble(),
        longitude: (map['loc_lng'] as num).toDouble(),
        dateTime: DateTime.parse(map['date_time'] as String),
      );
}
