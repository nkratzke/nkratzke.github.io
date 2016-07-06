import 'static/Enum.dart';
import 'Field.dart';
import 'cards/Card.dart';
import 'dart:math';

/*represents a human player object*/
class Player{
  /*amount of lives the player currenty has*/
  int       lives,
  /*current level of the player*/
            level,
  /*current levelpoints of the player*/
            levelpoints,
  /*current summed up AP of this player object*/
              summedAP;
  /*current faction of the player*/
  FACTION     _faction;
  /*reference to the object holding the rows for player and AI*/
  Field       field;
  /*name of the player*/
  String      name,
  /*password the player has set */
              password,
  /*this players unique ID provided by the gamekey service*/
              id;
  /*list of card objects currently in the players hand*/
  List<Card>  hand,
  /*list of card objects currently in the players deck*/
              deck,
  /*list of card objects currently on the players discard pile*/
              discard,
  /*list of cards currently in the players card selection.
  * used in the pre game phase/view only*/
              cardSelection;
  /*list of card IDs the player currently owns. can hold the same ID
  * multiple times*/
  List<String> pool;
  /*information wether the player has or hasn't fold a round*/
  bool        hasFold = false;

  Player(this.lives, this.level, this.levelpoints, this.summedAP, this._faction,
      this.field, this.hand, this.deck, this.discard){
      cardSelection   = new List<Card>();
      pool            = new List<String>();
  }

  /*putting all cards from players hand and discard pile back into
  * the deck and then putting the given amount of cards into
  * the players hand
  * @param size   amount of cards to put into the players deck*/
  void buildHand(int size){
    handToDeck();
    discardToDeck();

    int handSize = deck.length < size ? deck.length : size;
    hand = buildHandForLevel(this.level, handSize);
  }

  /*building a hand for the given level with the given amount of cards
  * @param level  maximum level of the cards for the hand
  * @param handSize number of cards for the players hand*/
  List<Card> buildHandForLevel(int level, int handSize){
    Random      random      = new Random();
    List<Card>  reflux      = new List<Card>();
    int         currentRand;
    print('Deck bauen für level: ' + level.toString());

    for(int i = 0; i<handSize && !deck.isEmpty; i++){
      currentRand = random.nextInt(deck.length);
      if(deck[currentRand].level <= level){
        reflux.add(deck.removeAt(currentRand));
      }else{i--;} //TODO IHBÄH!
    }

    print('Deck groesse: ' + deck.length.toString());
    return reflux;
  }

  /*putting each card from the players hand back into the deck*/
  void handToDeck(){
    while(hand.length>0){
      deck.add(hand.removeLast());
    }
  }

  /*putting each card from the players discard pile back into the deck*/
  void discardToDeck(){
    while(discard.length>0){
      deck.add(discard.removeLast());
    }
  }

  /*putting each element from the players deck into the card selection pile.
  * useful for the creation of the deck in the pre game phase*/
  void deckInSelection(){
    while(deck.length>0){
      cardSelection.add(deck.removeLast());
    }
  }

  /*increasind the players level by 1 per call*/
  void increaseLevel(){
    level++;
  }

  /*resetting this player object to its default state by putting all cards
  * from the hand and discard pile back into the deck, then resetting all cards
  * in the deck.
  * setting the summed up ap */
  void reset(){
    handToDeck();
    discardToDeck();
    deckResetAllCards();
    summedAP = 0;
    lives = field.game.mc.settings.get('defaultLivesPlayer');
    if(!(this is Player)){
      lives = field.game.mc.settings.get('defaultLivesAI');
    }
    hasFold = false;
  }

  /*resetting all cards back to their default values by
  * invoking the reset method of all cards in the deck#
  * of this object*/
  void deckResetAllCards(){deck.forEach((Card k) => k.reset());}

  /*setting the owner attribute on all cards in all card piles
  * to this object. ownership is used for assigning cards back
  * to the player after a game has ended and the user wants to
  * play another one.*/
  void takeOwnershipOfCards(){
    hand.forEach((Card k) => k.owner = this);
    deck.forEach((Card k) => k.owner = this);
    discard.forEach((Card k) => k.owner = this);
    cardSelection.forEach((Card k) => k.owner = this);
  }

  /*returns a partial string representation of the players state,
  * ignoring card piles*/
  String valuesMatrix(){
    return  'name: ' + name + '\n' +
        'level: ' + level.toString() + '\n' +
        'levelpunkte: ' + levelpoints.toString() + '\n' +
        'friedhof: ' + discard.length.toString() + '\n' +
        'deck: ' + deck.length.toString() + '\n' +
        'hand: ' + hand.length.toString() + '\n' +
        'fraktion: ' + _faction.toString();
  }

  //******//
  //Getter//
  //******//
  List<Card> getDeck(){return deck;}
  FACTION getFaction(){return _faction;}

  //******//
  //Setter//
  //******//
  void setFraktion(FACTION f){_faction = f;print(this.runtimeType.toString() + ' fraktion set to ' + _faction.toString());}
}