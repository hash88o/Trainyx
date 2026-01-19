import 'package:equatable/equatable.dart';

/// Represents a diet plan created by a trainer for a client
class DietPlan extends Equatable {
  final String id;
  final String clientId;
  final String trainerId;
  final String? name;
  final int targetCalories;
  final int targetProteinG;
  final int targetCarbsG;
  final int targetFatG;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<RecommendedMeal> meals;
  final DateTime createdAt;

  const DietPlan({
    required this.id,
    required this.clientId,
    required this.trainerId,
    this.name,
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatG,
    this.notes,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.meals = const [],
    required this.createdAt,
  });

  /// Total recommended macros from all meals
  MacroSummary get totalRecommendedMacros {
    return meals.fold(
      MacroSummary.zero(),
      (sum, meal) => sum + meal.macros,
    );
  }

  /// Whether the diet plan is currently valid (within date range)
  bool get isCurrentlyValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  DietPlan copyWith({
    String? id,
    String? clientId,
    String? trainerId,
    String? name,
    int? targetCalories,
    int? targetProteinG,
    int? targetCarbsG,
    int? targetFatG,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<RecommendedMeal>? meals,
    DateTime? createdAt,
  }) {
    return DietPlan(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      trainerId: trainerId ?? this.trainerId,
      name: name ?? this.name,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetFatG: targetFatG ?? this.targetFatG,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      meals: meals ?? this.meals,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        trainerId,
        name,
        targetCalories,
        targetProteinG,
        targetCarbsG,
        targetFatG,
        notes,
        startDate,
        endDate,
        isActive,
        meals,
        createdAt,
      ];
}

/// Meal type enum
enum MealType {
  breakfast('Breakfast'),
  morningSnack('Morning Snack'),
  lunch('Lunch'),
  afternoonSnack('Afternoon Snack'),
  dinner('Dinner'),
  eveningSnack('Evening Snack');

  final String label;
  const MealType(this.label);
}

/// A recommended meal in a diet plan
class RecommendedMeal extends Equatable {
  final String id;
  final String dietPlanId;
  final MealType type;
  final String name;
  final String? description;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final DateTime? timeOfDay;
  final List<String>? ingredients;

  const RecommendedMeal({
    required this.id,
    required this.dietPlanId,
    required this.type,
    required this.name,
    this.description,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.timeOfDay,
    this.ingredients,
  });

  MacroSummary get macros => MacroSummary(
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
      );

  @override
  List<Object?> get props => [
        id,
        dietPlanId,
        type,
        name,
        description,
        calories,
        proteinG,
        carbsG,
        fatG,
        timeOfDay,
        ingredients,
      ];
}

/// A food item logged by the client
class FoodLog extends Equatable {
  final String id;
  final String userId;
  final MealType type;
  final String name;
  final String? description;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double? servingSize;
  final String? servingUnit;
  final DateTime loggedAt;

  const FoodLog({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.description,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.servingSize,
    this.servingUnit,
    required this.loggedAt,
  });

  MacroSummary get macros => MacroSummary(
        calories: calories,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        name,
        calories,
        proteinG,
        carbsG,
        fatG,
        servingSize,
        servingUnit,
        loggedAt,
      ];
}

/// Summary of macronutrients
class MacroSummary extends Equatable {
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MacroSummary({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory MacroSummary.zero() => const MacroSummary(
        calories: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
      );

  /// Protein percentage of total calories (4 cal/g)
  double get proteinPercent {
    if (calories == 0) return 0;
    return (proteinG * 4 / calories) * 100;
  }

  /// Carbs percentage of total calories (4 cal/g)
  double get carbsPercent {
    if (calories == 0) return 0;
    return (carbsG * 4 / calories) * 100;
  }

  /// Fat percentage of total calories (9 cal/g)
  double get fatPercent {
    if (calories == 0) return 0;
    return (fatG * 9 / calories) * 100;
  }

  MacroSummary operator +(MacroSummary other) {
    return MacroSummary(
      calories: calories + other.calories,
      proteinG: proteinG + other.proteinG,
      carbsG: carbsG + other.carbsG,
      fatG: fatG + other.fatG,
    );
  }

  @override
  List<Object?> get props => [calories, proteinG, carbsG, fatG];
}

/// Comparison of recommended vs actual diet for a day
class DietComparison extends Equatable {
  final DateTime date;
  final MacroSummary recommended;
  final MacroSummary actual;
  final List<FoodLog> foodLogs;

  const DietComparison({
    required this.date,
    required this.recommended,
    required this.actual,
    required this.foodLogs,
  });

  /// Calories difference (positive = over, negative = under)
  int get caloriesDifference => actual.calories - recommended.calories;

  /// Protein completion percentage
  double get proteinCompletion {
    if (recommended.proteinG == 0) return 0;
    return (actual.proteinG / recommended.proteinG) * 100;
  }

  /// Carbs completion percentage
  double get carbsCompletion {
    if (recommended.carbsG == 0) return 0;
    return (actual.carbsG / recommended.carbsG) * 100;
  }

  /// Fat completion percentage
  double get fatCompletion {
    if (recommended.fatG == 0) return 0;
    return (actual.fatG / recommended.fatG) * 100;
  }

  /// Overall diet adherence score (0-100)
  double get adherenceScore {
    // Weight: protein 40%, carbs 30%, fat 20%, calories 10%
    final proteinScore = _clampedScore(proteinCompletion);
    final carbsScore = _clampedScore(carbsCompletion);
    final fatScore = _clampedScore(fatCompletion);
    final caloriesScore = _clampedScore(
      recommended.calories > 0
          ? (actual.calories / recommended.calories) * 100
          : 0,
    );

    return proteinScore * 0.4 + carbsScore * 0.3 + fatScore * 0.2 + caloriesScore * 0.1;
  }

  double _clampedScore(double percentage) {
    // 100% is perfect, <80% or >120% starts reducing score
    if (percentage >= 80 && percentage <= 120) {
      // Within 20%, give bonus for being close to 100%
      return 100 - (percentage - 100).abs();
    } else if (percentage < 80) {
      return percentage;
    } else {
      return 100 - (percentage - 100);
    }
  }

  /// Summary text for the day's diet
  String get summaryText {
    if (adherenceScore >= 90) return 'Excellent!';
    if (adherenceScore >= 75) return 'Good job!';
    if (adherenceScore >= 50) return 'Keep going';
    return 'Needs improvement';
  }

  @override
  List<Object?> get props => [date, recommended, actual, foodLogs];
}

/// Weekly diet summary
class WeeklyDietSummary extends Equatable {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<DietComparison> dailyComparisons;
  final double averageAdherence;
  final int daysTracked;

  const WeeklyDietSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.dailyComparisons,
    required this.averageAdherence,
    required this.daysTracked,
  });

  /// Average macros for the week
  MacroSummary get averageActualMacros {
    if (dailyComparisons.isEmpty) return MacroSummary.zero();
    final total = dailyComparisons.fold(
      MacroSummary.zero(),
      (sum, day) => sum + day.actual,
    );
    return MacroSummary(
      calories: (total.calories / dailyComparisons.length).round(),
      proteinG: total.proteinG / dailyComparisons.length,
      carbsG: total.carbsG / dailyComparisons.length,
      fatG: total.fatG / dailyComparisons.length,
    );
  }

  @override
  List<Object?> get props => [
        weekStart,
        weekEnd,
        dailyComparisons,
        averageAdherence,
        daysTracked,
      ];
}

