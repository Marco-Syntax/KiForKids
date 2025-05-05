import 'dart:math';

class UserModel {
  final String userId;
  final String selectedClass;
  final String selectedLevel;
  final List<String> selectedSubjects;

  const UserModel({
    required this.userId,
    required this.selectedClass,
    required this.selectedLevel,
    this.selectedSubjects = const [],
  });

  UserModel copyWith({String? userId, String? selectedClass, String? selectedLevel, List<String>? selectedSubjects}) {
    return UserModel(
      userId: userId ?? this.userId,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
    );
  }

  factory UserModel.generate({
    required String selectedClass,
    required String selectedLevel,
    List<String> selectedSubjects = const [],
  }) {
    final random = Random();
    final randomId = List.generate(12, (_) => random.nextInt(10)).join();
    return UserModel(
      userId: "user_$randomId",
      selectedClass: selectedClass,
      selectedLevel: selectedLevel,
      selectedSubjects: selectedSubjects,
    );
  }
}
