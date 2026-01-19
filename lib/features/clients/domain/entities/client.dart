import 'package:equatable/equatable.dart';

/// Client entity representing a trainer's client
class Client extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatarUrl;
  final String trainerId;
  final ClientProfile? profile;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Client({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatarUrl,
    required this.trainerId,
    this.profile,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full name of the client
  String get fullName => '$firstName $lastName';

  /// Initials for avatar placeholder
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Creates a copy with modified fields
  Client copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? trainerId,
    ClientProfile? profile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      trainerId: trainerId ?? this.trainerId,
      profile: profile ?? this.profile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        avatarUrl,
        trainerId,
        profile,
        createdAt,
        updatedAt,
      ];
}

/// Extended profile information for a client
class ClientProfile extends Equatable {
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final String? goal;
  final String? notes;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final List<String>? medicalConditions;
  final DateTime? memberSince;

  const ClientProfile({
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.targetWeightKg,
    this.goal,
    this.notes,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalConditions,
    this.memberSince,
  });

  /// Calculates age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int calculatedAge = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// Calculates BMI if height and weight are available
  double? get bmi {
    if (heightCm == null || currentWeightKg == null) return null;
    if (heightCm! <= 0) return null;
    final heightM = heightCm! / 100;
    return currentWeightKg! / (heightM * heightM);
  }

  /// Returns BMI category
  String? get bmiCategory {
    final calculatedBmi = bmi;
    if (calculatedBmi == null) return null;
    if (calculatedBmi < 18.5) return 'Underweight';
    if (calculatedBmi < 25) return 'Normal';
    if (calculatedBmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Height formatted in feet and inches
  String? get heightFormatted {
    if (heightCm == null) return null;
    final totalInches = heightCm! / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

  ClientProfile copyWith({
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? goal,
    String? notes,
    String? emergencyContactName,
    String? emergencyContactPhone,
    List<String>? medicalConditions,
    DateTime? memberSince,
  }) {
    return ClientProfile(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goal: goal ?? this.goal,
      notes: notes ?? this.notes,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  @override
  List<Object?> get props => [
        dateOfBirth,
        gender,
        heightCm,
        currentWeightKg,
        targetWeightKg,
        goal,
        notes,
        emergencyContactName,
        emergencyContactPhone,
        medicalConditions,
        memberSince,
      ];
}

/// Quick stats for a client
class ClientStats extends Equatable {
  final int totalWorkouts;
  final int workoutsThisMonth;
  final DateTime? lastWorkoutDate;
  final double attendanceRate;
  final int personalRecords;
  final double? weightChange; // Positive = gained, Negative = lost

  const ClientStats({
    required this.totalWorkouts,
    required this.workoutsThisMonth,
    this.lastWorkoutDate,
    required this.attendanceRate,
    required this.personalRecords,
    this.weightChange,
  });

  @override
  List<Object?> get props => [
        totalWorkouts,
        workoutsThisMonth,
        lastWorkoutDate,
        attendanceRate,
        personalRecords,
        weightChange,
      ];
}

