import 'package:flame/components.dart';

import '../factory.dart';
import 'mixins.dart';
import 'extensions.dart';

class UsableComponent extends PositionComponent {
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

Future<UsableComponent> usableComponentFromData(dynamic yaml) async {
  final comp = new UsableComponent();
  await comp.fromData(yaml);
  return comp;
}