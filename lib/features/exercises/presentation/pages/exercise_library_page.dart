import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Exercise Library Page
class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final _searchController = TextEditingController();
  String _selectedMuscle = 'All';

  final List<String> _muscleGroups = [
    'All', 'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Legs', 'Core', 'Glutes'
  ];

  final List<ExerciseLibraryData> _exercises = [
    ExerciseLibraryData(name: 'Bench Press', muscleGroup: 'Chest', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Incline Bench Press', muscleGroup: 'Chest', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Dumbbell Flyes', muscleGroup: 'Chest', equipment: 'Dumbbells'),
    ExerciseLibraryData(name: 'Cable Crossovers', muscleGroup: 'Chest', equipment: 'Cable'),
    ExerciseLibraryData(name: 'Push-ups', muscleGroup: 'Chest', equipment: 'Bodyweight'),
    
    ExerciseLibraryData(name: 'Deadlift', muscleGroup: 'Back', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Barbell Rows', muscleGroup: 'Back', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Pull-ups', muscleGroup: 'Back', equipment: 'Bodyweight'),
    ExerciseLibraryData(name: 'Lat Pulldowns', muscleGroup: 'Back', equipment: 'Cable'),
    ExerciseLibraryData(name: 'Seated Rows', muscleGroup: 'Back', equipment: 'Cable'),
    
    ExerciseLibraryData(name: 'Shoulder Press', muscleGroup: 'Shoulders', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Lateral Raises', muscleGroup: 'Shoulders', equipment: 'Dumbbells'),
    ExerciseLibraryData(name: 'Front Raises', muscleGroup: 'Shoulders', equipment: 'Dumbbells'),
    ExerciseLibraryData(name: 'Face Pulls', muscleGroup: 'Shoulders', equipment: 'Cable'),
    
    ExerciseLibraryData(name: 'Bicep Curls', muscleGroup: 'Biceps', equipment: 'Dumbbells'),
    ExerciseLibraryData(name: 'Hammer Curls', muscleGroup: 'Biceps', equipment: 'Dumbbells'),
    ExerciseLibraryData(name: 'Preacher Curls', muscleGroup: 'Biceps', equipment: 'EZ Bar'),
    
    ExerciseLibraryData(name: 'Tricep Pushdowns', muscleGroup: 'Triceps', equipment: 'Cable'),
    ExerciseLibraryData(name: 'Skull Crushers', muscleGroup: 'Triceps', equipment: 'EZ Bar'),
    ExerciseLibraryData(name: 'Tricep Dips', muscleGroup: 'Triceps', equipment: 'Bodyweight'),
    
    ExerciseLibraryData(name: 'Squats', muscleGroup: 'Legs', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Leg Press', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseLibraryData(name: 'Romanian Deadlift', muscleGroup: 'Legs', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Leg Extensions', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseLibraryData(name: 'Leg Curls', muscleGroup: 'Legs', equipment: 'Machine'),
    ExerciseLibraryData(name: 'Calf Raises', muscleGroup: 'Legs', equipment: 'Machine'),
    
    ExerciseLibraryData(name: 'Plank', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseLibraryData(name: 'Crunches', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseLibraryData(name: 'Russian Twists', muscleGroup: 'Core', equipment: 'Bodyweight'),
    ExerciseLibraryData(name: 'Leg Raises', muscleGroup: 'Core', equipment: 'Bodyweight'),
    
    ExerciseLibraryData(name: 'Hip Thrusts', muscleGroup: 'Glutes', equipment: 'Barbell'),
    ExerciseLibraryData(name: 'Glute Bridges', muscleGroup: 'Glutes', equipment: 'Bodyweight'),
    ExerciseLibraryData(name: 'Cable Kickbacks', muscleGroup: 'Glutes', equipment: 'Cable'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise Library',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_exercises.length} exercises available',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.textTertiary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 16),

            // Muscle group filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _muscleGroups.map((muscle) {
                  final isSelected = _selectedMuscle == muscle;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMuscle = muscle),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.surfaceLighter,
                          ),
                        ),
                        child: Text(
                          muscle,
                          style: TextStyle(
                            color: isSelected ? AppColors.background : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Exercise list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  return _ExerciseListItem(
                    exercise: exercise,
                    onTap: () => _showExerciseDetail(exercise),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ExerciseLibraryData> get _filteredExercises {
    return _exercises.where((e) {
      final matchesSearch = _searchController.text.isEmpty ||
          e.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesMuscle = _selectedMuscle == 'All' || e.muscleGroup == _selectedMuscle;
      return matchesSearch && matchesMuscle;
    }).toList();
  }

  void _showExerciseDetail(ExerciseLibraryData exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ExerciseDetailSheet(exercise: exercise),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final ExerciseLibraryData exercise;
  final VoidCallback onTap;

  const _ExerciseListItem({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fitness_center,
                color: _getMuscleColor(exercise.muscleGroup),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getMuscleColor(exercise.muscleGroup).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          exercise.muscleGroup,
                          style: TextStyle(
                            color: _getMuscleColor(exercise.muscleGroup),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exercise.equipment,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Color _getMuscleColor(String muscle) {
    switch (muscle) {
      case 'Chest':
        return AppColors.primary;
      case 'Back':
        return AppColors.secondary;
      case 'Shoulders':
        return AppColors.accent;
      case 'Biceps':
        return AppColors.info;
      case 'Triceps':
        return AppColors.warning;
      case 'Legs':
        return const Color(0xFF9B59B6);
      case 'Core':
        return AppColors.error;
      case 'Glutes':
        return const Color(0xFFE91E63);
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ExerciseDetailSheet extends StatelessWidget {
  final ExerciseLibraryData exercise;

  const _ExerciseDetailSheet({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Exercise image placeholder
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 64, color: AppColors.textTertiary),
                    const SizedBox(height: 8),
                    Text(
                      'Exercise Demo',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                exercise.name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _InfoChip(label: exercise.muscleGroup, isPrimary: true),
                  const SizedBox(width: 8),
                  _InfoChip(label: exercise.equipment),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Instructions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              _InstructionStep(number: 1, text: 'Set up in the starting position with proper form.'),
              _InstructionStep(number: 2, text: 'Perform the movement with controlled tempo.'),
              _InstructionStep(number: 3, text: 'Focus on the target muscle contraction.'),
              _InstructionStep(number: 4, text: 'Return to starting position and repeat.'),
              
              const SizedBox(height: 24),
              
              Text(
                'Tips',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Keep your core engaged throughout the movement for stability and injury prevention.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got It'),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _InfoChip({required this.label, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? AppColors.primary : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseLibraryData {
  final String name;
  final String muscleGroup;
  final String equipment;

  ExerciseLibraryData({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
  });
}
