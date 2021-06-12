import 'package:flame/components.dart';

import '../factory.dart';
import 'mixins.dart';
import 'extensions.dart';

class Usable extends PositionComponent {
  String requiredItem;
  int requiredItemCount;
  String playerAnimationOnUse;

  Future<void> fromData(dynamic yaml) async {
    addChildren(await Factory().createFromDataArray(yaml['children']));
    requiredItem = yaml['requiredItem'];
    requiredItemCount = yaml['requiredItemCount'] ?? 1;
    playerAnimationOnUse = yaml['playerAnimationOnUse'];
  }
}

Future<Usable> usableComponentFromData(dynamic yaml) async {
  final comp = new Usable();
  await comp.fromData(yaml);
  return comp;
}