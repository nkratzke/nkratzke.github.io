import '../Row.dart';
import '../cards/Card.dart';
import '../cards/Unit.dart';

/*implementing moraleboosts logic*/
class MoraleBoost {

  /*adding +1 to all non-hero, non-weather cards current AP*/
  void applyEffect(Row sourceRow, Card sourceCard){
    sourceRow.getCards().forEach((Card k){
      if(k is Unit && k != sourceCard){
        k.setAPTo(
          /*add the amount of ap provided by the preferences.dart
          * to the current cards ap*/
          k.apCurrent+sourceRow.field.game.mc.settings.get('moraleBoostAPmod')
        );
      }
    });
  }
}