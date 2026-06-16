import 'package:equatable/equatable.dart';

class YoutubeSettingsModel extends Equatable {
  final int id;
  final int subscribers;

  const YoutubeSettingsModel({
    this.id = 1,
    required this.subscribers,
  });

  YoutubeSettingsModel copyWith({
    int? id,
    int? subscribers,
  }) {
    return YoutubeSettingsModel(
      id: id ?? this.id,
      subscribers: subscribers ?? this.subscribers,
    );
  }

  factory YoutubeSettingsModel.fromJson(Map<String, dynamic> json) {
    return YoutubeSettingsModel(
      id: json['id'] as int? ?? 1,
      subscribers: json['subscribers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscribers': subscribers,
    };
  }

  factory YoutubeSettingsModel.fromMap(Map<String, dynamic> map) {
    return YoutubeSettingsModel(
      id: map['id'] as int? ?? 1,
      subscribers: map['subscribers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscribers': subscribers,
    };
  }

  @override
  List<Object?> get props => [id, subscribers];
}

class YoutubeVideoModel extends Equatable {
  final int id;
  final String title;
  final String type;
  final String stage;
  final int views;
  final int watchTimeMinutes;
  final DateTime createdAt;

  const YoutubeVideoModel({
    required this.id,
    required this.title,
    required this.type,
    required this.stage,
    required this.views,
    required this.watchTimeMinutes,
    required this.createdAt,
  });

  YoutubeVideoModel copyWith({
    int? id,
    String? title,
    String? type,
    String? stage,
    int? views,
    int? watchTimeMinutes,
    DateTime? createdAt,
  }) {
    return YoutubeVideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      views: views ?? this.views,
      watchTimeMinutes: watchTimeMinutes ?? this.watchTimeMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory YoutubeVideoModel.fromJson(Map<String, dynamic> json) {
    return YoutubeVideoModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      views: json['views'] as int? ?? 0,
      watchTimeMinutes: json['watch_time_minutes'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'stage': stage,
      'views': views,
      'watch_time_minutes': watchTimeMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory YoutubeVideoModel.fromMap(Map<String, dynamic> map) {
    return YoutubeVideoModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? '',
      stage: map['stage'] as String? ?? '',
      views: map['views'] as int? ?? 0,
      watchTimeMinutes: map['watchTimeMinutes'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'title': title,
      'type': type,
      'stage': stage,
      'views': views,
      'watchTimeMinutes': watchTimeMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, title, type, stage, views, watchTimeMinutes, createdAt];
}

class ContentCalendarEntryModel extends Equatable {
  final int id;
  final String title;
  final String type;
  final DateTime scheduledDate;
  final bool isPublished;

  const ContentCalendarEntryModel({
    required this.id,
    required this.title,
    required this.type,
    required this.scheduledDate,
    required this.isPublished,
  });

  ContentCalendarEntryModel copyWith({
    int? id,
    String? title,
    String? type,
    DateTime? scheduledDate,
    bool? isPublished,
  }) {
    return ContentCalendarEntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  factory ContentCalendarEntryModel.fromJson(Map<String, dynamic> json) {
    return ContentCalendarEntryModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      scheduledDate: DateTime.tryParse(json['scheduled_date'] as String? ?? '') ?? DateTime.now(),
      isPublished: json['is_published'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'scheduled_date': scheduledDate.toIso8601String(),
      'is_published': isPublished,
    };
  }

  factory ContentCalendarEntryModel.fromMap(Map<String, dynamic> map) {
    return ContentCalendarEntryModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? '',
      scheduledDate: DateTime.tryParse(map['scheduledDate'] as String? ?? '') ?? DateTime.now(),
      isPublished: (map['isPublished'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'title': title,
      'type': type,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isPublished': isPublished ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [id, title, type, scheduledDate, isPublished];
}
