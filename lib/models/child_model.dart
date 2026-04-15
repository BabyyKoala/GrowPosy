class ChildModel {
  final String id;
  final String name;
  final int age;
  final String gender; // 'L' atau 'P'

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
  });

  factory ChildModel.fromMap(String id, Map<String, dynamic> data) {
    return ChildModel(
      id: id,
      name: data['name'] ?? 'Tanpa Nama',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? 'L',
    );
  }
}