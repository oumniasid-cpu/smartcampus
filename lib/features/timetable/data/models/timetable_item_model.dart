import '../../domain/entities/timetable_item.dart';
 
class TimetableItemModel extends TimetableItem {
  const TimetableItemModel({
    required super.id,
    required super.subject,
    required super.teacher,
    required super.room,
    required super.day,
    required super.startTime,
    required super.endTime,
    super.description,
  });
 
  factory TimetableItemModel.fromJson(Map<String, dynamic> json) {
    return TimetableItemModel(
      id: json['id'] as int,
      subject: json['subject'] as String,
      teacher: json['teacher'] as String,
      room: json['room'] as String,
      day: TimetableDay.values[json['day'] as int],
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      description: json['description'] as String?,
    );
  }
 
  factory TimetableItemModel.fromMap(Map<String, dynamic> map) {
    return TimetableItemModel(
      id: map['id'] as int,
      subject: map['subject'] as String,
      teacher: map['teacher'] as String,
      room: map['room'] as String,
      day: TimetableDay.values[map['day'] as int],
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      description: map['description'] as String?,
    );
  }
 
  Map<String, dynamic> toMap({required int cachedAt}) => {
        'id': id,
        'subject': subject,
        'teacher': teacher,
        'room': room,
        'day': day.index,
        'startTime': startTime,
        'endTime': endTime,
        'description': description,
        'cachedAt': cachedAt,
      };
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'teacher': teacher,
        'room': room,
        'day': day.index,
        'dayLabel': dayLabel,
        'startTime': startTime,
        'endTime': endTime,
        'description': description,
      };
 
  /// Mock timetable — used when API has no timetable endpoint
  static List<TimetableItemModel> get mockData => [
        const TimetableItemModel(id: 1, subject: 'Systèmes d\'exploitation mobiles', teacher: 'Dr. Benali', room: 'A101', day: TimetableDay.monday, startTime: '08:00', endTime: '09:30'),
        const TimetableItemModel(id: 2, subject: 'Développement Flutter', teacher: 'Prof. Hamdi', room: 'B204', day: TimetableDay.monday, startTime: '10:00', endTime: '11:30'),
        const TimetableItemModel(id: 3, subject: 'Algorithmique Avancée', teacher: 'Dr. Meziane', room: 'C305', day: TimetableDay.tuesday, startTime: '08:00', endTime: '09:30'),
        const TimetableItemModel(id: 4, subject: 'Réseaux & Protocoles', teacher: 'Prof. Kaddour', room: 'A102', day: TimetableDay.tuesday, startTime: '13:00', endTime: '14:30'),
        const TimetableItemModel(id: 5, subject: 'Base de données', teacher: 'Dr. Sahraoui', room: 'B201', day: TimetableDay.wednesday, startTime: '09:00', endTime: '10:30'),
        const TimetableItemModel(id: 6, subject: 'Développement Flutter', teacher: 'Prof. Hamdi', room: 'Labo 1', day: TimetableDay.wednesday, startTime: '14:00', endTime: '16:00', description: 'TP — Projet semestriel'),
        const TimetableItemModel(id: 7, subject: 'Sécurité Informatique', teacher: 'Dr. Berkane', room: 'A103', day: TimetableDay.thursday, startTime: '08:00', endTime: '09:30'),
        const TimetableItemModel(id: 8, subject: 'Systèmes d\'exploitation mobiles', teacher: 'Dr. Benali', room: 'Labo 2', day: TimetableDay.thursday, startTime: '10:00', endTime: '12:00', description: 'TP — Démonstration concepts OS'),
        const TimetableItemModel(id: 9, subject: 'Algorithmique Avancée', teacher: 'Dr. Meziane', room: 'C305', day: TimetableDay.friday, startTime: '08:00', endTime: '09:30'),
        const TimetableItemModel(id: 10, subject: 'Réseaux & Protocoles', teacher: 'Prof. Kaddour', room: 'A102', day: TimetableDay.friday, startTime: '10:00', endTime: '11:30'),
      ];
}