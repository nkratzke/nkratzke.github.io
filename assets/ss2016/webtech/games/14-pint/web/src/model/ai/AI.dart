import '../Player.dart';
import '../../controller/MasterController.dart';
import '../cards/Card.dart';
import '../cards/Unit.dart';
import '../cards/Hero.dart';
import '../static/Enum.dart';
import '../Row.dart';

class AI extends Player{

  /*Constructor*/
  AI(lives, level, levelpoints, summedAP, _faction,
      field, hand, deck, discard) : super(lives, level, levelpoints, summedAP, _faction,
      field, hand, deck, discard){
    print('KI konstruiert');
  }

  /*Checks if at least on Spy is in the Discard, if yes returns true, else false*/
  bool _discardContainsSpy(){
    if(this.discard.isNotEmpty) {
      this.discard.forEach((Card tmp) {
        if (tmp is Unit && tmp.effects.contains(EFFECTS.SPY)) {
          return true;
        }
      });
    }
    return false;
  }

  /*Returns a list of names of AI played Cards with Brotherhood effect*/
  List<String> _brotherhoodPlayed(){
    List<String> names = new List<String>();
    this.field.rowsAI.values.forEach((Row r){
      r.getCards().forEach((Card c){
        if(c.effects.contains(EFFECTS.BROTHERHOOD)){
          names.add(c.name);
        }
      });
    });
    return names;
  }

  /*Computes the AP of a given Row if Weather weren't active*/
  int _apWithoutWeather(Row r){
    int ret = 0;
    Row tmprow = new Row(r.typ, r.typDist, r.field, r.typePlayer);
    r.getCards().forEach((Card c){
      tmprow.addCard(c);
    });
    return ret;
  }

  /*Checks if the current weather is more useful then good weather, return true if yes, else false
   *@param rows List of ROWTYPES which are to check*/
  bool _weatherEffectHelpful(List<ROWTYPE> rows){
    int tmpAIGoodW = 0, tmpPlayerGoodW = 0, tmpAICurrent = 0, tmpPlayerCurrent = 0, diffAI = 0, diffPlayer = 0;
    rows.forEach((ROWTYPE type){
      tmpAIGoodW += _apWithoutWeather(this.field.rowsAI[type]);
      tmpAICurrent += this.field.rowsAI[type].ap;
      tmpPlayerGoodW += _apWithoutWeather(this.field.rowsPlayer[type]);
      tmpPlayerCurrent += this.field.rowsPlayer[type].ap;
      });

    diffAI = tmpAIGoodW - tmpAICurrent;
    diffPlayer = tmpPlayerGoodW- tmpPlayerCurrent;
    return diffPlayer > diffAI;
  }

  /*Adds each ROWTYPE on which a weather effect is active to a given list*/
  List<ROWTYPE> _checkRowWeather(List<ROWTYPE> rows){
    this.field.rowsAI.values.forEach((Row r){
      if(r.weatherEffects.isNotEmpty){
        rows.add(r.typ);
      }
    });
    return rows;
  }

  /*Checks if it's smart/necessary to fold, returns true if it is, else false*/
  bool _isFoldingUseful(MasterController mc){
    //if AI doesn't have Cards left, fold and return
    if(this.hand.length == 0){
      return true;
    }

    int apOnHand = 0;
    this.hand.forEach((Card c){
      apOnHand += c.getAPNormal();
    });

    //if AI doesn't have enough AP to win this round and doesn't need to, fold and return
    if((mc.getGame().player.summedAP > (this.summedAP+apOnHand)) && this.lives>1){
      return true;
    }

    //if Player has already folded and AI has more AP, fold and return
    if(mc.getGame().player.hasFold) {
      int diff = mc.getGame().player.summedAP - this.summedAP;
      if (diff < 0) {
        return true;
      }
    }
    //if AI has more AP than the player + half of the hand AP of the AI and has more than 1 live, fold and return
    if((this.summedAP) > ((mc.getGame().player.summedAP)+(apOnHand/2).round()) && this.lives>1){
      return true;
    }
    return false;
  }

