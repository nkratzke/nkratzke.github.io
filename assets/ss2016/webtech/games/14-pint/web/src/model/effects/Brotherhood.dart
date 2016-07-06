import '../Row.dart';
import '../cards/Card.dart';
import '../cards/Unit.dart';

/*implementing brotherhood effect logic*/
class Brotherhood{

  /*setting each cards AP like "current AP * number of cards with the same ID"
  * taking care of possible weather effects in the given row*/
  void applyEffect(Row sourceRow, Card sourceCard){
    /*amount of cards with the same name in the given row*/
    int count = 0,
    /*amount of AP each card with the same name has to be set to*/
                result;
    sourceRow.getCards().forEach((Card k)=>print(k.getAPCurrent().toString()+'\n'));
    sourceRow.getCards().forEach((Card k){
      if (k.name.compareTo(sourceCard.name)==0) {
        /*increasing the card counter by 1 if another card with the same
        * name was found in the given row*/
        count = count+1;
      } else {
        count = count;
      }
    });

    /*taking care of possible active weather effects. in this case each cards
    * AP is assumed to be 1*/
    if(sourceRow.weatherEffects.isNotEmpty){
      result = 1 * count;
    }
    /*if there are no active weather effects use the standard AP of this card*/
    else{
      result = sourceCard.getAPNormal() * count;
    }

    /*now setting each cards new AP to the calculated value*/
    sourceRow.getCards().forEach((Card k){
      if(k is Unit && sourceCard.name.compareTo(k.name)==0){
        k.setAPTo(result);
      }
    });
    sourceRow.getCards().forEach((Card k)=>print(k.getAPCurrent().toString()+'\n'));
  }
}