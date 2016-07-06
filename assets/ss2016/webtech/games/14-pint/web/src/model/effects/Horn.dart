import '../Row.dart';
import '../cards/Card.dart';
import '../cards/Unit.dart';

/*implementing horns effect logic*/
class Horn{

  /*doubling all non-hero, non-weather cards ap of
  * the target row, ignoring the card played with
  * this effect.
  * modifies the horn counter for not letting this
  * effect stack. would be too powerful*/
  void applyEffect(Row sourceRow, Card source){
    sourceRow.getCards().forEach((Card k){
      if(k is Unit && k!=source){
        /*horns may not stack, therefor we need to check if
        * any horn effects were applied previously*/
        if(k.hornCount == 0){
          k.setAPTo(
            /*multiply currents cards AP with the factor provided by
            * the preferences.dart*/
            k.apCurrent*sourceRow.field.game.mc.settings.get('hornAPmod')
          );
          k.hornCount++;
        }
      }
    });
  }
}