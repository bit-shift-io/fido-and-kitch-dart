import 'package:fido_and_kitch/components/mixins.dart';
import 'package:flame/components.dart';
import '../utils/script.dart';

@HTBinding()
class Inventory extends Component with HasName {
  Map<String, int> items = Map();

  void addItem(String name, {int count = 1}) {
    items[name] = (items[name] ?? 0) + count;
  }

  bool hasItem(String name, {int count = 1}) {
    return items[name] != null && items[name] >= count;
  }

  void removeItem(String name, {int count = 1}) {
    items[name] = (items[name] ?? 0) - count;
  }

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
  }
}

Future<Inventory> inventoryComponentFromData(dynamic yaml) async {
  final comp = new Inventory();
  await comp.fromData(yaml);
  return comp;
}