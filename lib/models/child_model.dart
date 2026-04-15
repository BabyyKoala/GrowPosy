class GrowthData {
  final double weight;
  final double height;

  GrowthData({required this.weight, required this.height});

  factory GrowthData.fromMap(Map<String, dynamic> map) {
    return GrowthData(
      weight: (map['weight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'weight': weight, 'height': height};
  }
}

class ChildModel {
  final String id;
  final String name;
  final int age;
  final String gender;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
  });

  factory ChildModel.fromMap(String id, Map<String, dynamic> data) {
    return ChildModel(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
    );
  }
}
