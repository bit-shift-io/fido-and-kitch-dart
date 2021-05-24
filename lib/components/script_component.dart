import 'package:flame/components.dart';
import 'package:hetu_script/hetu_script.dart';

import '../factory.dart';
import 'mixins.dart';
import 'extensions.dart';

class ScriptComponent extends BaseComponent with HasName {
  String script;

  Future<void> fromYaml(dynamic yaml) async {
    name = yaml['name'];
    addChildren(await Factory().createFromYamlArray(yaml['children']));
    script = yaml['script'];
  }

  dynamic eval(dynamic props) async {
    var hetu = Hetu();
    await hetu.init(externalFunctions: {
      'fn_props': () {
        return props;
      },
    });
    String fullscript = '''
      external fun fn_props
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
  }
}

Future<ScriptComponent> scriptComponentFromYaml(dynamic yaml) async {
  final comp = new ScriptComponent();
  await comp.fromYaml(yaml);
  return comp;
}