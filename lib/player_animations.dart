import 'package:fido_and_kitch/utils.dart';

List<String> anim(dir, aninName, numImages) {
  return List<String>.generate(10, (index) => '$dir/$aninName (${index + 1}).png');
}

List<String> walk(dir) {
  return anim(dir, 'Walk', 10);
}
