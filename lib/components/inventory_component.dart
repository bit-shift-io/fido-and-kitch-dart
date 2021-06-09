import 'package:fido_and_kitch/components/mixins.dart';
import 'package:flame/components.dart';

class InventoryComponent extends Component with HasName {
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

Future<InventoryComponent> inventoryComponentFromData(dynamic yaml) async {
  final comp = new InventoryComponent();
  await comp.fromData(yaml);
  return comp;
}