import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WorkoutDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'fitcoach.db');

    _database = await openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            weight REAL NOT NULL,
            reps INTEGER NOT NULL,
            sets INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE workout_sets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_id INTEGER NOT NULL,
            set_number INTEGER NOT NULL,
            weight REAL NOT NULL,
            reps INTEGER NOT NULL,
            FOREIGN KEY (workout_id)
              REFERENCES workouts(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE nutrition_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_name TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            amount_grams REAL NOT NULL,
            calories REAL NOT NULL,
            protein_grams REAL NOT NULL,
            eaten_at TEXT NOT NULL
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE workout_sets (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              workout_id INTEGER NOT NULL,
              set_number INTEGER NOT NULL,
              weight REAL NOT NULL,
              reps INTEGER NOT NULL,
              FOREIGN KEY (workout_id)
                REFERENCES workouts(id)
                ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 3) {
  await db.execute('''
    CREATE TABLE nutrition_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      food_name TEXT NOT NULL,
      meal_type TEXT NOT NULL,
      amount_grams REAL NOT NULL,
      calories REAL NOT NULL,
      protein_grams REAL NOT NULL,
      eaten_at TEXT NOT NULL
    )
  ''');
}
      },
    );

    return _database!;
  }

  static Future<int> insertWorkout({
  required String name,
  required double weight,
  required int reps,
  required int sets,
  required DateTime workoutDate,
}) async {
  final db = await database;

  return db.insert('workouts', {
    'name': name,
    'weight': weight,
    'reps': reps,
    'sets': sets,
    'created_at': workoutDate.toIso8601String(),
  });
}

  static Future<List<Map<String, dynamic>>> getWorkouts() async {
    final db = await database;

    return db.query(
      'workouts',
      orderBy: 'created_at DESC, id DESC',
    );
  }

  static Future<int> deleteWorkout(int id) async {
    final db = await database;

    return db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  static Future<int> updateWorkout({
  required int id,
  required String name,
  required double weight,
  required int reps,
  required int sets,
}) async {
  final db = await database;

  return db.update(
    'workouts',
    {
      'name': name,
      'weight': weight,
      'reps': reps,
      'sets': sets,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

static Future<bool> workoutExists(int workoutId) async {
  final db = await database;

  final result = await db.query(
    'workouts',
    columns: ['id'],
    where: 'id = ?',
    whereArgs: [workoutId],
    limit: 1,
  );

  return result.isNotEmpty;
}

static Future<Map<String, dynamic>?> getWorkoutById(
  int workoutId,
) async {
  final db = await database;

  final results = await db.query(
    'workouts',
    where: 'id = ?',
    whereArgs: [workoutId],
    limit: 1,
  );

  if (results.isEmpty) {
    return null;
  }

  return results.first;
}

static Future<void> updateWorkoutWithSets({
  required int workoutId,
  required String name,
  required List<Map<String, dynamic>> workoutSets,
}) async {
  if (workoutId <= 0) {
    throw ArgumentError('올바르지 않은 운동 기록 ID입니다.');
  }

  if (name.trim().isEmpty) {
    throw ArgumentError('운동 이름을 입력해야 합니다.');
  }

  if (workoutSets.isEmpty) {
    throw ArgumentError('최소 1개의 세트가 필요합니다.');
  }

  for (final set in workoutSets) {
    final weight = set['weight'];
    final reps = set['reps'];

    if (weight is! num ||
        !weight.toDouble().isFinite ||
        weight < 0 ||
        reps is! int ||
        reps <= 0) {
      throw ArgumentError('세트별 중량과 반복 횟수를 확인해 주세요.');
    }
  }

  final db = await database;

  await db.transaction((txn) async {
  // 1. 기존 운동 기록 확인
  final existing = await txn.query(
    'workouts',
    columns: ['id'],
    where: 'id = ?',
    whereArgs: [workoutId],
    limit: 1,
  );

  if (existing.isEmpty) {
    throw StateError('수정할 운동 기록이 존재하지 않습니다.');
  }

  // 2. 세트별 기록인지 확인
  final existingSets = await txn.query(
    'workout_sets',
    columns: ['id'],
    where: 'workout_id = ?',
    whereArgs: [workoutId],
    limit: 1,
  );

  if (existingSets.isEmpty) {
    throw StateError('세트별 운동 기록이 아닙니다.');
  }

  // 3. 새로운 합계 계산
  final totalReps = workoutSets.fold<int>(
    0,
    (sum, set) => sum + (set['reps'] as int),
  );

  final maxWeight = workoutSets
      .map((set) => (set['weight'] as num).toDouble())
      .reduce((a, b) => a > b ? a : b);

  // 4. 부모 운동 기록 수정
  await txn.update(
    'workouts',
    {
      'name': name.trim(),
      'weight': maxWeight,
      'reps': totalReps,
      'sets': workoutSets.length,
    },
    where: 'id = ?',
    whereArgs: [workoutId],
  );

  // 5. 기존 세트 데이터 삭제
  await txn.delete(
    'workout_sets',
    where: 'workout_id = ?',
    whereArgs: [workoutId],
  );

  // 6. 수정된 세트 데이터 저장
  for (int i = 0; i < workoutSets.length; i++) {
    final set = workoutSets[i];

    await txn.insert(
      'workout_sets',
      {
        'workout_id': workoutId,
        'set_number': i + 1,
        'weight': (set['weight'] as num).toDouble(),
        'reps': set['reps'] as int,
      },
    );
  }
});

}

static Future<int> insertWorkoutSet({
  required int workoutId,
  required int setNumber,
  required double weight,
  required int reps,
}) async {
  if (workoutId <= 0 ||
      setNumber <= 0 ||
      !weight.isFinite ||
      weight < 0 ||
      reps <= 0) {
    throw ArgumentError('올바르지 않은 세트 기록입니다.');
  }

  final db = await database;

  return db.insert(
    'workout_sets',
    {
      'workout_id': workoutId,
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
    },
  );
}
static Future<List<Map<String, dynamic>>> getWorkoutSets(
  int workoutId,
) async {
  if (workoutId <= 0) {
    throw ArgumentError('올바르지 않은 운동 기록 ID입니다.');
  }

  final db = await database;

  return db.query(
    'workout_sets',
    where: 'workout_id = ?',
    whereArgs: [workoutId],
    orderBy: 'set_number ASC, id ASC',
  );
}
static Future<int> insertWorkoutWithSets({
  required String name,
  required DateTime workoutDate,
  required List<Map<String, dynamic>> workoutSets,
}) async {
  if (name.trim().isEmpty || workoutSets.isEmpty) {
    throw ArgumentError('운동 이름과 세트 기록이 필요합니다.');
  }

  int totalReps = 0;
  double maxWeight = 0;

  for (final set in workoutSets) {
    final weight = (set['weight'] as num).toDouble();
    final reps = (set['reps'] as num).toInt();

    if (!weight.isFinite || weight < 0 || reps <= 0) {
      throw ArgumentError('올바르지 않은 세트 기록입니다.');
    }

    totalReps += reps;

    if (weight > maxWeight) {
      maxWeight = weight;
    }
  }

  final totalSets = workoutSets.length;

  final db = await database;

  return db.transaction((txn) async {
    final workoutId = await txn.insert(
      'workouts',
      {
        'name': name.trim(),
        'weight': maxWeight,
        'reps': totalReps,
        'sets': totalSets,
        'created_at': workoutDate.toIso8601String(),
      },
    );

    for (int i = 0; i < workoutSets.length; i++) {
      final set = workoutSets[i];

      await txn.insert(
        'workout_sets',
        {
          'workout_id': workoutId,
          'set_number': i + 1,
          'weight': (set['weight'] as num).toDouble(),
          'reps': (set['reps'] as num).toInt(),
        },
      );
    }

    return workoutId;
  });
}
static Future<Set<int>> getWorkoutIdsWithSets() async {
  final db = await database;

  final results = await db.rawQuery('''
    SELECT DISTINCT workout_id
    FROM workout_sets
  ''');

  return results
      .map((row) => (row['workout_id'] as num).toInt())
      .toSet();
}
static Future<List<String>> getTableNames() async {
  final db = await database;

  final result = await db.rawQuery(
    "SELECT name FROM sqlite_master "
    "WHERE type = 'table' "
    "ORDER BY name",
  );

  return result
      .map((row) => row['name'] as String)
      .toList();
}
static Future<int> insertNutritionRecord({
  required String foodName,
  required String mealType,
  required double amountGrams,
  required double calories,
  required double proteinGrams,
  required DateTime eatenAt,
}) async {
  if (foodName.trim().isEmpty) {
    throw ArgumentError('음식 이름을 입력해야 합니다.');
  }

  if (!['아침', '점심', '저녁', '간식'].contains(mealType)) {
    throw ArgumentError('올바른 식사 구분을 선택해야 합니다.');
  }

  if (!amountGrams.isFinite || amountGrams <= 0) {
    throw ArgumentError('섭취량은 0보다 커야 합니다.');
  }

  if (!calories.isFinite || calories < 0) {
    throw ArgumentError('칼로리는 0 이상이어야 합니다.');
  }

  if (!proteinGrams.isFinite || proteinGrams < 0) {
    throw ArgumentError('단백질은 0 이상이어야 합니다.');
  }

  final db = await database;

  return db.insert(
    'nutrition_records',
    {
      'food_name': foodName.trim(),
      'meal_type': mealType,
      'amount_grams': amountGrams,
      'calories': calories,
      'protein_grams': proteinGrams,
      'eaten_at': eatenAt.toIso8601String(),
    },
  );
}
static Future<List<Map<String, dynamic>>> getNutritionRecords() async {
  final db = await database;

  return db.query(
    'nutrition_records',
    orderBy: 'eaten_at DESC, id DESC',
  );
}
static Future<Map<String, double>> getTodayNutritionTotals() async {
  final db = await database;

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final result = await db.rawQuery(
    '''
    SELECT
      COALESCE(SUM(calories), 0) AS total_calories,
      COALESCE(SUM(protein_grams), 0) AS total_protein
    FROM nutrition_records
    WHERE eaten_at >= ? AND eaten_at < ?
    ''',
    [
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ],
  );

  final row = result.first;

  return {
    'calories': (row['total_calories'] as num).toDouble(),
    'protein': (row['total_protein'] as num).toDouble(),
  };
}
static Future<List<Map<String, dynamic>>>
    getNutritionRecordsByDate(DateTime date) async {
  final db = await database;

  final startOfDay = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final endOfDay = DateTime(
    date.year,
    date.month,
    date.day + 1,
  );

  return db.query(
    'nutrition_records',
    where: 'eaten_at >= ? AND eaten_at < ?',
    whereArgs: [
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ],
    orderBy: 'eaten_at DESC, id DESC',
  );
}
static Future<Map<String, double>> getNutritionTotalsByDate(
  DateTime date,
) async {
  final db = await database;

  final startOfDay = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final endOfDay = DateTime(
    date.year,
    date.month,
    date.day + 1,
  );

  final result = await db.rawQuery(
    '''
    SELECT
      COALESCE(SUM(calories), 0) AS total_calories,
      COALESCE(SUM(protein_grams), 0) AS total_protein
    FROM nutrition_records
    WHERE eaten_at >= ? AND eaten_at < ?
    ''',
    [
      startOfDay.toIso8601String(),
      endOfDay.toIso8601String(),
    ],
  );

  final row = result.first;

  return {
    'calories': (row['total_calories'] as num).toDouble(),
    'protein': (row['total_protein'] as num).toDouble(),
  };
}
static Future<int> deleteNutritionRecord(int id) async {
  if (id <= 0) {
    throw ArgumentError('올바른 음식 기록 ID가 필요합니다.');
  }

  final db = await database;

  return db.delete(
    'nutrition_records',
    where: 'id = ?',
    whereArgs: [id],
  );
}
static Future<int> updateNutritionRecord({
  required int id,
  required String foodName,
  required String mealType,
  required double amountGrams,
  required double calories,
  required double proteinGrams,
}) async {
  if (id <= 0 ||
      foodName.trim().isEmpty ||
      amountGrams <= 0 ||
      !amountGrams.isFinite ||
      calories < 0 ||
      !calories.isFinite ||
      proteinGrams < 0 ||
      !proteinGrams.isFinite) {
    throw ArgumentError('올바른 음식 기록 정보가 필요합니다.');
  }

  final db = await database;

  return db.update(
    'nutrition_records',
    {
      'food_name': foodName.trim(),
      'meal_type': mealType,
      'amount_grams': amountGrams,
      'calories': calories,
      'protein_grams': proteinGrams,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}
}