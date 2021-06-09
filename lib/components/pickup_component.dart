import 'package:fido_and_kitch/components/mixins.dart';
import 'package:flame/components.dart';

class PickupComponent extends PositionComponent with HasName {
  String itemName;
  int itemCount;

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    itemName = yaml['itemName'];
    itemCount = yaml['itemCount'] ?? 1;
  }
}

Future<PickupComponent> pickupComponentFromData(dynamic yaml) async {
  final comp = new PickupComponent();
  await comp.fromData(yaml);
  return comp;
}