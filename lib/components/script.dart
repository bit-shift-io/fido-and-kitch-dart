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
    } else {
      print("Error: Script $name has no entity!");
    }
    return await h.eval(script, props);
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