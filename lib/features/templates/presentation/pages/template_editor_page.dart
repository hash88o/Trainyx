import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Template Editor Page for creating/editing workout templates
class TemplateEditorPage extends StatefulWidget {
  final String? templateId;

  const TemplateEditorPage({super.key, this.templateId});

  @override
  State<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends State<TemplateEditorPage> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Push';
  final List<TemplateExerciseData> _exercises = [];

  bool get isEditing => widget.templateId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Load existing template data
      _nameController.text = 'Push Day';
      _exercises.addAll([
        TemplateExerciseData(name: 'Bench Press', sets: 4),
        TemplateExerciseData(name: 'Incline DB Press', sets: 3),
        TemplateExerciseData(name: 'Shoulder Press', sets: 3),
      ]);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? 'Edit Template' : 'New Template',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveTemplate,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Template name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'e.g., Push Day, Upper Body',
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Category selector
                Text(
                  'Category',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Push', 'Pull', 'Legs', 'Upper', 'Lower', 'Full Body', 'HIIT', 'Custom']
                      .map((cat) => _CategoryChip(
                            label: cat,
                            isSelected: _selectedCategory == cat,
                            onTap: () => setState(() => _selectedCategory = cat),
                          ))
                      .toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Exercises section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercises',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addExercise,
                      icon: Icon(Icons.add, size: 18, color: AppColors.primary),
                      label: Text(
                        'Add Exercise',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                if (_exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.surfaceLighter,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: AppColors.textTertiary,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No exercises added yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "Add Exercise" to get started',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _exercises.removeAt(oldIndex);
                        _exercises.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return _ExerciseItem(
                        key: ValueKey(exercise.name + index.toString()),
                        index: index + 1,
                        exercise: exercise,
                        onSetsChanged: (sets) {
                          setState(() {
                            _exercises[index] = TemplateExerciseData(
                              name: exercise.name,
                              sets: sets,
                            );
                          });
                        },
                        onRemove: () {
                          setState(() {
                            _exercises.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ExercisePickerSheet(
        onExerciseSelected: (name) {
          setState(() {
            _exercises.add(TemplateExerciseData(name: name, sets: 3));
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _saveTemplate() {
    // TODO: Save template via BLoC
    context.pop();
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLighter,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final int index;
  final TemplateExerciseData exercise;
  final ValueChanged<int> onSetsChanged;
  final VoidCallback onRemove;

  const _ExerciseItem({
    super.key,
    required this.index,
    required this.exercise,
    required this.onSetsChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index - 1,
            child: Icon(Icons.drag_handle, color: AppColors.textTertiary),
          ),
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${exercise.sets} sets',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (exercise.sets > 1) {
                          onSetsChanged(exercise.sets - 1);
                        }
                      },
                      child: Icon(
                        Icons.remove_circle_outline,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => onSetsChanged(exercise.sets + 1),
                      child: Icon(
                        Icons.add_circle_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.error, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _ExercisePickerSheet extends StatefulWidget {
  final ValueChanged<String> onExerciseSelected;

  const _ExercisePickerSheet({required this.onExerciseSelected});

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _allExercises = [
    'Bench Press',
    'Incline Bench Press',
    'Dumbbell Press',
    'Shoulder Press',
    'Lateral Raises',
    'Tricep Pushdowns',
    'Deadlift',
    'Barbell Rows',
    'Pull-ups',
    'Lat Pulldowns',
    'Face Pulls',
    'Bicep Curls',
    'Squats',
    'Leg Press',
    'Romanian Deadlift',
    'Leg Extensions',
    'Leg Curls',
    'Calf Raises',
    'Lunges',
    'Hip Thrusts',
    'Burpees',
    'Kettlebell Swings',
    'Box Jumps',
    'Battle Ropes',
    'Mountain Climbers',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _allExercises.where((e) {
      final matchesSearch = _searchController.text.isEmpty ||
          e.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesSearch;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Exercise',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  return ListTile(
                    onTap: () => widget.onExerciseSelected(exercise),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      exercise,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.add_circle_outline, color: AppColors.primary),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class TemplateExerciseData {
  final String name;
  final int sets;

  TemplateExerciseData({required this.name, required this.sets});
}
