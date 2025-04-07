import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final int? id;
  final String name;
  final Map<DateTime, bool> completions; // Date -> completed status

  const Habit({
    this.id,
    required this.name,
    this.completions = const {},
  });

  Habit copyWith({
    int? id,
    String? name,
    Map<DateTime, bool>? completions,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      completions: completions ?? this.completions,
    );
  }

  @override
  List<Object?> get props => [id, name, completions];
}