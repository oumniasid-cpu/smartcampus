import 'package:equatable/equatable.dart';
 
class Event extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;
  final DateTime? date;
  final String? location;
  final String? photoPath;
  final String? imageUrl;
  final String? category;
  final int? attendeeCount;
 
  const Event({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.date,
    this.location,
    this.photoPath,
    this.attendeeCount,
    this.category,
    this.imageUrl
  });
 
  Event copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
    DateTime? date,
    String? location,
    String? photoPath,
  }) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        userId: userId ?? this.userId,
        date: date ?? this.date,
        location: location ?? this.location,
        photoPath: photoPath ?? this.photoPath,
      );
 
  @override
  List<Object?> get props => [id, title, body, userId, date, location, photoPath];
}