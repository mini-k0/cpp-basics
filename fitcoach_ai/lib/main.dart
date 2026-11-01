import 'workout_set_input_page.dart';
import 'package:flutter/material.dart';
import 'workout_statistics_page.dart';
import 'workout_growth_page.dart';
import 'workout_database.dart';

void main() {
  runApp(const FitCoachApp());
}

class FitCoachApp extends StatelessWidget {
  const FitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitCoach AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitCoach AI'),
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘도 성장하는 하루!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '운동과 영양을 기록하고 목표를 달성하세요.',
            ),
            const SizedBox(height: 30),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('운동 기록'),
                subtitle: const Text('오늘의 운동을 기록하세요'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutPage(),
                    ),
                  );
                },
              ),
            ),
            Card(
  child: ListTile(
    leading: const Icon(Icons.bar_chart),
    title: const Text('운동 통계'),
    subtitle: const Text('주간·월간 종목별 운동 분석'),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WorkoutStatisticsPage(),
        ),
      );
    },
  ),
),
            Card(
  child: ListTile(
    leading: const Icon(Icons.show_chart),
    title: const Text('운동 성장 그래프'),
    subtitle: const Text('최근 8주간 종목별 운동량 변화'),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WorkoutGrowthPage(),
        ),
      );
    },
  ),
),
            const Card(
              child: ListTile(
                leading: Icon(Icons.restaurant),
                title: Text('영양 관리'),
                subtitle: Text('칼로리와 단백질을 관리하세요'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.smart_toy),
                title: Text('AI 코치'),
                subtitle: Text('AI에게 운동 조언을 받아보세요'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final setsController = TextEditingController();

  Set<int> workoutIdsWithSets = {};

  List<Map<String, dynamic>> workouts = [];
  DateTime selectedDate = DateTime.now();

@override
void initState() {
  super.initState();
  loadWorkouts();
}
List<Map<String, dynamic>> get filteredWorkouts {
  final dateString =
      '${selectedDate.year.toString().padLeft(4, '0')}-'
      '${selectedDate.month.toString().padLeft(2, '0')}-'
      '${selectedDate.day.toString().padLeft(2, '0')}';

  return workouts.where((workout) {
    final createdAt = workout['created_at'].toString();
    return createdAt.startsWith(dateString);
  }).toList();
}

Future<void> selectWorkoutDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    helpText: '운동 기록 날짜 선택',
    cancelText: '취소',
    confirmText: '확인',
  );

  if (pickedDate == null || !mounted) return;

  setState(() {
    selectedDate = pickedDate;
  });
}

Future<void> loadWorkouts() async {
  try {
    final data = await WorkoutDatabase.getWorkouts();
    final idsWithSets =
    await WorkoutDatabase.getWorkoutIdsWithSets();

    if (!mounted) return;

    setState(() {
      workouts = data;
      workoutIdsWithSets = idsWithSets;
    });
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('운동 기록을 불러오지 못했습니다: $e')),
    );
  }
}

  Future<void> saveWorkout() async {
  final name = nameController.text.trim();
  final weight = double.tryParse(weightController.text);
  final reps = int.tryParse(repsController.text);
  final sets = int.tryParse(setsController.text);

  if (name.isEmpty ||
      weight == null ||
      !weight.isFinite ||
      weight < 0 ||
      reps == null ||
      reps <= 0 ||
      sets == null ||
      sets <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('운동 정보를 올바르게 입력해 주세요.'),
      ),
    );
    return;
  }

  try {
    await WorkoutDatabase.insertWorkout(
  name: name,
  weight: weight,
  reps: reps,
  sets: sets,
  workoutDate: selectedDate,
);

    await loadWorkouts();

    if (!mounted) return;

    nameController.clear();
    weightController.clear();
    repsController.clear();
    setsController.clear();

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('운동 기록이 저장되었습니다.')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('저장에 실패했습니다: $e')),
    );
  }
}
Future<void> editWorkout(Map<String, dynamic> workout) async {
  final nameEdit = TextEditingController(
    text: workout['name'].toString(),
  );
  final weightEdit = TextEditingController(
    text: workout['weight'].toString(),
  );
  final repsEdit = TextEditingController(
    text: workout['reps'].toString(),
  );
  final setsEdit = TextEditingController(
    text: workout['sets'].toString(),
  );

  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('운동 기록 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameEdit,
                  decoration: const InputDecoration(
                    labelText: '운동 이름',
                  ),
                ),
                TextField(
                  controller: weightEdit,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: '추가 무게 (kg)',
                  ),
                ),
                TextField(
                  controller: repsEdit,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '반복 횟수',
                  ),
                ),
                TextField(
                  controller: setsEdit,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '세트 수',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameEdit.text.trim();
                final weight = double.tryParse(weightEdit.text);
                final reps = int.tryParse(repsEdit.text);
                final sets = int.tryParse(setsEdit.text);

                if (name.isEmpty ||
                    weight == null ||
                    !weight.isFinite ||
                    weight < 0 ||
                    reps == null ||
                    reps <= 0 ||
                    sets == null ||
                    sets <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('올바른 운동 정보를 입력해 주세요.'),
                    ),
                  );
                  return;
                }

                try {
                  await WorkoutDatabase.updateWorkout(
                    id: workout['id'] as int,
                    name: name,
                    weight: weight,
                    reps: reps,
                    sets: sets,
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);

                  await loadWorkouts();
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('수정 실패: $e')),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  } finally {
    // 대화상자가 닫히는 애니메이션 중 컨트롤러가
    // 참조될 수 있으므로 다음 단계에서 수명 관리를 개선할 예정.
  }
}
  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    repsController.dispose();
    setsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록'),
        backgroundColor: Colors.teal.shade100,
      ),
      
      floatingActionButton: FloatingActionButton.extended(
  onPressed: openWorkoutSetInputPage,
  icon: const Icon(Icons.add),
  label: const Text('세트별 기록'),
),
      
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '오늘의 운동 입력',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '운동 이름 (예: 풀업)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: '추가 무게 (kg, 맨몸이면 0)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '반복 횟수',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: setsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '세트 수',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: saveWorkout,
            child: const Text('운동 저장'),
          ),
          const SizedBox(height: 30),
          const Text(
  '운동 기록 목록',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
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

const SizedBox(height: 12),
          const SizedBox(height: 12),
          if (filteredWorkouts.isEmpty)
            const Text('아직 기록한 운동이 없습니다.'),
          for (final workout in filteredWorkouts)
  Card(
    child: ListTile(
      leading: const Icon(Icons.check_circle),
      title: Text('${workout['name']}'),
      subtitle: Text(
        workoutIdsWithSets.contains((workout['id'] as num).toInt())
    ? '${workout['weight']}kg (최대) | '
        '총 ${workout['reps']}회 · ${workout['sets']}세트\n'
        '${workout['created_at'].toString().split('T').first}'
    : '${workout['weight']}kg | '
        '${workout['reps']}회 × ${workout['sets']}세트\n'
        '${workout['created_at'].toString().split('T').first}',
      ),
      isThreeLine: true,
      trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
  icon: const Icon(Icons.edit_outlined),
  tooltip: '기록 수정',
  onPressed: () async {
    final workoutId = (workout['id'] as num).toInt();

    if (workoutIdsWithSets.contains(workoutId)) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSetInputPage(
            workoutId: workoutId,
          ),
        ),
      );

      if (result == true) {
        await loadWorkouts();
      }
    } else {
      editWorkout(workout);
    }
  },
),
    IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: '기록 삭제',
      onPressed: () async {
        try {
          await WorkoutDatabase.deleteWorkout(
            workout['id'] as int,
          );
          await loadWorkouts();
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제에 실패했습니다: $e')),
          );
        }
      },
    ),
  ],
),
    ),
  ),
        ],
      ),
    );
  }
  Future<void> openWorkoutSetInputPage() async {
  final saved = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => const WorkoutSetInputPage(),
    ),
  );

  if (!mounted) return;

  if (saved == true) {
    await loadWorkouts();
  }
}
}