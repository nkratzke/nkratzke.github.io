import '../cards/Card.dart';
import 'dart:html';
import '../../controller/MasterController.dart';
import '../cards/Unit.dart';
import '../static/Enum.dart';
import '../cards/Hero.dart';

/*implementing healer effect logic*/
class Healer{

  /*enabling the player to play a non-hero, non-weather card from its
  * discard pile by displaying all fitting cards as playable cards
  * in the card display row of the field.
  * handling player and AI separately*/
  void applyEffect(List<Card> discard, MasterController mc, bool isPlayer){
    if(discard.isEmpty){
      mc.aiTurn();
      print('healer: attempting to play healer but discard pile is empty!');
      return;
    }

    if(isPlayer){
      print('heiler from spieler');
      List<DivElement> divsDiscard = mc.gc.divPlayerDiscard_playable();
      if(divsDiscard.isEmpty){
        mc.aiTurn();
        print('return from heiler cause discard is empty!');
      }

      DivElement cardDisplay = mc.gc.view.cardDisplayRow.children[1];
      cardDisplay.children.clear();
      print('healer card display cleared');
      mc.gc.addPositionsForCardDivs(divsDiscard);

      divsDiscard.forEach((DivElement div) {
        div.classes.add('karte');
        div.classes.add(mc.gc.getDivClass('kartenid', div));
      });

      cardDisplay.children.addAll(divsDiscard);
      print('healer card display updated');
    }else{
      List<Card> discardtmp = new List<Card>();
      discard.forEach((Card tmp){
        if(tmp is Unit){
          discardtmp.add(tmp);
        }
      });
      discardtmp.sort((Unit a, Unit b)=>a.apCurrent.compareTo(b.apCurrent));
      for(int i = 0; i < discard.length; i++){
        if(discardtmp[0].effects.contains(EFFECTS.SPY)){
          discardtmp.add(discardtmp.removeAt(i));
        }
        if(discardtmp[0].effects.contains(EFFECTS.HEALER)){
          discardtmp.add(discardtmp.removeAt(i));
        }
      }
      mc.getGame().playCard(discardtmp.removeLast(), mc.getGame().ai);
    }
  }
}