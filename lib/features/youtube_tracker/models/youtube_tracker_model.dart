import 'package:equatable/equatable.dart';

class YoutubeContentModel extends Equatable {
  final int id;
  final String title;
  final String targetDate; // yyyy-MM-dd
  final String status; // 'planned' | 'scripting' | 'filming' | 'editing' | 'thumbnail' | 'published'
  final DateTime? publishedAt;
  final DateTime createdAt;
  final String reminderDateTime;

  const YoutubeContentModel({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    this.reminderDateTime = '',
  });

  YoutubeContentModel copyWith({
    int? id,
    String? title,
    String? targetDate,
    String? status,
    DateTime? publishedAt,
    DateTime? createdAt,
    String? reminderDateTime,
  }) {
    return YoutubeContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
    );
  }

  factory YoutubeContentModel.fromMap(Map<String, dynamic> map) {
    return YoutubeContentModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      targetDate: map['target_date'] as String? ?? '',
      status: map['status'] as String? ?? 'planned',
      publishedAt: map['published_at'] != null ? DateTime.tryParse(map['published_at'] as String) : null,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      reminderDateTime: map['reminderDateTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'title': title,
      'target_date': targetDate,
      'status': status,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'reminderDateTime': reminderDateTime,
    };
  }

  @override
  List<Object?> get props => [id, title, targetDate, status, publishedAt, createdAt, reminderDateTime];
}

class YoutubeChannelStatsModel extends Equatable {
  final String subscribers;
  final String totalViews;
  final String totalVideos;
  final String watchHours;
  final String monthlyRevenue;

  const YoutubeChannelStatsModel({
    this.subscribers = '0',
    this.totalViews = '0',
    this.totalVideos = '0',
    this.watchHours = '0',
    this.monthlyRevenue = '0',
  });

  YoutubeChannelStatsModel copyWith({
    String? subscribers,
    String? totalViews,
    String? totalVideos,
    String? watchHours,
    String? monthlyRevenue,
  }) {
    return YoutubeChannelStatsModel(
      subscribers: subscribers ?? this.subscribers,
      totalViews: totalViews ?? this.totalViews,
      totalVideos: totalVideos ?? this.totalVideos,
      watchHours: watchHours ?? this.watchHours,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
    );
  }

  @override
  List<Object?> get props => [subscribers, totalViews, totalVideos, watchHours, monthlyRevenue];
}
