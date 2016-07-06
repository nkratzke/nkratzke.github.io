
abstract class GameObject {
  int id;

  GameObject(this.id);

  static const nomNomNeutral = 0;
  static const nomNomLeft = 1;
  static const nomNomRight = 2;
  static const nomNomDown = 3;
  static const nomNomUp = 4;

  static const block = 10;
  static const empty = 11;

  static const point = 20;
  static const cherry = 21;
  static const orange = 22;

  static const raspberry = 30;
  static const lemon = 31;

  static const blueBonbon = 40;
  static const redBonbon = 41;

  static const greenBonbon = 50;
  static const yellowBonbon = 51;

  static const yellowGhost = 100;
  static const greenGhost = 101;
  static const blueGhost = 102;
  static const redGhost = 103;
  static const pinkGhost = 104;

}