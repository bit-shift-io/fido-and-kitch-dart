import 'mixins.dart';
import 'package:flame/components.dart';


// TODO: Pickup should be combined with Area component
// currently coin and key need 2 componenets to function correctly
// as a pickup, but should only need 1 component with a default script
// to give it to the player on contact
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