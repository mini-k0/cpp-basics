import 'workout_database.dart';
import 'package:flutter/material.dart';

class WorkoutSetInputPage extends StatefulWidget {
  const WorkoutSetInputPage({super.key});

  @override
  State<WorkoutSetInputPage> createState() =>
      _WorkoutSetInputPageState();
}

class _WorkoutSetInputPageState extends State<WorkoutSetInputPage> {
  final nameController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  final List<_SetInput> workoutSets = [
    _SetInput(),
  ];

int get totalReps {
  int total = 0;

  for (final set in workoutSets) {
    final reps = int.tryParse(set.repsController.text) ?? 0;

    if (reps > 0) {
      total += reps;
    }
  }

  return total;
}

void updateTotalReps() {
  setState(() {});
}

Future<void> selectWorkoutDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    helpText: '운동 날짜 선택',
    cancelText: '취소',
    confirmText: '확인',
  );

  if (pickedDate == null || !mounted) return;

  setState(() {
    selectedDate = pickedDate;
  });
}

  List<Map<String, dynamic>>? validateWorkoutSets() {
  final name = nameController.text.trim();

  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('운동 이름을 입력해 주세요.'),
      ),
    );
    return null;
  }

  final validatedSets = <Map<String, dynamic>>[];

  for (int i = 0; i < workoutSets.length; i++) {
    final set = workoutSets[i];

    final weight =
        double.tryParse(set.weightController.text.trim());

    final reps =
        int.tryParse(set.repsController.text.trim());

    if (weight == null ||
        !weight.isFinite ||
        weight < 0 ||
        reps == null ||
        reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${i + 1}세트의 중량과 반복 횟수를 확인해 주세요.',
          ),
        ),
      );
      return null;
    }

    validatedSets.add({
      'weight': weight,
      'reps': reps,
    });
  }

  return validatedSets;
}
  
bool isSaving = false;

Future<void> saveWorkoutWithSets() async {
  if (isSaving) return;

  final validatedSets = validateWorkoutSets();

  if (validatedSets == null) return;

  setState(() {
    isSaving = true;
  });

  try {
    await WorkoutDatabase.insertWorkoutWithSets(
      name: nameController.text.trim(),
      workoutDate: selectedDate,
      workoutSets: validatedSets,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('세트별 운동 기록이 저장되었습니다.'),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('운동 기록 저장 실패: $e'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
}

  void addSet() {
    setState(() {
      workoutSets.add(_SetInput());
    });
  }

  void removeSet(int index) {
    if (workoutSets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1개의 세트가 필요합니다.'),
        ),
      );
      return;
    }

    setState(() {
      final removed = workoutSets.removeAt(index);
      removed.dispose();
    });
  }

  @override
  void dispose() {
    nameController.dispose();

    for (final set in workoutSets) {
      set.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('세트별 운동 기록'),
        backgroundColor: Colors.teal.shade100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '운동 이름 (예: 풀업)',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 12),

OutlinedButton.icon(
  onPressed: selectWorkoutDate,
  icon: const Icon(Icons.calendar_month),
  label: Text(
    '${selectedDate.year}년 '
    '${selectedDate.month}월 '
    '${selectedDate.day}일',
  ),
),

          const SizedBox(height: 24),
          Text(
            '세트별 운동 입력',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          for (int i = 0; i < workoutSets.length; i++)
            Card(
              key: ObjectKey(workoutSets[i]),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${i + 1}세트',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => removeSet(i),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: '세트 삭제',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: workoutSets[i].weightController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: '추가 중량 (kg)',
                              hintText: '0',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: workoutSets[i].repsController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => updateTotalReps(),
                            decoration: const InputDecoration(
                              labelText: '반복 횟수',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: addSet,
            icon: const Icon(Icons.add),
            label: const Text('세트 추가'),
          ),

          const SizedBox(height: 20),

          Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      '현재 총 ${workoutSets.length}세트',
      style: Theme.of(context).textTheme.titleMedium,
    ),
    const SizedBox(height: 8),
    Text(
      '총 반복 횟수: $totalReps회',
      style: Theme.of(context).textTheme.titleMedium,
    ),
  ],
),
const SizedBox(height: 24),

FilledButton.icon(
  onPressed: isSaving ? null : saveWorkoutWithSets,
  icon: const Icon(Icons.save),
  label: Text(
    isSaving ? '저장 중...' : '운동 기록 저장',
  ),
),
        ],
      ),
    );
  }
}

class _SetInput {
  final weightController = TextEditingController(text: '0');
  final repsController = TextEditingController();

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}