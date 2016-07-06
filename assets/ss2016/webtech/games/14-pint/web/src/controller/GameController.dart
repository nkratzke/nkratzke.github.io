import '../view/GameView.dart';
import 'MasterController.dart';
import '../model/static/Enum.dart';
import '../model/cards/Card.dart';
import '../model/cards/Hero.dart';
import 'dart:html';
import 'dart:async';
import '../model/ai/AI.dart';
import '../model/Player.dart';
import '../model/Field.dart';
import '../model/Game.dart';
import '../model/Row.dart';
import 'buttonElements/GVButtons.dart';

/*handles the game phase. controls the model during the game phase*/
class GameController{
  /*reference to the helper class used by this controller class for
  * generating button elements including their logic for the view
  * class controlled by this class*/
  GVButtons _buttons;
  /*reference to the view class controlled by this controller class*/
  GameView         view;
  /*reference to the master controller controlling this controller class*/
  MasterController  mc;
  /*data structure enabling the controlled view to match a card representing
  * table cell elements with the unique css class. every time a card
  * representing table cell element is created out of a card object
  * the card objects card id is used as the key referenced by
  * the table cell element in the map*/
  Map<TableCellElement, String> _tceIDs;
  /*data structure enabling the controlled view to match a card representing
  * div element with the card id it represents for adding each cards
  * unique css class*/
  Map<DivElement, String> _divIDs;

  GameController(MasterController masterController){
    this.mc = masterController;
    _buttons = new GVButtons(this);
    view    = new GameView(this);
    _tceIDs = new Map<TableCellElement, String>();
    _divIDs = new Map<DivElement, String>();
  }

  /*updates the game phase state.
  * updating the master controller to the next game phase if either the player
  * or the ai got no lives left.
  * updates itself and the view if both player and ai has fold.
  * updates the view if only the ai has fold.
  * invoking an ai turn if only the player has fold as well as updating itself
  * and the view.*/
  void update(bool ki){
    print('sc-update\n');
    print('Groesse der KI-Hand vor dem Update: ' + mc.getAIHandLength().toString());
    bool playerHasFold, aiHasFold, playerHandEmpty, aiHandEmpty, playerHasLives, aiHasLives;
    playerHasFold   = playerFold();
    aiHasFold       = aiFold();
    playerHandEmpty = getPlayerHand().length  == 0 ? true : false;
    aiHandEmpty     = mc.getAIHandLength()    == 0 ? true : false;
    playerHasLives  = mc.getPlayerLive()      == 0 ? false : true;
    aiHasLives      = mc.getAILive()          == 0 ? false : true;
    playerHasFold   = playerHandEmpty ?   true : playerHasFold;
    aiHasFold       = aiHandEmpty ?       true : aiHasFold;

    print('spielerHatGepasst: '   + playerHasFold.toString() + '\n'+
          'kiHatGepasst: '        + aiHasFold.toString() + '\n'+
          'spielerHandLeer: '     + playerHandEmpty.toString() + '\n'+
          'kiHandLeer: '          + aiHandEmpty.toString() + '\n'+
          'spielerLebenUebrig: '  + playerHasLives.toString() + '\n'+
          'kiLebenUebrig: '       + aiHasLives.toString() + '\n');

   getField().updatedSummedAP();

    if(!playerHasLives || !aiHasLives){
      print('Spieler und KI haben keine Leben mehr, naechste Phase\n');
      nextPhase();
      return;
    }
    if(playerHasFold && aiHasFold){
      print('Spieler und KI haben gepasst, Runde ist zuende\n');
      if(getPlayerAP() > getAiAP())  {mc.setAILive(-1);}
      if(getPlayerAP() < getAiAP())  {mc.setPlayerLive(-1);}
      if(getPlayerAP() == getAiAP()) {mc.setPlayerLive(-1);mc.setAILive(-1);}

      print('Passen bei Spieler und KI zurücksetzen\n');
      addResult(getPlayerAP(), getAiAP());
      mc.setPlayerFold(false);
      mc.setAIFold(false);
      mc.setPlayerAP(0);
      mc.setAIAP(0);

      print('Spieldfeld-Reihen clearen\n');
      mc.clearReihen();

      print('SC update aufrufen\n');
      this.update(false);
      view.update();
      return;
    }
    if(!playerHasFold && aiHasFold){
      view.update();
      return;
    }
    if(playerHasFold && !aiHasFold){
      getAI().makeAMove(mc);
      this.update(false);
      view.update();
      return;
    }
    if(!playerHasFold && !aiHasFold){
      view.update();
    }
  }


  //****//
  //Misc//
  //****//
  /*clears all children from the game view div element*/
  void clearView(){
    view.clear();
  }

  /*void sortAllRows(){
    mc.rowsSortAll();
  }*/

  /*updating to the after game phase by clearing
  * the view table and updating the master controller
  * to the after game phase*/
  void nextPhase(){
    clearView();
    mc.update(GAMEPHASE.DISPLAYRESULT, false);
  }

