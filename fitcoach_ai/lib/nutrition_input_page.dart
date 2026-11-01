import 'package:flutter/material.dart';
import 'workout_database.dart';

class NutritionInputPage extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, dynamic>? existingRecord;

  const NutritionInputPage({
    super.key,
    required this.selectedDate,
    this.existingRecord,
  });

  @override
  State<NutritionInputPage> createState() =>
      _NutritionInputPageState();
}

class _NutritionInputPageState
    extends State<NutritionInputPage> {
  final foodNameController = TextEditingController();
  final amountController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();

  String selectedMealType = '아침';
  @override
void initState() {
  super.initState();

  final record = widget.existingRecord;

  if (record != null) {
    foodNameController.text =
        record['food_name'] as String;

    selectedMealType =
        record['meal_type'] as String;

    amountController.text =
        (record['amount_grams'] as num).toString();

    caloriesController.text =
        (record['calories'] as num).toString();

    proteinController.text =
        (record['protein_grams'] as num).toString();
  }
}

  @override
  void dispose() {
    foodNameController.dispose();
    amountController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    super.dispose();
  }

  Future<void> saveNutritionRecord() async {
  final foodName = foodNameController.text.trim();
  final amount = double.tryParse(amountController.text.trim());
  final calories = double.tryParse(caloriesController.text.trim());
  final protein = double.tryParse(proteinController.text.trim());

  if (foodName.isEmpty ||
      amount == null ||
      amount <= 0 ||
      !amount.isFinite ||
      calories == null ||
      calories < 0 ||
      !calories.isFinite ||
      protein == null ||
      protein < 0 ||
      !protein.isFinite) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('음식 이름과 올바른 영양 정보를 입력해 주세요.'),
      ),
    );
    return;
  }

  try {
  final existingRecord = widget.existingRecord;

  if (existingRecord == null) {
    final now = DateTime.now();

    await WorkoutDatabase.insertNutritionRecord(
      foodName: foodName,
      mealType: selectedMealType,
      amountGrams: amount,
      calories: calories,
      proteinGrams: protein,
      eatenAt: DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        now.hour,
        now.minute,
      ),
    );
  } else {
    final updatedCount =
        await WorkoutDatabase.updateNutritionRecord(
      id: existingRecord['id'] as int,
      foodName: foodName,
      mealType: selectedMealType,
      amountGrams: amount,
      calories: calories,
      proteinGrams: protein,
    );

    if (updatedCount == 0) {
      throw StateError('수정할 음식 기록을 찾을 수 없습니다.');
    }
  }

  if (!mounted) return;
  Navigator.pop(context, true);
} catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('음식 기록 저장 실패: $e'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음식 기록 추가'),
      ),
      body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      TextField(
        controller: foodNameController,
        decoration: const InputDecoration(
          labelText: '음식 이름',
          hintText: '예: 닭가슴살',
          prefixIcon: Icon(Icons.restaurant),
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),

DropdownButtonFormField<String>(
  initialValue: selectedMealType,
  decoration: const InputDecoration(
    labelText: '식사 구분',
    prefixIcon: Icon(Icons.access_time),
    border: OutlineInputBorder(),
  ),
  items: const [
    DropdownMenuItem(
      value: '아침',
      child: Text('아침'),
    ),
    DropdownMenuItem(
      value: '점심',
      child: Text('점심'),
    ),
    DropdownMenuItem(
      value: '저녁',
      child: Text('저녁'),
    ),
    DropdownMenuItem(
      value: '간식',
      child: Text('간식'),
    ),
  ],
  onChanged: (value) {
    if (value == null) return;

    setState(() {
      selectedMealType = value;
    });
  },
),
const SizedBox(height: 16),

TextField(
  controller: amountController,
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
  ),
  decoration: const InputDecoration(
    labelText: '섭취량 (g)',
    hintText: '예: 150',
    prefixIcon: Icon(Icons.scale),
    suffixText: 'g',
    border: OutlineInputBorder(),
  ),
  textInputAction: TextInputAction.next,
),
const SizedBox(height: 16),

TextField(
  controller: caloriesController,
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
  ),
  decoration: const InputDecoration(
    labelText: '칼로리 (kcal)',
    hintText: '예: 165',
    prefixIcon: Icon(Icons.local_fire_department),
    suffixText: 'kcal',
    border: OutlineInputBorder(),
  ),
  textInputAction: TextInputAction.next,
),
const SizedBox(height: 16),

TextField(
  controller: proteinController,
  keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
  ),
  decoration: const InputDecoration(
    labelText: '단백질 (g)',
    hintText: '예: 34.5',
    prefixIcon: Icon(Icons.fitness_center),
    suffixText: 'g',
    border: OutlineInputBorder(),
  ),
  textInputAction: TextInputAction.done,
),
const SizedBox(height: 24),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: saveNutritionRecord,
    icon: const Icon(Icons.save),
    label: const Text('음식 기록 저장'),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
),
          ],
    ),
  ),
),
    );
  }
}