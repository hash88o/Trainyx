import 'package:equatable/equatable.dart';

import '../../../clients/domain/entities/client.dart';

/// Attendance status
enum AttendanceStatus {
  scheduled('Scheduled'),
  present('Present'),
  absent('Absent'),
  cancelled('Cancelled'),
  late('Late');

  final String label;
  const AttendanceStatus(this.label);

  bool get isCompleted => this == present || this == absent || this == cancelled;
}

/// Represents a recurring schedule for a client
class ClientSchedule extends Equatable {
  final String id;
  final String clientId;
  final String trainerId;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, etc.
  final DateTime startTime;
  final DateTime? endTime;
  final bool isRecurring;
  final String? notes;
  final DateTime createdAt;

  const ClientSchedule({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.dayOfWeek,
    required this.startTime,
    this.endTime,
    this.isRecurring = true,
    this.notes,
    required this.createdAt,
  });

  /// Day name (Monday, Tuesday, etc.)
  String get dayName {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[dayOfWeek % 7];
  }

  /// Short day name (Mon, Tue, etc.)
  String get dayShortName {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayOfWeek % 7];
  }

  /// Formatted time range (e.g., "9:00 AM - 10:00 AM")
  String get timeRangeFormatted {
    final start = _formatTime(startTime);
    if (endTime == null) return start;
    return '$start - ${_formatTime(endTime!)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Duration if end time is set
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        trainerId,
        dayOfWeek,
        startTime,
        endTime,
        isRecurring,
        notes,
        createdAt,
      ];
}

/// Represents an attendance record for a specific day
class Attendance extends Equatable {
  final String id;
  final String clientId;
  final String trainerId;
  final DateTime scheduledTime;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? workoutId;
  final String? notes;
  final DateTime createdAt;

  const Attendance({
    required this.id,
    required this.clientId,
    required this.trainerId,
    required this.scheduledTime,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.workoutId,
    this.notes,
    required this.createdAt,
  });

  /// Whether the client was late
  bool get wasLate {
    if (checkInTime == null) return false;
    return checkInTime!.isAfter(scheduledTime.add(const Duration(minutes: 10)));
  }

  /// How late the client was (if late)
  Duration? get lateBy {
    if (checkInTime == null || !wasLate) return null;
    return checkInTime!.difference(scheduledTime);
  }

  /// Session duration (check-out - check-in)
  Duration? get sessionDuration {
    if (checkInTime == null || checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime!);
  }

  /// Whether a workout was logged for this session
  bool get hasWorkout => workoutId != null;

  Attendance copyWith({
    String? id,
    String? clientId,
    String? trainerId,
    DateTime? scheduledTime,
    AttendanceStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? workoutId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      trainerId: trainerId ?? this.trainerId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workoutId: workoutId ?? this.workoutId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        trainerId,
        scheduledTime,
        status,
        checkInTime,
        checkOutTime,
        workoutId,
        notes,
        createdAt,
      ];
}

/// A scheduled client with their attendance status for today's view
class TodayScheduledClient extends Equatable {
  final Client client;
  final ClientSchedule schedule;
  final Attendance? attendance;

  const TodayScheduledClient({
    required this.client,
    required this.schedule,
    this.attendance,
  });

  /// Current status for display
  AttendanceStatus get status => attendance?.status ?? AttendanceStatus.scheduled;

  /// Whether client has checked in
  bool get isCheckedIn => attendance?.checkInTime != null;

  /// Whether session is complete
  bool get isComplete => attendance?.status.isCompleted ?? false;

  /// Scheduled time for display
  DateTime get scheduledTime => schedule.startTime;

  @override
  List<Object?> get props => [client, schedule, attendance];
}

/// Daily attendance summary
class DailyAttendanceSummary extends Equatable {
  final DateTime date;
  final int totalScheduled;
  final int present;
  final int absent;
  final int cancelled;
  final int pending;
  final List<TodayScheduledClient> scheduledClients;

  const DailyAttendanceSummary({
    required this.date,
    required this.totalScheduled,
    required this.present,
    required this.absent,
    required this.cancelled,
    required this.pending,
    required this.scheduledClients,
  });

  /// Attendance rate for the day
  double get attendanceRate {
    final completed = present + absent;
    if (completed == 0) return 0;
    return present / completed;
  }

  /// Percentage of clients who showed up
  double get showRate {
    if (totalScheduled == 0) return 0;
    return present / totalScheduled;
  }

  /// Clients sorted by scheduled time
  List<TodayScheduledClient> get sortedByTime {
    final sorted = List<TodayScheduledClient>.from(scheduledClients);
    sorted.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return sorted;
  }

  /// Upcoming clients (not yet checked in)
  List<TodayScheduledClient> get upcomingClients {
    return scheduledClients
        .where((c) => c.status == AttendanceStatus.scheduled)
        .toList();
  }

  @override
  List<Object?> get props => [
        date,
        totalScheduled,
        present,
        absent,
        cancelled,
        pending,
        scheduledClients,
      ];
}

/// Attendance statistics for a client
class ClientAttendanceStats extends Equatable {
  final String clientId;
  final int totalSessions;
  final int attended;
  final int missed;
  final int cancelled;
  final double attendanceRate;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastAttendedDate;
  final Map<int, int> attendanceByDayOfWeek;

  const ClientAttendanceStats({
    required this.clientId,
    required this.totalSessions,
    required this.attended,
    required this.missed,
    required this.cancelled,
    required this.attendanceRate,
    required this.currentStreak,
    required this.longestStreak,
    this.lastAttendedDate,
    required this.attendanceByDayOfWeek,
  });

  /// Best day of the week for attendance
  String? get bestDayOfWeek {
    if (attendanceByDayOfWeek.isEmpty) return null;
    final bestDay = attendanceByDayOfWeek.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[bestDay.key % 7];
  }

  @override
  List<Object?> get props => [
        clientId,
        totalSessions,
        attended,
        missed,
        cancelled,
        attendanceRate,
        currentStreak,
        longestStreak,
        lastAttendedDate,
        attendanceByDayOfWeek,
      ];
}

