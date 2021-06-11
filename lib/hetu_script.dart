import 'package:flame/components.dart';
import 'package:hetu_script/hetu_script.dart';

import 'components/mixins.dart';
import 'components/extensions.dart';
import 'components/switch_component.dart';

class HetuScript {

  static final HetuScript _singleton = HetuScript._internal();

  factory HetuScript() {
    return _singleton;
  }

  HetuScript._internal();

  Map<String, Function> externalFunctions = {
      'findFirstChild': (Component c, String name) {
        if (c is BaseComponent) {
          BaseComponent b = c as BaseComponent;
          return b.findFirstChild<Component>(name);
        }
        return null;
      },
      'setActiveComponent': (SwitchComponent s, String name) {
        s.setActiveComponent(name);
      },
      'getActiveComponent': (SwitchComponent s) {
        return s.activeComponent;
      },
      'getName': (Component c) {
        if (c is HasName) {
          HasName n = c as HasName;
          return n.name;
        }

        return null;
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
      scriptPrefix += 'external fun $key\r\n';
    });

    String fullscript = scriptPrefix + '\r\nfun main(';
    props.forEach((key, value) {
      fullscript += key + ', ';
      positionalArgs.add(value);
    });
    fullscript += 'props) {\r\n';
    fullscript += script;
    fullscript += '\r\n}';
    print(fullscript);

    positionalArgs.add(props);

    final hetu = Hetu();
    await hetu.init(externalFunctions: externalFunctions);
    await hetu.eval(fullscript);
    var hetuValue = hetu.invoke('main', positionalArgs: positionalArgs/*, namedArgs: namedArgs*/);
    return hetuValue;
  }
}