

import 'package:fido_and_kitch/components/entity.dart';
import 'package:fido_and_kitch/components/inventory_component.dart';
import 'package:fido_and_kitch/components/pickup_component.dart';
import 'package:flame/components.dart';

import '../components/extensions.dart';
import '../components/system.dart';
import '../game.dart';

class PickupSystem extends System with HasGameRef<MyGame> {
  @override
  void update(double delta) {
    // TODO: for each player, see if they intersect any pickups
    final players = gameRef.players;
    final pickups = gameRef.getEntities<Entity>('Pickups');

    for (final player in players) {
      final playerRect = player.toRect();
      for (final pickup in pickups) {
        final pickupRect = pickup.toRect();
        if (playerRect.overlaps(pickupRect)) {
          gameRef.remove(pickup);
          pickup.removeFromEntityLists(gameRef);

          InventoryComponent playerInventory = player.findFirstChildByClass<InventoryComponent>();
          if (playerInventory != null) {
            List<PickupComponent> pickupComponents = pickup.findChildrenByClass<PickupComponent>();
            for (final pc in pickupComponents) {
              print('Player picked up ${pc.itemName}');
              playerInventory.addItem(pc.itemName, count: pc.itemCount);
            }
          }
        }
      }
    }
  }
}