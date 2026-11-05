class ActivityCadence {
  static const int defaultMaxActivities = 5;
  static const Duration defaultCycleDuration = Duration(hours: 5);

  final int availableActivities;
  final int maxActivities;
  final DateTime cycleStartTime;
  final Duration cycleDuration;

  const ActivityCadence({
    required this.availableActivities,
    this.maxActivities = defaultMaxActivities,
    required this.cycleStartTime,
    this.cycleDuration = defaultCycleDuration,
  });

  DateTime get nextRefreshTime => cycleStartTime.add(cycleDuration);

  Duration timeRemaining(DateTime now) {
    if (now.isAfter(nextRefreshTime)) return Duration.zero;
    return nextRefreshTime.difference(now);
  }

  bool shouldRefresh(DateTime now) {
    return now.isAfter(nextRefreshTime) || now.isAtSameMomentAs(nextRefreshTime);
  }

  bool get hasAvailableActivity => availableActivities > 0;

  ActivityCadence copyWith({
    int? availableActivities,
    int? maxActivities,
    DateTime? cycleStartTime,
    Duration? cycleDuration,
  }) {
    return ActivityCadence(
      availableActivities: availableActivities ?? this.availableActivities,
      maxActivities: maxActivities ?? this.maxActivities,
      cycleStartTime: cycleStartTime ?? this.cycleStartTime,
      cycleDuration: cycleDuration ?? this.cycleDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableActivities': availableActivities,
      'maxActivities': maxActivities,
      'cycleStartTime': cycleStartTime.toIso8601String(),
      'cycleDurationMinutes': cycleDuration.inMinutes,
    };
  }

  factory ActivityCadence.fromJson(Map<String, dynamic> json) {
    return ActivityCadence(
      availableActivities: json['availableActivities'] as int? ?? defaultMaxActivities,
      maxActivities: json['maxActivities'] as int? ?? defaultMaxActivities,
      cycleStartTime: json['cycleStartTime'] != null
          ? DateTime.parse(json['cycleStartTime'] as String)
          : DateTime.now(),
      cycleDuration: Duration(minutes: json['cycleDurationMinutes'] as int? ?? defaultCycleDuration.inMinutes),
    );
  }

  factory ActivityCadence.initial({DateTime? now}) {
    final current = now ?? DateTime.now();
    return ActivityCadence(
      availableActivities: defaultMaxActivities,
      maxActivities: defaultMaxActivities,
      cycleStartTime: current,
      cycleDuration: defaultCycleDuration,
    );
  }
}
