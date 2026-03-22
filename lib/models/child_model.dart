class GrowthData {
  final double weight;
  final double height;

  GrowthData({required this.weight, required this.height});
}

class ChildModel {
  final String name;
  final int age;
  final List<GrowthData> growth;

  ChildModel({required this.name, required this.age, required this.growth});
}