  /*clears the card id buffer for all card representing table cell elements*/
  clearTceIDs(){
    _tceIDs.clear();
  }
  /*clears the card id buffer for all card representing div elements*/
  clearDivIDs(){
    _divIDs.clear();
  }

  /*calculates the top left corner position in percent for each
  * given div element starting at the given offset from the
  * screens left border.
  * starts overlapping the elements after more cards than the
  * given overlapTrigger are to be displayed in a field row
  * or players card display row*/
  List<DivElement> addPositionsForCardDivs(List<DivElement> elements){
    double  positionModifier  = 0.0,
            distanceModifier  = mc.settings.get('gc_cardDist'),
            offset            = mc.settings.get('gc_cardPositionOffset'),
            max               = mc.settings.get('gc_cardPositionMax'),
            cardSize          = mc.settings.get('gc_cardWidth'),
            range             = max-offset,
            thisPosition      = 0.0;
    int     length            = elements.length,
            overlapTrigger     = mc.settings.get('gc_cardOverlap');

    positionModifier = length > overlapTrigger ?
    range / length : cardSize + distanceModifier;

    for(int i=0; i<length; i++){
      thisPosition = offset + i * positionModifier;
      elements[i].style.left = thisPosition.toString() + '%';
      elements[i].style.zIndex = i.toString();
    }

    return elements;
  }

  //*************//
  //HTML Elements//
  //*************//
  /*returns a button element enabling the player to fold a round*/
  ButtonElement beFold(){
    return _buttons.beFold();
  }
  /*returns a button element enabling the player to display the help table
  * instead if the field*/
  ButtonElement beHelp([String s]){
    return _buttons.beHelp(s);
  }
  /*returns a button element enabling the player to display his hand pile
  * in the card display*/
  ButtonElement bePlayerHand(){
    return _buttons.bePlayerHand();
  }
  /*returns a button element enabling the player to display his discard
  * pile cards in the card display*/
  ButtonElement bePlayerDiscard(){
    return _buttons.bePlayerDiscard();
  }

  /*returns a div element for each card in the players hand.
  * elements are playable and are invoking an ai-turn and a
  * view update after its possible effects are executed*/
  List<DivElement> divsPlayerHand(){
    List<DivElement> reflux = new List<DivElement>();

    getPlayerHand().forEach((Card k){
      DivElement div = k.basicDivElement();
      _playableOnClickEvents(div, k, getPlayerHand());
      _divIDs.putIfAbsent(div, () =>  k.id);
      reflux.add(div);
    });

    return reflux;
  }

  /*returns a div element for each card in players discard pile
  * except for heroes and weather cards. returned elements are
  * playable. invokes an ai-turn and view update if the element
  * chosen by the player is no healer.*/
  List<DivElement> divPlayerDiscard_playable(){
    List<DivElement>  reflux = new List<DivElement>();
    List<Card>      playable = new List<Card>();

    getPlayerDiscard().forEach((Card k){
      if(!(k is Hero)){
        if(k.effects.isEmpty){
          playable.add(k);
        }else if(k.effects[0] != EFFECTS.WEATHER){
          playable.add(k);
        }
      }
    });

    playable.forEach((Card k){
      DivElement div = k.basicDivElement();
      _playableOnClickEvents(div, k, getPlayerDiscard());
      _divIDs.putIfAbsent(div, () =>  k.id);
      reflux.add(div);
    });

    return reflux;
  }

  /*adds onclick-events to a div element (div represents a card).
  * if the user has not released the mousebutton or finger after
  * the set amount of milliseconds, the card will not be played.
  * otherwise the card is removed from its parent list and the
  * games playCard() method is invoked*/
  _playableOnClickEvents(DivElement div, Card k, List<Card> source){
    bool clicked;

    div.onMouseDown.listen((Event e){
      clicked = true;
      new Timer(new Duration(milliseconds: mc.settings.get('playCardCancelDelay')),(){
        clicked = false;
      });
    });
    div.onMouseUp.listen((Event e){
      if(clicked){
        source.remove(k);
        getGame().playCard(k, getPlayer());
        if(k.effects.isEmpty){
          mc.aiTurn();
          view.update();
        }else if(k.effects[0] == EFFECTS.HEALER){}
        else{
          mc.aiTurn();
          view.update();
        }
      }
    });
  }

