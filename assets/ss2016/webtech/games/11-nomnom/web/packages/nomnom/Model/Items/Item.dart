import '../NomNom.dart';
import '../GameObject.dart';

abstract class Item extends GameObject{
  int type;

  /**
   * Constructor
   */
  Item(int id) : super(id);

  /**
   * A function for what happend, when we pick the item up
   * @param pm Pacman where the pick up has a effect on
   */
  void onPickUp(NomNom pm){

  }

}

