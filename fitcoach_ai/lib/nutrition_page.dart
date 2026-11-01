import 'nutrition_input_page.dart';
import 'workout_database.dart';
import 'package:flutter/material.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  List<Map<String, dynamic>> nutritionRecords = [];
bool isLoading = true;
double todayCalories = 0;
double todayProtein = 0;
DateTime selectedDate = DateTime.now();
  Future<void> checkNutritionTable() async {
  try {
    final tables = await WorkoutDatabase.getTableNames();

    debugPrint('SQLite 테이블 목록: $tables');

    if (tables.contains('nutrition_records')) {
      debugPrint('영양 기록 테이블 생성 성공!');
    } else {
      debugPrint('영양 기록 테이블을 찾을 수 없습니다.');
    }
  } catch (e) {
    debugPrint('SQLite 테이블 확인 오류: $e');
  }
}

Future<void> loadNutritionRecords() async {
  try {
    final records =
    await WorkoutDatabase.getNutritionRecordsByDate(selectedDate);

    if (!mounted) return;

    setState(() {
      nutritionRecords = records;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('음식 기록을 불러오지 못했습니다: $e'),
      ),
    );
  }
}

Future<void> loadTodayNutritionTotals() async {
  try {
    final totals =
        await WorkoutDatabase.getNutritionTotalsByDate(selectedDate);

    if (!mounted) return;

    setState(() {
      todayCalories = totals['calories'] ?? 0;
      todayProtein = totals['protein'] ?? 0;
    });
  } catch (e) {
    debugPrint('선택한 날짜의 영양 합계 불러오기 오류: $e');
  }
}

Future<void> selectNutritionDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (pickedDate == null || !mounted) return;

  setState(() {
  selectedDate = pickedDate;
  isLoading = true;
});

await loadNutritionRecords();
if (!mounted) return;
await loadTodayNutritionTotals();
}

@override
void initState() {
  super.initState();
  checkNutritionTable();
  loadNutritionRecords();
  loadTodayNutritionTotals();
}

Future<void> confirmDeleteNutritionRecord(int id) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('음식 기록 삭제'),
      content: const Text(
        '이 음식 기록을 삭제하시겠습니까?\n'
        '삭제한 기록은 복구할 수 없습니다.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, false);
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, true);
          },
          child: const Text('삭제'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  try {
    final deletedCount =
        await WorkoutDatabase.deleteNutritionRecord(id);

    if (!mounted) return;

    if (deletedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('삭제할 음식 기록을 찾을 수 없습니다.'),
        ),
      );
      return;
    }

    await loadNutritionRecords();

    if (!mounted) return;

    await loadTodayNutritionTotals();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('음식 기록이 삭제되었습니다.'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('음식 기록 삭제 실패: $e'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영양 관리'),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NutritionInputPage(
  selectedDate: selectedDate,
),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
  await loadNutritionRecords();
  if (!mounted) return;
  await loadTodayNutritionTotals();
}
  },
  tooltip: '음식 기록 추가',
  child: const Icon(Icons.add),
),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : Column(
        children: [
          Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
  child: OutlinedButton.icon(
    onPressed: selectNutritionDate,
    icon: const Icon(Icons.calendar_month),
    label: Text(
      '${selectedDate.year}년 '
      '${selectedDate.month}월 '
      '${selectedDate.day}일',
    ),
  ),
),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('선택 날짜 총칼로리'),
                          const SizedBox(height: 8),
                          Text(
                            '${todayCalories.toStringAsFixed(0)} kcal',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('선택 날짜 총단백질'),
                          const SizedBox(height: 8),
                          Text(
                            '${todayProtein.toStringAsFixed(1)} g',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: nutritionRecords.isEmpty
                ? const Center(
                    child: Text('아직 등록된 음식 기록이 없습니다.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: nutritionRecords.length,
                    itemBuilder: (context, index) {
                      final record = nutritionRecords[index];
                      final foodName = record['food_name'] as String;
                      final mealType = record['meal_type'] as String;
                      final amount =
                          (record['amount_grams'] as num).toDouble();
                      final calories =
                          (record['calories'] as num).toDouble();
                      final protein =
                          (record['protein_grams'] as num).toDouble();

                      return Card(
  child: ListTile(
    leading: const Icon(Icons.restaurant),
    title: Text(foodName),
    subtitle: Text(
      '$mealType · ${amount.toStringAsFixed(0)}g\n'
      '${calories.toStringAsFixed(0)}kcal · '
      '단백질 ${protein.toStringAsFixed(1)}g',
    ),
    isThreeLine: true,
    onTap: () async {
  final updated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => NutritionInputPage(
        selectedDate: selectedDate,
        existingRecord: record,
      ),
    ),
  );

  if (!mounted) return;

  if (updated == true) {
    await loadNutritionRecords();

    if (!mounted) return;

    await loadTodayNutritionTotals();
  }
},
    trailing: IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: '음식 기록 삭제',
      onPressed: () {
        final id = record['id'] as int;
        confirmDeleteNutritionRecord(id);
      },
    ),
  ),
);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}