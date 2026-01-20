import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/heatmap/fitness_activity_heatmap.dart';

/// Progress Page with workout heatmap and dated progress photos
class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                    'Progress',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your fitness journey',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'Activity'),
                  Tab(text: 'Photos'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ActivityTab(),
                  _PhotosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity Tab - Workout heatmap and stats
class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout Heatmap (fitness-friendly, period-based)
          const FitnessActivityHeatmap(
            seedKey: 'progress',
            subtitle: 'Consistency over time',
          ),

          const SizedBox(height: 20),

          // Stats summary
          Row(
            children: [
              _StatCard(
                icon: Icons.local_fire_department,
                value: '156',
                label: 'Total Workouts',
                color: AppColors.secondary,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.calendar_today,
                value: '24',
                label: 'Current Streak',
                color: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _StatCard(
                icon: Icons.trending_up,
                value: '87%',
                label: 'Consistency',
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.emoji_events,
                value: '42',
                label: 'PRs Set',
                color: AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Monthly breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Breakdown',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _MonthRow(month: 'January 2026', workouts: 18, target: 20),
                _MonthRow(month: 'December 2025', workouts: 22, target: 20),
                _MonthRow(month: 'November 2025', workouts: 19, target: 20),
                _MonthRow(month: 'October 2025', workouts: 16, target: 20),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.background, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  final String month;
  final int workouts;
  final int target;

  const _MonthRow({
    required this.month,
    required this.workouts,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = workouts / target;
    final isOnTarget = percentage >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$workouts / $target',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isOnTarget)
                    Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(
                isOnTarget ? AppColors.secondary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photos Tab - Progress photos by date
class _PhotosTab extends StatelessWidget {
  const _PhotosTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add photo button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Add photo
              },
              icon: const Icon(Icons.add_a_photo, size: 20),
              label: const Text('Add Progress Photo'),
            ),
          ),

          const SizedBox(height: 20),

          // Photo timeline
          const _PhotoTimelineSection(
            month: 'January 2026',
            photos: [
              ProgressPhotoData(day: 15, type: 'Front'),
              ProgressPhotoData(day: 15, type: 'Side'),
              ProgressPhotoData(day: 15, type: 'Back'),
              ProgressPhotoData(day: 1, type: 'Front'),
              ProgressPhotoData(day: 1, type: 'Side'),
            ],
          ),
          
          const _PhotoTimelineSection(
            month: 'December 2025',
            photos: [
              ProgressPhotoData(day: 20, type: 'Front'),
              ProgressPhotoData(day: 20, type: 'Side'),
              ProgressPhotoData(day: 20, type: 'Back'),
              ProgressPhotoData(day: 1, type: 'Front'),
            ],
          ),
          
          const _PhotoTimelineSection(
            month: 'November 2025',
            photos: [
              ProgressPhotoData(day: 15, type: 'Front'),
              ProgressPhotoData(day: 15, type: 'Side'),
            ],
          ),
          
          const _PhotoTimelineSection(
            month: 'October 2025',
            photos: [
              ProgressPhotoData(day: 10, type: 'Front'),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PhotoTimelineSection extends StatelessWidget {
  final String month;
  final List<ProgressPhotoData> photos;

  const _PhotoTimelineSection({required this.month, required this.photos});

  @override
  Widget build(BuildContext context) {
    // Group photos by day
    final groupedPhotos = <int, List<ProgressPhotoData>>{};
    for (final photo in photos) {
      groupedPhotos.putIfAbsent(photo.day, () => []).add(photo);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                month,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${photos.length} photos',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Date groups
          ...groupedPhotos.entries.map((entry) {
            final day = entry.key;
            final dayPhotos = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getDateLabel(month, day),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Photos grid
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dayPhotos.length,
                      itemBuilder: (context, index) {
                        final photo = dayPhotos[index];
                        return GestureDetector(
                          onTap: () {
                            // TODO: Show full photo
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.surfaceLighter),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: AppColors.textTertiary,
                                  size: 32,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  photo.type,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getDateLabel(String month, int day) {
    final monthName = month.split(' ')[0];
    return '$monthName $day';
  }
}

class ProgressPhotoData {
  final int day;
  final String type;

  const ProgressPhotoData({required this.day, required this.type});
}