  /*Checks which is the most useful card to play and plays it*/
  void makeAMove(MasterController mc){

	//fold if it's useful
    if(_isFoldingUseful(mc)){
      this.hasFold = true;
      print('KI hat gepasst\n');
      return;
    }

    //List to manage the sublist
    List<List<Card>> metalist = new List<List<Card>>();
    //Creates sublists of hand for different kinds of cards
    List<Card> tmpList = new List<Card>(), goodWeathers = new List<Card>(), siegeWeathers = new List<Card>(), distWeathers = new List<Card>(), closeWeathers = new List<Card>(), spies = new List<Card>(), brotherhoods = new List<Card>(), horns = new List<Card>(), healers = new List<Card>(), moraleboosts = new List<Card>(), heroesSiege = new List<Card>(), heroesDist = new List<Card>(), heroesClose = new List<Card>(), normalSiege = new List<Card>(), normalDist = new List<Card>(), normalClose = new List<Card>(), sortedHand = new List<Card>();

    //Adds all this sublist to a list
    metalist.add(normalSiege);
    metalist.add(normalDist);
    metalist.add(normalClose);
    metalist.add(spies);
    metalist.add(brotherhoods);
    metalist.add(horns);
    metalist.add(healers);
    metalist.add(moraleboosts);
    metalist.add(goodWeathers);
    metalist.add(siegeWeathers);
    metalist.add(distWeathers);
    metalist.add(closeWeathers);
    metalist.add(heroesSiege);
    metalist.add(heroesDist);
    metalist.add(heroesClose);

    //use help methods to gather data which is the most useful card to play
    bool spyInDiscard = _discardContainsSpy();
    List<ROWTYPE> rowWithActiveWeather = new List<ROWTYPE>();
    rowWithActiveWeather = _checkRowWeather(rowWithActiveWeather);
    bool strengthenedByWeather = _weatherEffectHelpful(rowWithActiveWeather);
    List<String> playedBrotherhoods = _brotherhoodPlayed();

    //Adds all cards on hand to the appropriate sublist
    for(int i = 0; i<this.hand.length; i++){
      if(this.hand[i].effects.contains(EFFECTS.WEATHER)){
        if(hand[i].getRowTypes().contains(ROWTYPE.SIEGE)){
          siegeWeathers.add(this.hand[i]);
        }
        else if(this.hand[i].getRowTypes().contains(ROWTYPE.DIST)){
          distWeathers.add(this.hand[i]);
        }
        else if(this.hand[i].getRowTypes().contains(ROWTYPE.CLOSE)){
          closeWeathers.add(this.hand[i]);
        }
      }
      else if(this.hand[i].effects.contains(EFFECTS.GOODWEATHER)){
        goodWeathers.add(this.hand[i]);
      }
      else if(this.hand[i].effects.contains(EFFECTS.SPY)){
        spies.add(this.hand[i]);
      }
      else if(this.hand[i].effects.contains(EFFECTS.BROTHERHOOD)){
        brotherhoods.add(this.hand[i]);
      }
      else if(this.hand[i].effects.contains(EFFECTS.HORN)){
        horns.add(this.hand[i]);
      }
      else if(this.hand[i].effects.contains(EFFECTS.HEALER)){
        healers.add(this.hand[i]);
      }
      else if(this.hand[i].effects.contains(EFFECTS.MORALEBOOST)){
        moraleboosts.add(this.hand[i]);
      }
      else if(this.hand[i] is Hero){
        if(this.hand[i].rowTypes.contains(ROWTYPE.SIEGE)){
          heroesSiege.add(this.hand[i]);
        }
        else if(this.hand[i].rowTypes.contains(ROWTYPE.SIEGE)){
          heroesDist.add(this.hand[i]);
        }
        else{
          heroesClose.add(this.hand[i]);
        }

      }
      else {
        if(this.hand[i].rowTypes.contains(ROWTYPE.SIEGE)){
          normalSiege.add(this.hand[i]);
        }
        else if(this.hand[i].rowTypes.contains(ROWTYPE.DIST)){
          normalDist.add(this.hand[i]);
        }
        else{
          normalClose.add(this.hand[i]);
        }
      }
    }

    //Creates a list of rows on which the Player played at least on card with horn effect
    List<Row> activePlayerHornRows = new List<Row>();
    this.field.rowsPlayer.values.forEach((Row r){
      r.getCards().forEach((Card c){
        if(c.effects.contains(EFFECTS.HORN)){
          activePlayerHornRows.add(r);
        }
      });
    });

    //plays spy if it has
    sortedHand.addAll(spies);//wenn auf der hand vorhanden, spielt die KI immer spione
    spies.clear();

    //enqueues healer if it can bring back a spy
    if(spyInDiscard){
      sortedHand.addAll(healers); //wenn Heiler auf hand und spion auf friedhof heiler spielen um spion wiederzubeleben
      healers.clear();
    }

    //enqueues good weather if the current weather
    if(!strengthenedByWeather && rowWithActiveWeather.isNotEmpty){
      sortedHand.addAll(goodWeathers); //wenn Wetterkarten negative auswirkungen auf ki haben bevorzugt spielen
      goodWeathers.clear();
    }
    //enqueues heroes for all rows with weather effect active
    if(rowWithActiveWeather.isNotEmpty){
      if(rowWithActiveWeather.contains(ROWTYPE.SIEGE)){
        sortedHand.addAll(heroesSiege);
        heroesSiege.clear();
      }
      if(rowWithActiveWeather.contains(ROWTYPE.DIST)){
        sortedHand.addAll(heroesDist);
        heroesDist.clear();
      }
      if(rowWithActiveWeather.contains(ROWTYPE.CLOSE)){
        sortedHand.addAll(heroesClose);
        heroesClose.clear();
      }
    }

    //enqueues cards with brotherhood effect, if corresponding card is already played
    if(playedBrotherhoods.isNotEmpty) {
      for (int i = 0; i < brotherhoods.length; i++) {
        if (playedBrotherhoods.contains(brotherhoods[i].name)) {
          sortedHand.add(brotherhoods[i]);
          brotherhoods.removeAt(i);
        }
      }
    }

    //put cards with brotherhood effect at the first position of the corresponding row list for normal units
    for (int i = 0; i < brotherhoods.length; i++) {
      if(brotherhoods[i].getRowTypes().contains(ROWTYPE.SIEGE)){
        tmpList.addAll(normalSiege);
        normalSiege.clear();
        normalSiege.add(brotherhoods[i]);
        brotherhoods.removeAt(i);
        normalSiege.addAll(tmpList);
      }
      if(brotherhoods[i].getRowTypes().contains(ROWTYPE.DIST)){
        tmpList.addAll(normalDist);
        normalDist.clear();
        normalDist.add(brotherhoods[i]);
        brotherhoods.removeAt(i);
        normalDist.addAll(tmpList);
      }
      if(brotherhoods[i].getRowTypes().contains(ROWTYPE.CLOSE)){
        tmpList.addAll(normalClose);
        normalClose.clear();
        normalClose.add(brotherhoods[i]);
        brotherhoods.removeAt(i);
        normalClose.addAll(tmpList);
      }
    }

    //enqueues all normal units for rows where no weather effect is active
    if(!rowWithActiveWeather.contains(ROWTYPE.SIEGE)){
      sortedHand.addAll(normalSiege);
      normalSiege.clear();
    }
    if(!rowWithActiveWeather.contains(ROWTYPE.DIST)){
      sortedHand.addAll(normalDist);
      normalDist.clear();
    }
    if(!rowWithActiveWeather.contains(ROWTYPE.CLOSE)){
      sortedHand.addAll(normalClose);
      normalClose.clear();
    }

    //enqueues all cards which are not enqueued yet
    metalist.forEach((List<Card> l){
      if(l.isNotEmpty){
        sortedHand.addAll(l);
      }
    });


    this.hand.clear();
    this.hand.addAll(sortedHand);
    mc.getGame().playCard(hand.removeAt(0), this);
    return;
  }

  /*Builds a hand for the AI. Resets the deck and rebuilds it under the
   *following conditions:
   * - Card must be less or equal AIs level
   * - If a Card got the brotherhood-effect, two additional
   *   clones of this card are added to the deck
   *@param level level for which the hand is to build
   *@param handSize size of the hand to build*/
  setLevel(int level, int handSize){
    List<Card> cardsFaction = field.game.mc.getCardData().cloneFor(this.getFaction(), true);
    List<Card> cardsNeutral = field.game.mc.getCardData().cloneNeutral();
    List<Card> cardsMerged = new List<Card>();
    cardsMerged.addAll(cardsFaction);
    cardsMerged.addAll(cardsNeutral);

    this.deck.clear();
    cardsMerged.forEach((Card c)  {
          if(c.level <= this.level){
            this.deck.add(c);
            if(c.effects.contains(EFFECTS.BROTHERHOOD)){
              this.deck.add(c.clone());
              this.deck.add(c.clone());
            }
          }
        }
    );

    this.hand = buildHandForLevel(level, handSize);
  }
}


