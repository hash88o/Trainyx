class ExerciseData {
  final String name;
  final String equipment;
  final String primaryMuscle;
  final String? secondaryMuscle;
  final String? sourceUrl;
  final String? sourceType; // 'image' or 'video'
  final String? localImagePath;
  final String? localVideoPath;

  ExerciseData({
    required this.name,
    required this.equipment,
    required this.primaryMuscle,
    this.secondaryMuscle,
    this.sourceUrl,
    this.sourceType,
    this.localImagePath,
    this.localVideoPath,
  });

  bool get hasImage => localImagePath != null || (sourceType == 'image' && sourceUrl != null);
  bool get hasVideo => localVideoPath != null || (sourceType == 'video' && sourceUrl != null);
  bool get hasMedia => hasImage || hasVideo;
}

