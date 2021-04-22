import 'package:fido_and_kitch/utils.dart';

List<String> anim(dir, aninName, numImages) {
  return List<String>.generate(10, (index) => '$dir/$aninName (${index + 1}).png');
}

List<String> walk(dir) {
  return anim(dir, 'Walk', 10);
}

/*
someFunc(List<String> imageNames, ) {
  List<Image> images = await Flame.images.loadAll(walk('cat'));
    print('Loaded ${images.length} for walk cycle animation');
    List<Sprite> sprites = List<Sprite>.generate(images.length, (index) => Sprite.fromImage(images[index], width: images[index].width as double, height: images[index].height as double));
    //Image image = await Flame.images.load('cat/Walk (1).png');
    //
    print('Created ${sprites.length} sprites for walk cycle animation');
    
    // https://github.com/flame-engine/trex-flame/blob/master/lib/game/t_rex/t_rex.dart
    double width = images[0].width as double;
    double height = images[0].height as double;

    //final sprite = Sprite.fromImage(image, width: width, height: height);

    comp = AnimationComponent(width, height, 
      Animation.spriteList(sprites, 
        stepTime: 0.2,
        loop: true
      )
    );

}
*/