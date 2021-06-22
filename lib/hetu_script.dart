import 'package:fido_and_kitch/components/entity.dart';
import 'package:flame/components.dart';
import 'package:hetu_script/hetu_script.dart';

import 'components/mixins.dart';
import 'components/extensions.dart';
import 'components/script.dart';
import 'components/switch.dart';
import 'components/tiled_object.dart';
import 'game.dart';
import 'tiled_map.dart' as t; // TODO: fix names collision of TiledObject

class HetuScript {

  static final HetuScript _singleton = HetuScript._internal();

  factory HetuScript() {
    return _singleton;
  }

  HetuScript._internal();

  Map<String, Function> externalFunctions = {
      'findFirstChild': (Component? c, String name) {
        if (c == null) {
          return null;
        }

        if (c is BaseComponent) {
          BaseComponent b = c as BaseComponent;
          return b.findFirstChild<Component>(name);
        }
        return null;
      },
      'setActiveComponent': (Switch s, String name) {
        s.setActiveComponent(name);
      },
      'getActiveComponent': (Switch s) {
        return s.activeComponent;
      },
      'getName': (Component c) {
        if (c is HasName) {
          HasName n = c as HasName;
          return n.name;
        }

        return null;
      },
      'findObjectById': (MyGame game, int id) {
        return game.map!.findObjectById(id);
      },
      // find entity that is using the TiledObject with id
      'findEntityByObjectId': (MyGame game, int id) {
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