import 'package:uuid/uuid.dart';

class UserModel {
  final String id;
  final String selectedClass;
  final String selectedLevel;
  final List<String> selectedSubjects;

  UserModel({String? id, required this.selectedClass, required this.selectedLevel, this.selectedSubjects = const []})
    : id = id ?? const Uuid().v4();

  UserModel copyWith({String? id, String? selectedClass, String? selectedLevel, List<String>? selectedSubjects}) {
    return UserModel(
      id: id ?? this.id,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
    );
  }
}
