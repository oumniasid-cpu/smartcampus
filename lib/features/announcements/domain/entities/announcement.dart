import 'package:equatable/equatable.dart';
 
class Announcement extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;
 
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });
 
  @override
  List<Object?> get props => [id, title, body, userId];
}