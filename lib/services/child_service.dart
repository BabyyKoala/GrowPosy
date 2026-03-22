import '../models/child_model.dart';

class ChildService {
  static final List<ChildModel> _children = [];

  static List<ChildModel> getChildren() {
    return _children;
  }

  static void addChild(ChildModel child) {
    _children.add(child);
  }
}
