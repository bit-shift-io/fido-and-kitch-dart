import 'mixins.dart';
import 'package:flame/components.dart';

class Pickup extends PositionComponent with HasName {
  String itemName = '';
  int itemCount = 1;

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    itemName = yaml['itemName'];
    itemCount = yaml['itemCount'] ?? 1;
  }
}

Future<Pickup> pickupComponentFromData(dynamic yaml) async {
  final comp = new Pickup();
  await comp.fromData(yaml);
  return comp;
}