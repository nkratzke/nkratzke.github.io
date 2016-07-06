import 'Item.dart';
import '../NomNom.dart';

class SpeedItem extends Item {
  double speed;

  /**
   * Constructor
   */
  SpeedItem(int id, this.speed) : super(id);

  /**
   * A function to change the speed of Pacman or the ghost
   * @param pm Pacman where the pick up has a effect on
   */
  onPickUp(NomNom pm) {
    pm.adjustSpeed(this.id, speed);
  }
}