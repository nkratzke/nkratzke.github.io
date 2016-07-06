import 'static/Enum.dart';
import 'cards/Unit.dart';
import 'cards/Card.dart';
import 'Field.dart';

/*model version of a row of the game phase. holding all cards, summed up AP
* and weather effects currently active.
* knows its own type and wether it belongs to a player or the ai.
* can reset itself by an external method call by clearing the list of cards
* and weather effects currently active*/
class Row{
  /*type information about this row, doesn't differ AI and player rows*/
  ROWTYPE typ;
  /*type information about this row, differs AI and player rows*/
  ROWTYPEDIST typDist;
  /*type information about this row wether it belongs to player or AI*/
  PLAYERTYPE typePlayer;
  /*summed up AP of all card objects currently placed in this row*/
  int ap;
  /*reference to the object holding all rows of the game*/
  Field field;
  /*list of cards currently placed in this row*/
  List<Card> _cards;
  /*list of weather effects currently applied to this row*/
  List<EFFECTS> weatherEffects;

  Row(ROWTYPE typ, ROWTYPEDIST typDist, Field f, PLAYERTYPE typePlayer){
    this.typ = typ;
    this.typDist = typDist;
    this.typePlayer = typePlayer;
    _cards = new List<Card>();
    weatherEffects = new List<EFFECTS>();
    field = f;
  }

  //****//
  //Misc//
  //****//
  /*Sums up all cards AP, returning the sum and refreshing
  * this rows summed AP cache*/
  int sumAP(){
    ap = 0;

    _cards.forEach( (Unit e) {
      ap+=e.apCurrent;
    });

    return ap;
  }

  /*returns a string-representation of this rows summed up ap*/
  String sumAP_s(String refluxPrefix){
    return refluxPrefix + sumAP().toString();
  }

  /*triggers all AP-related effects in this row in the proper order*/
  void _triggerEffects(){
    List<Card>  brotherhood = new List<Card>(),
                horn = new List<Card>(),
                moraleboost = new List<Card>(),
                rest = new List<Card>();

    /*putting each card currently placed in this row in distinct lists
    * ordered by their effects*/
    for(int i=0; i<_cards.length; i++){
      Card k0 = _cards[i];

      if(k0.effects.isEmpty){
        rest.add(k0);
      }
      else if(k0.effects[0]==EFFECTS.BROTHERHOOD){
        brotherhood.add(k0);
      }
      else if(k0.effects[0]==EFFECTS.MORALEBOOST){
        moraleboost.add(k0);
      }
      else if(k0.effects[0]==EFFECTS.HORN){
        horn.add(k0);
      }else{
        rest.add(k0);
      }
    }

    /*putting back each card to the list of cards currently placed in this row.
    * this is taking care of the need to have them in the correct order for
    * applying effects on the cards of this row*/
    _cards.clear();
    brotherhood.forEach(    (Card k1)=>_cards.add(k1));
    horn.forEach(       (Card k2)=>_cards.add(k2));
    moraleboost.forEach( (Card k3)=>_cards.add(k3));
    rest.forEach(       (Card k4)=>_cards.add(k4));

    /*taking care of possible weather effects applied to this row*/
    if(weatherEffects.isNotEmpty){
      _cards.forEach((Card k) => k.setAPTo( k.getAPCurrent() == 0 ? 0 : 1 ));
    }

    /*now trigger all effects for all cards currently placed in this row*/
    for(int i=0; i<_cards.length; i++){
      _triggerEffect(_cards[i]);
    }
  }

  /*triggers the ap-related effects for this row from a card*/
  void _triggerEffect(Card source){
    if(source.effects.contains(EFFECTS.BROTHERHOOD)){
      print(source.getEffects());
      field.game.eBrotherhood.applyEffect(this, source);
    }
    if(source.effects.contains(EFFECTS.HORN)){
      print(source.getEffects());
      field.game.eHorn.applyEffect(this, source);
    }
    if(source.effects.contains(EFFECTS.MORALEBOOST)){
      print(source.getEffects());
      field.game.eMoraleBoost.applyEffect(this, source);
    }
  }

  /*clears the list of cards and all weather effects of this row*/
  void clearCardsAndWeather(){
    clearWeather();
    _cards.forEach((Card k) => k.reset());
    _cards.clear();
  }

  /*clears all weather effects from this row*/
  void clearWeather() {
    print('weather effects cleared');
    weatherEffects.clear();
    _triggerEffects();
  }

  /*adds a weather effect and invokes the method
  * for triggering all ap-related effects in this row*/
  void addWeather(EFFECTS e){
    print('weather effect added');
    weatherEffects.add(e);
    _triggerEffects();
  }

  //******//
  //Getter//
  //******//
  List<Card> getCards(){return _cards;}

  //******//
  //Setter//
  //******//
  void addCard(Card k){
    _cards.add(k);
    _triggerEffects();
  }

  /*removes the given card from this row*/
  bool removeByReference(Card k){return _cards.remove(k);}
}