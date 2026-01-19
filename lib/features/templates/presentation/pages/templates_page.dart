import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_theme.dart';

/// Workout Templates Page
class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  final List<WorkoutTemplateData> _templates = [
    WorkoutTemplateData(
      id: '1',
      name: 'Push Day',
      exercises: ['Bench Press', 'Incline DB Press', 'Shoulder Press', 'Lateral Raises', 'Tricep Pushdowns'],
      estimatedDuration: 50,
      category: 'Push',
      timesUsed: 24,
    ),
    WorkoutTemplateData(
      id: '2',
      name: 'Pull Day',
      exercises: ['Deadlift', 'Barbell Rows', 'Pull-ups', 'Face Pulls', 'Bicep Curls'],
      estimatedDuration: 55,
      category: 'Pull',
      timesUsed: 22,
    ),
    WorkoutTemplateData(
      id: '3',
      name: 'Leg Day',
      exercises: ['Squats', 'Leg Press', 'Romanian Deadlift', 'Leg Extensions', 'Calf Raises'],
      estimatedDuration: 60,
      category: 'Legs',
      timesUsed: 20,
    ),
    WorkoutTemplateData(
      id: '4',
      name: 'Upper Body',
      exercises: ['Bench Press', 'Barbell Rows', 'Shoulder Press', 'Pull-ups', 'Curls', 'Tricep Dips'],
      estimatedDuration: 65,
      category: 'Upper',
      timesUsed: 15,
    ),
    WorkoutTemplateData(
      id: '5',
      name: 'Full Body HIIT',
      exercises: ['Burpees', 'Kettlebell Swings', 'Box Jumps', 'Battle Ropes', 'Mountain Climbers'],
      estimatedDuration: 30,
      category: 'HIIT',
      timesUsed: 8,
    ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Templates',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_templates.length} workout templates',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.templateEditorPath()),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Templates grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  return _TemplateCard(
                    template: template,
                    onTap: () => _showTemplateOptions(context, template),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateOptions(BuildContext context, WorkoutTemplateData template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TemplateOptionsSheet(
        template: template,
        onStartWorkout: () {
          Navigator.pop(context);
          context.go(AppRoutes.activeWorkout);
        },
        onEdit: () {
          Navigator.pop(context);
          context.go(AppRoutes.templateEditorPath(template.id));
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplateData template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLighter),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(template.category).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(template.category),
                    color: _getCategoryColor(template.category),
                    size: 22,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    template.category,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              template.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${template.exercises.length} exercises',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '~${template.estimatedDuration} min',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  '${template.timesUsed}x',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'push':
        return AppColors.primary;
      case 'pull':
        return AppColors.secondary;
      case 'legs':
        return AppColors.accent;
      case 'upper':
        return AppColors.info;
      case 'hiit':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'push':
        return Icons.arrow_upward;
      case 'pull':
        return Icons.arrow_downward;
      case 'legs':
        return Icons.directions_run;
      case 'upper':
        return Icons.accessibility_new;
      case 'hiit':
        return Icons.local_fire_department;
      default:
        return Icons.fitness_center;
    }
  }
}

class _TemplateOptionsSheet extends StatelessWidget {
  final WorkoutTemplateData template;
  final VoidCallback onStartWorkout;
  final VoidCallback onEdit;

  const _TemplateOptionsSheet({
    required this.template,
    required this.onStartWorkout,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${template.exercises.length} exercises • ~${template.estimatedDuration} min',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Exercise list
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: template.exercises.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${entry.key + 1}.',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStartWorkout,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Template'),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class WorkoutTemplateData {
  final String id;
  final String name;
  final List<String> exercises;
  final int estimatedDuration;
  final String category;
  final int timesUsed;

  WorkoutTemplateData({
    required this.id,
    required this.name,
    required this.exercises,
    required this.estimatedDuration,
    required this.category,
    required this.timesUsed,
  });
}
