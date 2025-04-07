import 'package:sqflite/sqflite.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../data/database/habit_database.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitDatabase _db = HabitDatabase.instance;

  @override
  Future<List<Habit>> getHabits() async {
    final db = await _db.database;
    final habitResult = await db.query('habits');
    final List<Habit> habits = [];

    for (var habitJson in habitResult) {
      final completionsResult = await db.query(
        'completions',
        where: 'habit_id = ?',
        whereArgs: [habitJson['id']],
      );
      final completions = Map<DateTime, bool>.fromEntries(
        completionsResult.map((c) => MapEntry(
          DateTime.parse(c['date'] as String),
          (c['completed'] as int) == 1,
        )),
      );
      habits.add(Habit(
        id: habitJson['id'] as int,
        name: habitJson['name'] as String,
        completions: completions,
      ));
    }
    return habits;
  }

  @override
  Future<void> addHabit(Habit habit) async {
    final db = await _db.database;
    final id = await db.insert('habits', {'name': habit.name});
    for (var entry in habit.completions.entries) {
      await db.insert('completions', {
        'habit_id': id,
        'date': entry.key.toIso8601String(),
        'completed': entry.value ? 1 : 0,
      });
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final db = await _db.database;
    await db.update(
      'habits',
      {'name': habit.name},
      where: 'id = ?',
      whereArgs: [habit.id],
    );
    await db.delete('completions', where: 'habit_id = ?', whereArgs: [habit.id]);
    for (var entry in habit.completions.entries) {
      await db.insert('completions', {
        'habit_id': habit.id,
        'date': entry.key.toIso8601String(),
        'completed': entry.value ? 1 : 0,
      });
    }
  }

  @override
  Future<void> deleteHabit(int id) async {
    final db = await _db.database;
    await db.delete('completions', where: 'habit_id = ?', whereArgs: [id]);
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}