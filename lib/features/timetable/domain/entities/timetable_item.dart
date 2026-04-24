import 'package:equatable/equatable.dart';
 
enum TimetableDay { monday, tuesday, wednesday, thursday, friday, saturday }
 
class TimetableItem extends Equatable {
  final int id;
  final String subject;
  final String teacher;
  final String room;
  final TimetableDay day;
  final String startTime; // "08:00"
  final String endTime;   // "09:30"
  final String? description;
 
  const TimetableItem({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.description,
  });
 
  /// Label court du jour pour l'affichage
  String get dayLabel {
    const labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return labels[day.index];
  }
 
  String get dayFullLabel {
    const labels = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
    return labels[day.index];
  }
 
  @override
  List<Object?> get props =>
      [id, subject, teacher, room, day, startTime, endTime, description];
}