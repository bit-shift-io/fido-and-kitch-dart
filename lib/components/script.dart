import 'package:flame/components.dart';

import '../factory.dart';
import '../hetu_script.dart';
import 'mixins.dart';
import '../components/extensions.dart';

class Script extends BaseComponent with HasName, HasEntity {
  String script = '';

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    addChildren(await Factory().createFromDataArray(yaml['children']));
    script = yaml['script'];
  }

  dynamic eval(dynamic props) async {
    HetuScript h = HetuScript();
    props['entity'] = entity;
    if (entity != null) {
      props['game'] = entity!.gameRef;
    }
    return await h.eval(script, props);

    /*
    // TODO: https://github.com/hetu-script/hetu-script-autobinding
    // to auto bind entity and entity accessors
    var hetu = Hetu();
    await hetu.init(externalFunctions: {
      'fn_props': () {
        return props;
      },
      'findFirstChild': (Component c, String name) {
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
      }
    });

    // TODO: automate the external fn list here:
    // TODO: automate expand the props to be an argument so we done need to do: props['entitiy'] we can just use entity
    String fullscript = '''
      external fun fn_props
      external fun findFirstChild
      external fun setActiveComponent
      external fun getActiveComponent
      external fun getName
      fun main(props) {
        ${this.script}
      }
    ''';
    /*
    Map<String, dynamic> namedArgs = {
      'props': props
    };*/
    List<dynamic> positionalArgs = [props];
    await hetu.eval(fullscript);
    var hetuValue = hetu.invoke('main', positionalArgs: positionalArgs/*, namedArgs: namedArgs*/);
    return hetuValue;
    */
  }
}

Future<Script> scriptComponentFromData(dynamic data) async {
  final comp = new Script();
  await comp.fromData(data);
  return comp;
}

Script? scriptComponentFromString(String name, String? script) {
  if (script == null) {
    return null;
  }

  final comp = new Script();
  comp.name = name;
  comp.script = script;
  return comp;
}