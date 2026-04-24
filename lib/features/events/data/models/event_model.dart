import '../../domain/entities/event.dart';
 
class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.body,
    required super.userId,
    super.date,
    super.location,
    super.photoPath,
  });
 
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
      // JSONPlaceholder doesn't have date/location — we add defaults
      date: DateTime.now().add(Duration(days: json['id'] as int)),
      location: 'Salle B${(json['id'] as int) % 10 + 1}',
    );
  }
 
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int,
      title: map['title'] as String,
      body: map['body'] as String,
      userId: map['userId'] as int,
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int)
          : null,
      location: map['location'] as String?,
      photoPath: map['photoPath'] as String?,
    );
  }
 
  Map<String, dynamic> toMap({required int cachedAt}) => {
        'id': id,
        'title': title,
        'body': body,
        'userId': userId,
        'date': date?.millisecondsSinceEpoch,
        'location': location,
        'photoPath': photoPath,
        'cachedAt': cachedAt,
      };
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'userId': userId,
        'date': date?.toIso8601String(),
        'location': location,
      };
}