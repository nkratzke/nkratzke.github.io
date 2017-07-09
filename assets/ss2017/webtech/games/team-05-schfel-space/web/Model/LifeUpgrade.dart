import 'Item.dart';

class LifeUpgrade extends Item {
  // Anzahl an leben die hinzugefügt werden sollen
  int _life;
  int get life => _life;

  LifeUpgrade(int x, int y, int elementID, int valid, int life) : super(x, y, elementID, valid) {
    this._life = life;
  }




}