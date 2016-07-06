import 'Item.dart';
import '../NomNom.dart';


class SpecialItem extends Item {

  /**
   * Constructor
   */
  SpecialItem(int id) : super(id);

  /**
   * A function what do special things to the game like ghosts are eatable or warp to a other level
   * @param pm Pacman where the pick up has a effect on
   */
  onPickUp(NomNom pm) {
    pm.doSpecial(this.id);
  }
}