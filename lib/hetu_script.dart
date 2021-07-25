import 'package:fido_and_kitch/components/entity.dart';
import 'package:fido_and_kitch/components/pickup.dart';
import 'package:flame/components.dart';
import 'package:hetu_script/hetu_script.dart';

import 'components/area.dart';
import 'components/inventory.dart';
import 'components/mixins.dart';
import 'components/extensions.dart';
import 'components/script.dart';
import 'components/switch.dart';
import 'components/tiled_object.dart';
import 'game.dart';

class HetuScript {

  static final HetuScript _singleton = HetuScript._internal();

  factory HetuScript() {
    return _singleton;
  }

  HetuScript._internal();

  Map<String, Function> externalFunctions = {
      'playerExit': (Entity? player) {
        print('PLAYER EXITED');
      },
      'findFirstChild': (Component? c, String name) {
        if (c == null) {
          return null;
        }

        if (c is BaseComponent) {
          BaseComponent b = c;
          return b.findFirstChild<Component>(name);
        }
        return null;
      },
      'setActiveComponent': (Switch s, String name) {
        s.setActiveComponent(name);
      },
      'getActiveComponent': (Switch? s) {
        if (s == null) {
          return null;
        }
        return s.activeComponent;
      },
      'getName': (Component c) {
        if (c is HasName) {
          HasName n = c as HasName;
          return n.name;
        }

        return null;
      },
      'findObjectById': (Game game, int id) {
        return game.map!.findObjectById(id);
      },
      // find entity that is using the TiledObject with id
      'findEntityByObjectId': (Game game, int id) {
        List<Entity> entities = game.getEntities('Entity');
        for (final entity in entities) {
          TiledObject? tiledObject = entity.findFirstChildByClass<TiledObject>();
          if (tiledObject != null && tiledObject.object != null) {
            if (tiledObject.object!.id == id) {
              return entity;
            }
          }
        }

        return null;
      },
      'evalScript': (Script? s, dynamic props) {
        if (s == null) {
          return null;
        }

        return s.eval(props);
      },
      'reset': (SpriteAnimation? s) {
        if (s != null) {
          s.reset();
        }
      },
      'removeEntity': (Entity? e) {
        if (e == null) {
          return;
        }

        final gameRef = e.gameRef;
        gameRef.remove(e);
        e.removeFromEntityLists(gameRef);
      },
      'givePickupToPlayer': (Pickup? pickup, Entity? player) {
        if (pickup == null || player == null) {
          return false;
        }

        Inventory? playerInventory = player.findFirstChildByClass<Inventory>();
        if (playerInventory != null) {
          print('Player picked up ${pickup.itemName}');
          playerInventory.addItem(pickup.itemName, count: pickup.itemCount);
        }

        return true;
      },
      'setEnabled': (Component? c, bool enabled) {
        if (c is Area) {
          c.enabled = enabled;
        }
      }
  };
/*
  String scriptPrefix;

  // call after all things have been registered
  Future<void> init() async {
    // TODO: https://github.com/hetu-script/hetu-script-autobinding
    // to auto bind entity and entity accessors

    

    scriptPrefix = '';
    externalFunctions.forEach((key, value) {
      scriptPrefix += 'external fun $key\r\n';
    });
  }
*/
  void registerExternalFunction(String name, Function fn) {
    externalFunctions[name] = fn;
  }

  dynamic eval(String script, dynamic props) async {
    List<dynamic> positionalArgs = [];

    String scriptPrefix = '';
    externalFunctions.forEach((key, value) {
      scriptPrefix += 'external fun $key\n';
    });

    String fullscript = scriptPrefix + '\nfun main(';
    props.forEach((key, value) {
      fullscript += key + ', ';
      positionalArgs.add(value);
    });
    fullscript += 'props) {\n';
    fullscript += script;
    fullscript += '\n}';

    final lines = fullscript.split('\n');
    int i = 1;
    for (final line in lines) {
      print('$i)\t$line');
      ++i;
    }

    positionalArgs.add(props);

    try {
      final hetu = Hetu();
      await hetu.init(externalFunctions: externalFunctions);
      await hetu.eval(fullscript);
      var hetuValue = hetu.invoke('main', positionalArgs: positionalArgs/*, namedArgs: namedArgs*/);
      return hetuValue;
    } catch (e) {
      print(e);
    }

    return null;
  }
}