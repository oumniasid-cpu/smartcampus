import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  final String id;       // ← String au lieu de int (Firestore docId)
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.authorId = '',
    this.authorName = 'Admin',
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, body, authorId, authorName];
}