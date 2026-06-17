import 'package:equatable/equatable.dart';

class CareerTrackerModel extends Equatable {
  final int id;
  final String company;
  final String role;
  final String status;
  final double salary;
  final double offeredSalary;
  final DateTime dateApplied;
  final bool recruiterContacted;
  final String interviewDate;
  final String notes;
  final String reminderDateTime;

  const CareerTrackerModel({
    required this.id,
    required this.company,
    required this.role,
    required this.status,
    required this.salary,
    this.offeredSalary = 0.0,
    required this.dateApplied,
    required this.recruiterContacted,
    required this.interviewDate,
    required this.notes,
    this.reminderDateTime = '',
  });

  CareerTrackerModel copyWith({
    int? id,
    String? company,
    String? role,
    String? status,
    double? salary,
    double? offeredSalary,
    DateTime? dateApplied,
    bool? recruiterContacted,
    String? interviewDate,
    String? notes,
    String? reminderDateTime,
  }) {
    return CareerTrackerModel(
      id: id ?? this.id,
      company: company ?? this.company,
      role: role ?? this.role,
      status: status ?? this.status,
      salary: salary ?? this.salary,
      offeredSalary: offeredSalary ?? this.offeredSalary,
      dateApplied: dateApplied ?? this.dateApplied,
      recruiterContacted: recruiterContacted ?? this.recruiterContacted,
      interviewDate: interviewDate ?? this.interviewDate,
      notes: notes ?? this.notes,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
    );
  }

  factory CareerTrackerModel.fromJson(Map<String, dynamic> json) {
    return CareerTrackerModel(
      id: json['id'] as int? ?? 0,
      company: json['company'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      offeredSalary: (json['offeredSalary'] as num?)?.toDouble() ?? 0.0,
      dateApplied: DateTime.tryParse(json['date_applied'] as String? ?? '') ?? DateTime.now(),
      recruiterContacted: json['recruiter_contacted'] as bool? ?? false,
      interviewDate: json['interview_date'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      reminderDateTime: json['reminderDateTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'role': role,
      'status': status,
      'salary': salary,
      'offeredSalary': offeredSalary,
      'date_applied': dateApplied.toIso8601String(),
      'recruiter_contacted': recruiterContacted,
      'interview_date': interviewDate,
      'notes': notes,
      'reminderDateTime': reminderDateTime,
    };
  }

  // SQLite DB conversions (helper functions mapping SQLite format)
  factory CareerTrackerModel.fromMap(Map<String, dynamic> map) {
    return CareerTrackerModel(
      id: map['id'] as int? ?? 0,
      company: map['company'] as String? ?? '',
      role: map['role'] as String? ?? '',
      status: map['status'] as String? ?? '',
      salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
      offeredSalary: (map['offeredSalary'] as num?)?.toDouble() ?? 0.0,
      dateApplied: DateTime.tryParse(map['dateApplied'] as String? ?? '') ?? DateTime.now(),
      recruiterContacted: (map['recruiterContacted'] as int? ?? 0) == 1,
      interviewDate: map['interviewDate'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      reminderDateTime: map['reminderDateTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'company': company,
      'role': role,
      'status': status,
      'salary': salary,
      'offeredSalary': offeredSalary,
      'dateApplied': dateApplied.toIso8601String(),
      'recruiterContacted': recruiterContacted ? 1 : 0,
      'interviewDate': interviewDate,
      'notes': notes,
      'reminderDateTime': reminderDateTime,
    };
  }

  @override
  List<Object?> get props => [
        id,
        company,
        role,
        status,
        salary,
        offeredSalary,
        dateApplied,
        recruiterContacted,
        interviewDate,
        notes,
        reminderDateTime,
      ];
}

class CareerStatusHistoryModel {
  final int id;
  final int applicationId;
  final String status;
  final DateTime changedAt;

  const CareerStatusHistoryModel({
    required this.id,
    required this.applicationId,
    required this.status,
    required this.changedAt,
  });

  factory CareerStatusHistoryModel.fromMap(Map<String, dynamic> map) {
    return CareerStatusHistoryModel(
      id: map['id'] as int? ?? 0,
      applicationId: map['applicationId'] as int? ?? 0,
      status: map['status'] as String? ?? '',
      changedAt: DateTime.tryParse(map['changedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'applicationId': applicationId,
      'status': status,
      'changedAt': changedAt.toIso8601String(),
    };
  }
}
