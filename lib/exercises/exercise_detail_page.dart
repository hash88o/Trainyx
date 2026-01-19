import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/exercise_data.dart';

class ExerciseDetailPage extends StatefulWidget {
  final ExerciseData exercise;

  const ExerciseDetailPage({
    required this.exercise,
    super.key,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.hasVideo && widget.exercise.localVideoPath != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.exercise.localVideoPath!);
      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      // Video failed to load
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media display (image or video)
            _buildMediaDisplay(colorScheme),
            
            // Exercise information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Primary muscle
                  if (widget.exercise.primaryMuscle.isNotEmpty)
                    _buildInfoRow(
                      Icons.accessibility_new,
                      'Primary Muscle',
                      widget.exercise.primaryMuscle,
                      colorScheme,
                    ),
                  
                  // Secondary muscle
                  if (widget.exercise.secondaryMuscle != null &&
                      widget.exercise.secondaryMuscle!.isNotEmpty)
                    _buildInfoRow(
                      Icons.accessibility,
                      'Secondary Muscles',
                      widget.exercise.secondaryMuscle!,
                      colorScheme,
                    ),
                  
                  // Equipment
                  if (widget.exercise.equipment.isNotEmpty &&
                      widget.exercise.equipment != 'None')
                    _buildInfoRow(
                      Icons.fitness_center,
                      'Equipment',
                      widget.exercise.equipment,
                      colorScheme,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Description placeholder (for future)
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Description will be added later.',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
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

  Widget _buildMediaDisplay(ColorScheme colorScheme) {
    if (widget.exercise.hasVideo && widget.exercise.localVideoPath != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: _isVideoInitialized && _videoController != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    VideoPlayer(_videoController!),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 64,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),
      );
    } else if (widget.exercise.hasImage &&
        widget.exercise.localImagePath != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          widget.exercise.localImagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.fitness_center,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

