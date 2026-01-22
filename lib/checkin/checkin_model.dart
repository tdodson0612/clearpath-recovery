/// Model for daily check-in data
/// This represents a single day's check-in entry
class DailyCheckIn {
  final String id;
  final String userId;
  final DateTime date;
  final int moodRating; // 1-10
  final int cravingIntensity; // 1-10
  final bool substanceUsed;
  final String recoveryAction;
  final DateTime createdAt;

  DailyCheckIn({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodRating,
    required this.cravingIntensity,
    required this.substanceUsed,
    required this.recoveryAction,
    required this.createdAt,
  });

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'mood_rating': moodRating,
      'craving_intensity': cravingIntensity,
      'substance_used': substanceUsed,
      'recovery_action': recoveryAction,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON (database retrieval)
  factory DailyCheckIn.fromJson(Map<String, dynamic> json) {
    return DailyCheckIn(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      moodRating: json['mood_rating'] as int,
      cravingIntensity: json['craving_intensity'] as int,
      substanceUsed: json['substance_used'] as bool,
      recoveryAction: json['recovery_action'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Copy with modifications (useful for updates)
  DailyCheckIn copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? moodRating,
    int? cravingIntensity,
    bool? substanceUsed,
    String? recoveryAction,
    DateTime? createdAt,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodRating: moodRating ?? this.moodRating,
      cravingIntensity: cravingIntensity ?? this.cravingIntensity,
      substanceUsed: substanceUsed ?? this.substanceUsed,
      recoveryAction: recoveryAction ?? this.recoveryAction,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DailyCheckIn(id: $id, date: $date, mood: $moodRating, '
        'cravings: $cravingIntensity, substanceUsed: $substanceUsed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyCheckIn && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 