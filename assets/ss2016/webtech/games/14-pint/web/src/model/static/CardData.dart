import '../cards/Card.dart';
import '../cards/Hero.dart';
import 'Enum.dart';
import '../../controller/MasterController.dart';

/*database for all known cards.
* provides several methods for cloning cards.
* does not return any reference to any card stored in the cardPool
* to provide fully distinct cards*/
class CardData{
  /*map of preconstructed card objects. for internal use by this
  * class only. getting a card object from this data structure
  * from the outside means creating a deep clone of the to get
  * card object*/
  Map<String, Card> _cardPool;
  /*reference to the master controller, is set within
  * contructor of this class*/
  MasterController mc;

  CardData(MasterController mc){
    this.mc = mc;
    _cardPool = new Map<String, Card>();
  }

  /*returns a card-clone for each card-id given in the param list*/
  List<Card> cloneIDs(List<String> toClone){
    List<Card> reflux = new List<Card>();
    toClone.forEach((String id){
      Card c = cloneID(id);
      cardTooltipText(c);
      reflux.add(c);
    });
    return reflux;
  }

  /*returns a clone of the card with the given id*/
  Card cloneID(String cardID){
    return _cardPool[cardID].clone();
  }

  /*returns a faction-specific list of cards, with or without hero-ards*/
  List<Card> cloneFor(FACTION faction, bool includeHeroes){
    List<Card> reflux = new List<Card>();

    _cardPool.values.forEach((Card k){
      if(k.faction == faction){
        if(includeHeroes){
          reflux.add(cloneID(k.id));
        }else if(!includeHeroes && k is Hero){
          //nix
          if(k.effects.isNotEmpty && k.effects.contains(EFFECTS.WEATHER) || k.effects.contains(EFFECTS.GOODWEATHER)){
            reflux.add(cloneID(k.id));
          }
        }else{
          reflux.add(cloneID(k.id));
        }
      }
      cardTooltipText(k);
    });

    return reflux;
  }

  /*clones all neutral cards*/
  List<Card> cloneNeutral(){
    List<Card> reflux = new List<Card>();

    _cardPool.values.forEach((Card c){
      if(c.faction == FACTION.NEUTRAL){
        Card clone = c.clone();
        reflux.add(clone);
        cardTooltipText(clone);
      }
    });

    return reflux;
  }

  /*returns clones of all known cards*/
  List<Card> cloneAll(){
    List<Card> reflux = new List<Card>();
    _cardPool.forEach((String key, Card value){
      reflux.add(value.clone());
    });
    return reflux;
  }

  /*Builds a list of all known cards and adding the tooltip-delay to
  * each cards corresponding attribute*/
  void buildPool(List<Card> l){
    l.forEach((Card k){
      _cardPool.putIfAbsent(k.id, ()=>k);
      k.tooltipDelay = mc.settings.get('cardTooltipDelay');
    });
  }

  /*Returns a list of IDs for each card in the param list*/
  List<String> getIDs(List<Card> cards){
    List<String> reflux = new List<String>();
    cards.forEach((Card k) => reflux.add(k.id));
    return reflux;
  }

  //******//
  //Getter//
  //******//
  int getCardCount(){return _cardPool.length;}
  cardTooltipText(Card c){
    if(c.effects.isNotEmpty){
      String effect = c.effects[0].toString();
      effect.replaceAll('[','');
      effect.replaceAll(']','');
      c.tooltipText = mc.settings.get('cardTooltipText_'+effect);
    }
  }
}