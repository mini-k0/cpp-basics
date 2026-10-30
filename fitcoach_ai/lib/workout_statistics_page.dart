import 'package:flutter/material.dart';

import 'workout_database.dart';
import 'workout_statistics.dart';

class WorkoutStatisticsPage extends StatefulWidget {
  const WorkoutStatisticsPage({super.key});

  @override
  State<WorkoutStatisticsPage> createState() =>
      _WorkoutStatisticsPageState();
}

class _WorkoutStatisticsPageState
    extends State<WorkoutStatisticsPage> {
  bool isWeekly = true;
  late Future<WorkoutStatistics> statisticsFuture;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  void loadStatistics() {
    final now = DateTime.now();

    final start = isWeekly
        ? DateTime(
            now.year,
            now.month,
            now.day - (now.weekday - 1),
          )
        : DateTime(now.year, now.month, 1);

    final end = isWeekly
        ? DateTime(start.year, start.month, start.day + 6)
        : DateTime(now.year, now.month + 1, 0);

    statisticsFuture = _calculateStatistics(start, end);
  }

  Future<WorkoutStatistics> _calculateStatistics(
  DateTime start,
  DateTime end,
) async {
  // 기존 운동 기록 불러오기
  final workouts = await WorkoutDatabase.getWorkouts();

  // 세트별 기록이 있는 운동 ID 불러오기
  final workoutIdsWithSets =
      await WorkoutDatabase.getWorkoutIdsWithSets();

  // 기존 기록과 새로운 세트별 기록을 구분하여 통계 계산
  return WorkoutStatistics.calculate(
    workouts,
    start,
    end,
    workoutIdsWithSets: workoutIdsWithSets,
  );
}

  void changePeriod(bool weekly) {
    setState(() {
      isWeekly = weekly;
      loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 통계'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('이번 주'),
              ),
              ButtonSegment(
                value: false,
                label: Text('이번 달'),
              ),
            ],
            selected: {isWeekly},
            onSelectionChanged: (selection) {
              changePeriod(selection.first);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<WorkoutStatistics>(
              future: statisticsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState !=
                    ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('통계를 불러오지 못했습니다: ${snapshot.error}'),
                  );
                }

                final stats = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '전체 운동 통계',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('운동한 날짜'),
                            trailing: Text('${stats.workoutDays}일'),
                          ),
                          ListTile(
                            title: const Text('총 세트 수'),
                            trailing: Text('${stats.totalSets}세트'),
                          ),
                          ListTile(
                            title: const Text('총 반복 횟수'),
                            trailing: Text('${stats.totalReps}회'),
                          ),
                          ListTile(
                            title: const Text('운동 종목 수'),
                            trailing: Text('${stats.exerciseTypes}종목'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '종목별 운동 통계',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (stats.exercises.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            '선택한 기간에 운동 기록이 없습니다.',
                          ),
                        ),
                      ),
                    ...stats.exercises.map(
                      (exercise) => Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(exercise.name),
                              subtitle: Text(
                                '운동한 날짜: ${exercise.workoutDays}일',
                              ),
                            ),
                            ListTile(
                              title: const Text('총 세트'),
                              trailing:
                                  Text('${exercise.totalSets}세트'),
                            ),
                            ListTile(
                              title: const Text('총 반복'),
                              trailing:
                                  Text('${exercise.totalReps}회'),
                            ),
                            ListTile(
                              title: const Text('최고 추가 중량'),
                              trailing:
                                  Text('${exercise.maxWeight}kg'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}