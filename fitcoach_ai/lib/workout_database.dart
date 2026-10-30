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
      version: 2,
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
}