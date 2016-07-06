import 'Item.dart';
import '../NomNom.dart';

class PointItem extends Item {
  int points;

  /**
   * Constructor
   */
  PointItem(int id, this.points) : super(id);

  /**
   * A function to change the score of Pacman
   * @param pm Pacman where the pick up has a effect on
   */
  onPickUp(NomNom pm) {
    pm.modifyPoints(points);
  }

  /**
   * A function to return a string of the type and the points of item
   * @return A string
   */
  String toString(){
    return "PointItem, value:"+this.points.toString();
  }
}