  /*Div-Elements for card stacks*/
  List<DivElement> divPlayerDiscard() {return _divElementsFor(getPlayerDiscard());}
  List<DivElement> divPlayerSiege()   {return _divElementsFor(cardsPlayerSiege());}
  List<DivElement> divPlayerDist()    {return _divElementsFor(cardsPlayerDist());}
  List<DivElement> divPlayerClose()   {return _divElementsFor(cardsPlayerClose());}
  List<DivElement> divAISiege()       {return _divElementsFor(cardsAISiege());}
  List<DivElement> divAIDist()        {return _divElementsFor(cardsAIDist());}
  List<DivElement> divAIClose()       {return _divElementsFor(cardsAIClose());}
  /*returns a non-playable element for each card in the given list.
  * adds an abosolute position in percent starting from the left screen
  * border.*/
  List<DivElement> _divElementsFor(List<Card> cards){
    List<DivElement> reflux = new List<DivElement>();

    cards.forEach((Card k){
      DivElement div = k.basicDivElement();
      _divIDs.putIfAbsent(div, () => k.id);
      reflux.add(div);
    });
    addPositionsForCardDivs(reflux);
    return reflux;
  }


  //******//
  //Getter//
  //******//
  /*returns a string representation for a rows accumulated AP*/
  String apAiSiege(String prefix)      {return prefix + getRowsAI()    [ROWTYPE.SIEGE].sumAP().toString();}
  String apAiDist(String prefix)       {return prefix + getRowsAI()    [ROWTYPE.DIST].sumAP().toString();}
  String apAiClose(String prefix)      {return prefix + getRowsAI()    [ROWTYPE.CLOSE].sumAP().toString();}
  String apPlayerSiege(String prefix)  {return prefix + getRowsPlayer()[ROWTYPE.SIEGE].sumAP().toString();}
  String apPlayerDist(String prefix)   {return prefix + getRowsPlayer()[ROWTYPE.DIST].sumAP().toString();}
  String apPlayerClose(String prefix)  {return prefix + getRowsPlayer()[ROWTYPE.CLOSE].sumAP().toString();}

  /*returns a string representation of a piles card cound*/
  String aiHandLength()                     {return getAI().hand.length.toString();}
  String aiDeckLength()                     {return getAI().deck.length.toString();}
  String aiDiscardLength()                  {return getAI().discard.length.toString();}
  String playerHandLength()                 {return getPlayerHand().length.toString();}
  String playerDeckLength()                 {return getPlayer().deck.length.toString();}
  String playerDiscardLength()              {return getPlayer().discard.length.toString();}

  String getCardClass(String classPrefix,
                      TableCellElement tce) {return classPrefix + _tceIDs[tce];}
  String getDivClass(String classPrefix,
      DivElement div)                       {return classPrefix + _divIDs[div];}
  Card       getCard(String id)            {return mc.getCardData().cloneID(id);}

  /*returns the length of a players pile*/
  int playerHandSize()                      {return getPlayerHand().length;}
  int playerDeckSize()                      {return getPlayerDeck().length;}
  //returns the div elements representing the players hand cards
  List<DivElement> playerCardDisplay()      {return view.cardDisplayRow.children[1].children;}

  /*Misc*/
  String getPlayerName()         {return getPlayer().name;}
  Player getPlayer()             {return mc.getPlayer();}
  List<Card> getPlayerDeck()     {return getPlayer().getDeck();}
  List<Card> getPlayerHand()     {return getPlayer().hand;}
  List<Card> getPlayerDiscard()  {return getPlayer().discard;}
  List<Card> getAIDeck()         {return getAI().deck;}
  List<Card> getAIHand()         {return getAI().hand;}
  List<Card> getAIDiscard()      {return getAI().discard;}
  int getPlayerAP()              {return getGame().sumPlayerAP();}
  String getPlayerLives()        {return getPlayer().lives.toString();}
  int getAiAP()                  {return getGame().sumAiAP();}
  AI getAI()                     {return getGame().ai;}
  Field getField()               {return getGame().field;}
  Game getGame()                 {return mc.getGame();}
  String getAILives()            {return getAI().lives.toString();}
  bool playerFold()              {return getPlayer().hasFold;}
  bool aiFold()                  {return getAI().hasFold;}

  /*returns all cards of a row*/
  List<Card> cardsPlayerSiege() {return getRowsPlayer() [ROWTYPE.SIEGE].getCards();}
  List<Card> cardsPlayerDist()  {return getRowsPlayer() [ROWTYPE.DIST].getCards();}
  List<Card> cardsPlayerClose() {return getRowsPlayer() [ROWTYPE.CLOSE].getCards();}
  List<Card> cardsAISiege()     {return getRowsAI()     [ROWTYPE.SIEGE].getCards();}
  List<Card> cardsAIDist()      {return getRowsAI()     [ROWTYPE.DIST].getCards();}
  List<Card> cardsAIClose()     {return getRowsAI()     [ROWTYPE.CLOSE].getCards();}

  /*returning the row-maps for player and ai*/
  Map<ROWTYPE, Row> getRowsPlayer() {return getField().rowsPlayer;}
  Map<ROWTYPE, Row> getRowsAI()     {return getField().rowsAI;}

  //******//
  //Setter//
  //******//
  /*adds players ap and ai ap to the result buffer for the after game view*/
  void addResult(int apPlayer, int apAI){
    getGame().results.add(apPlayer);
    getGame().results.add(apAI);
  }
}