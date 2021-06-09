import 'package:fido_and_kitch/components/mixins.dart';
import 'package:flame/components.dart';

// Generic way to attach an unknown block of data
// which can be used by a system
class DataComponent extends Component with HasName {
  dynamic data;

  Future<void> fromData(dynamic yaml) async {
    name = yaml['name'];
    data = yaml;
  }
}

Future<DataComponent> pickupComponentFromData(dynamic yaml) async {
  final comp = new DataComponent();
  await comp.fromData(yaml);
  return comp;
}