# Fido and Kitch

Lurid Land made with Flutter and Flame.

## Install

Not sure this is right but:

    flutter create .

## Develop

    flutter run

## Map Editor

https://www.mapeditor.org/

## Assets

Here are a list of assets we use in the game and their source of origin.

* Cat & Dog - https://opengameart.org/content/cat-dog-free-sprites
* Platformer tiles - https://opengameart.org/content/generic-platformer-tiles
* Keys - https://opengameart.org/content/key-icons
* Teleporter - https://opengameart.org/content/4-summoning-circles
* Cage - https://opengameart.org/content/cage

## Todo List

* flutter pub add flame_tiled - https://pub.dev/packages/flame_tiled/install - version of flame I am using is too new?

## Architecture

Components are building blocks.
Entities are root level items that are made up of components.
Entities should interact with one another and each entity can interact with its own components, but no entity should know about another entities components.
