

import 'package:fido_and_kitch/components/entity.dart';
import 'package:fido_and_kitch/components/inventory.dart';
import 'package:fido_and_kitch/components/pickup.dart';
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

          Inventory playerInventory = player.findFirstChildByClass<Inventory>();
          if (playerInventory != null) {
            List<Pickup> pickupComponents = pickup.findChildrenByClass<Pickup>();
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