/// UserModel speichert relevante Nutzerdaten wie Klasse, Level, gewählte Fächer und userId für das Backend.

class UserModel {
  final String userId; // NEU: userId für Backend
  final String selectedClass;
  final String selectedLevel;
  final List<String> selectedSubjects;

  const UserModel({
    this.userId = "demo_user", // Default-Wert gesetzt
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
}
