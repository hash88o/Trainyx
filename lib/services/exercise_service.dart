import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../models/exercise_data.dart';

class ExerciseService {
  static List<ExerciseData>? _cachedExercises;

  static Future<List<ExerciseData>> loadExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    try {
      var csvData = await rootBundle.loadString('assets/exercises_data.csv');
      
      // Debug: print length and preview
      print('ExerciseService: CSV data length: ${csvData.length}');
      
      // Normalize line endings for cross-platform compatibility
      // Replace Windows-style \r\n with \n, then any remaining \r with \n
      csvData = csvData.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      
      // Parse CSV with explicit settings
      var csvTable = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvData);
      
      print('ExerciseService: Loaded CSV with ${csvTable.length} rows');
      
      // If we only got one row, try without specifying eol
      if (csvTable.length <= 1) {
        print('ExerciseService: Retrying with auto-detect eol...');
        csvTable = const CsvToListConverter(
          shouldParseNumbers: false,
        ).convert(csvData);
        print('ExerciseService: Second attempt: ${csvTable.length} rows');
      }
      
      if (csvTable.isEmpty || csvTable.length < 2) {
        print('ExerciseService: CSV is empty or has no data rows');
        print('ExerciseService: First row: ${csvTable.isNotEmpty ? csvTable.first : "empty"}');
        return [];
      }

      // Skip header row
      final exercises = <ExerciseData>[];
      int skippedRows = 0;
      
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length < 6) {
          skippedRows++;
          continue;
        }

        final name = row[0]?.toString().trim() ?? '';
        final equipment = row[1]?.toString().trim() ?? '';
        final primaryMuscle = row[2]?.toString().trim() ?? '';
        final secondaryMuscle = row[3]?.toString().trim() ?? '';
        final sourceUrl = row[4]?.toString().trim() ?? '';
        final sourceType = row[5]?.toString().trim() ?? '';
        
        if (name.isEmpty) {
          skippedRows++;
          continue;
        }

        // Map source URL to local asset path
        String? localImagePath;
        String? localVideoPath;
        
        if (sourceUrl.isNotEmpty && sourceUrl != 'None') {
          final fileName = p.basename(sourceUrl);
          if (sourceType == 'image') {
            localImagePath = 'exercise-assets/images/$fileName';
          } else if (sourceType == 'video') {
            localVideoPath = 'exercise-assets/videos/$fileName';
          }
        }

        exercises.add(ExerciseData(
          name: name,
          equipment: equipment,
          primaryMuscle: primaryMuscle,
          secondaryMuscle: secondaryMuscle.isEmpty || secondaryMuscle == 'None' 
              ? null 
              : secondaryMuscle,
          sourceUrl: sourceUrl.isEmpty || sourceUrl == 'None' ? null : sourceUrl,
          sourceType: sourceType.isEmpty || sourceType == 'None' ? null : sourceType,
          localImagePath: localImagePath,
          localVideoPath: localVideoPath,
        ));
      }

      print('ExerciseService: Loaded ${exercises.length} exercises (skipped $skippedRows rows)');
      _cachedExercises = exercises;
      return exercises;
    } catch (e, stackTrace) {
      print('ExerciseService: Error loading exercises: $e');
      print('ExerciseService: Stack trace: $stackTrace');
      return [];
    }
  }

  static List<ExerciseData> searchExercises(
    List<ExerciseData> exercises,
    String query,
  ) {
    if (query.isEmpty) return exercises;

    final lowerQuery = query.toLowerCase().trim();
    final queryWords = lowerQuery.split(RegExp(r'\s+'));
    
    // Common muscle group aliases for better search
    final muscleAliases = <String, List<String>>{
      'back': ['upper back', 'lower back', 'lats', 'latissimus'],
      'lats': ['upper back', 'latissimus', 'lat pulldown'],
      'arms': ['biceps', 'triceps', 'forearms'],
      'legs': ['quadriceps', 'hamstrings', 'calves', 'glutes'],
      'quads': ['quadriceps'],
      'hams': ['hamstrings'],
      'abs': ['abdominals', 'core'],
      'core': ['abdominals', 'abs'],
      'shoulders': ['deltoids', 'delts'],
      'delts': ['shoulders', 'deltoids'],
      'pecs': ['chest'],
      'glutes': ['glutes', 'hips'],
      'butt': ['glutes', 'hips'],
    };
    
    // Score exercises based on relevance
    final scored = exercises.map((exercise) {
      int score = 0;
      final lowerName = exercise.name.toLowerCase();
      final lowerPrimaryMuscle = exercise.primaryMuscle.toLowerCase();
      final lowerSecondaryMuscle = exercise.secondaryMuscle?.toLowerCase() ?? '';
      final lowerEquipment = exercise.equipment.toLowerCase();
      
      // Check each query word
      for (final word in queryWords) {
        if (word.isEmpty) continue;
        
        // Exact name match gets highest score
        if (lowerName == word) {
          score += 1000;
        }
        // Name starts with query word
        else if (lowerName.startsWith(word)) {
          score += 500;
        }
        // Name contains query word
        else if (lowerName.contains(word)) {
          score += 200;
        }
        // Any word in the name starts with query word
        else if (lowerName.split(RegExp(r'[\s\-\(\)]+')).any((w) => w.startsWith(word))) {
          score += 150;
        }
        
        // Check primary muscle - exact word match
        if (lowerPrimaryMuscle == word) {
          score += 100;
        } else if (lowerPrimaryMuscle.contains(word)) {
          score += 80;
        } else if (lowerPrimaryMuscle.split(RegExp(r'[\s,]+')).any((w) => w.startsWith(word))) {
          score += 60;
        }
        
        // Check muscle aliases
        final aliases = muscleAliases[word];
        if (aliases != null) {
          for (final alias in aliases) {
            if (lowerPrimaryMuscle.contains(alias) || lowerName.contains(alias)) {
              score += 70;
              break;
            }
            if (lowerSecondaryMuscle.contains(alias)) {
              score += 35;
              break;
            }
          }
        }
        
        // Check secondary muscle
        if (lowerSecondaryMuscle.isNotEmpty) {
          if (lowerSecondaryMuscle.contains(word)) {
            score += 40;
          } else if (lowerSecondaryMuscle.split(RegExp(r'[\s,]+')).any((w) => w.startsWith(word))) {
            score += 30;
          }
        }
        
        // Check equipment
        if (lowerEquipment.contains(word)) {
          score += 25;
        }
      }
      
      // Bonus for exercises with media assets
      if (exercise.hasMedia && score > 0) {
        score += 5;
      }

      return (exercise: exercise, score: score);
    }).toList();

    // Sort by score descending, then by name
    scored.sort((a, b) {
      if (a.score != b.score) {
        return b.score.compareTo(a.score);
      }
      return a.exercise.name.compareTo(b.exercise.name);
    });

    // Return only exercises with score > 0, limit to top 100
    return scored
        .where((item) => item.score > 0)
        .take(100)
        .map((item) => item.exercise)
        .toList();
  }

  static void clearCache() {
    _cachedExercises = null;
  }
}

