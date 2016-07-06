import '../view/PreGameView.dart';
import '../controller/MasterController.dart';
import '../model/static/Enum.dart';
import '../model/Player.dart';
import '../model/ai/AI.dart';
import '../model/Game.dart';
import '../model/cards/Card.dart';
import '../model/static/CardData.dart';
import 'buttonElements/PGVButtons.dart';
import 'dart:html';
import 'dart:async';

/*this controller handles the pre game phase where the player
* can choose which cards he wants to have in his deck.
* updating to the next phase via the start game button
* will invoke updating the master controller to the game phase.*/
class PreGameController{
  /*reference to the view class controlled by this controller class*/
  PreGameView                   view;
  /*helper class used for generating the pre game view buttons*/
  PGVButtons                    _buttons;
  /*reference to the controller class controlling this controller class*/
  MasterController              mc;
  /*data structure enabling the view controlled by this controller class to get
  * the card id of each card represented by a table cell element*/
  Map<TableCellElement, String> _tceIDs;
  /*data structure enabling the view controlled by this controller class to get
  * the card id of each card represented by a div element*/
  Map<DivElement, String>       _divIDs;
  /*data structure enabling the view to get the card object represented by a
  * html element*/
  Map<Element, Card>            _cardCache;

  PreGameController(MasterController mc){
    view        = new PreGameView(this);
    _buttons    = new PGVButtons(this);
    this.mc     = mc;
    _tceIDs     = new Map<TableCellElement, String>();
    _divIDs     = new Map<DivElement, String>();
    _cardCache  = new Map<Element, Card>();
  }



  //****//
  //Main//
  //****//

  /*updates the pre game state by creating the card pool for the player
  * and updating the view*/
  void update(){
    createCardSelection(mc.getPlayerFaction());
    print(getPlayer().cardSelection);
    print(getPlayer().cardSelection.length);
    view.update();
  }

  /*updates the master controller to the next (game phase) phase.
  * if the ai is null or its level isnt equal to the players
  * the ai is reset and its setLevel-method is invoked*/
  void nextPhase(){
    view.clear();
    if(getAI() == null || getAI().level != getPlayer().level){
      mc.resetAI();
    }
    int levelmod = mc.settings.get('pgc_kiLevelMod');
    levelmod = levelmod < 0 ? 0 : levelmod;
    getAI().setLevel(getPlayer().level+mc.settings.get('pgc_kiLevelMod'), mc.settings.get('pgc_handSizeAI') );
    mc.update(GAMEPHASE.PLAY, false);
  }



  //**************//
  //Card Selection//
  //**************//

  /*creates the card pool for the player and the given faction.
  * buffers all possible card-ids from the players pool.
  * for each card currently in the players deck it removes
  * one of the corresponding card-ids from the buffer.
  * then it sorts out all cards with the wrong faction
  * except for neutral.
  * it also sorts out all cards with a level higher
  * than the current player level*/
  void createCardSelection(FACTION playerFaction){
    print('createCardSelection');
    List<String> tempIDs = new List<String>();
    CardData kartendaten = getGame().cardData;
    getPlayer().cardSelection.clear();
    print('createCardSelection tempIDs before pool merge: ' + tempIDs.length.toString());
    tempIDs.addAll(getPlayer().pool);
    print('createCardSelection tempIDs after pool merge: ' + tempIDs.length.toString());
    _compareAndFilterDeck(tempIDs);
    print('createCardSelection tempIDs after deck check: ' + tempIDs.length.toString());
    _filterFactionAndLevel(tempIDs, kartendaten, getPlayer().getFaction());
  }

  /*removes a card id from the buffer for each card with a
  * corresponding id in the players deck */
  _compareAndFilterDeck(List<String> tempIDs){
    for(int i=0;i<getPlayer().deck.length;i++){
      Card temp = getPlayer().deck[i];
      if(tempIDs.contains(temp.id)){
        tempIDs.removeAt(tempIDs.lastIndexOf(temp.id));
      }
    }
  }

  /*adds all cards into the players card pool (representation in the model) matching
  * neutral or players faction and are lower or equal than the players current level*/
  _filterFactionAndLevel(List<String> tempIDs, CardData kartendaten, FACTION playerFaction){
    tempIDs.forEach((String s){
      Card k = kartendaten.cloneID(s);
      if(k.faction == FACTION.NEUTRAL && k.level <= getPlayer().level){
        getPlayer().cardSelection.add(k);
      }
      if(k.faction == playerFaction && k.level <= getPlayer().level){
        getPlayer().cardSelection.add(k);
      }
    });
  }



  //*************//
  //View Elements//
  //*************//

  /*generating view elements for cards in players deck
  * as well as the available cards display*/
  List<TableCellElement> tceCardsSelection(){
    return _tceForRow(getReCardsSelection(), getReCardsSelected(),
                      getCardsSelection(),   getCardsSelected());}
  List<TableCellElement> tceCardsSelected(){
    return  _tceForRow(getReCardsSelected(), getReCardsSelection(),
                       getCardsSelected(),   getCardsSelection());}
  /*switches a card from the deck to the pool by removing
  * the table cell element from the pool or the deck and adding it to
  * the opposite card display. is also removing and adding the card
  * object in the model representation of the views deck and pool
  * card display*/
  List<TableCellElement> _tceForRow(
      List<TableCellElement> removeFromRe, List<TableCellElement> addToRe,
      List<Card>          removeFromCards, List<Card>          addToCards){
    List<TableCellElement> reflux = new List<TableCellElement>();
    TableCellElement tce;

    removeFromCards.forEach((Card k){
      bool clicked;
      tce = k.basicCellElement();

      tce.onMouseDown.listen((Event e){
        clicked = true;
        new Timer(new Duration(milliseconds: mc.settings.get('playCardCancelDelay')),(){
          clicked = false;
        });
      });
      tce.onMouseUp.listen((Event e){
        if(clicked){
          addToRe.add(tce);
          removeFromRe.remove(tce);
          removeFromCards.remove(k);
          addToCards.add(k);
          updateDeckCount();
          view.update();
        }
      });
      _tceIDs.putIfAbsent(tce, () => k.id);
      _cardCache.putIfAbsent(tce, () => k);
      reflux.add(tce);
    });
    return reflux;
  }

  /*creating various button elements for selecting the faction,
  * deleting current deck, starting game or displaying the
  * help table as well es returning from the help table back
  * to the deck selection*/
  ButtonElement beFaction([String s])   {return _buttons.beFaction(s);}
  ButtonElement beDeleteDeck([String s]){return _buttons.beDeleteDeck(s);}
  ButtonElement beStartGame([String s]) {return _buttons.beStartGame(s);}
  ButtonElement beHelp([String s])      {return _buttons.beHelp(s);}
  ButtonElement beBack([String s])      {return _buttons.beBack(s);}



  //****//
  //Misc//
  //****//

  /*updates the number-of-cards-in-deck view element with the current
  * number of cards in deck.
  * reads the min. number of cards from the settings helper class*/
  void updateDeckCount(){
    //view.myTable.rows[4].innerHtml = 'Deck: '  + getPlayer().deck.length.toString() + '/' + mc.settings.get('pgc_deckSizeMin');
    view.myTable.rows[4].innerHtml = 'Deck: '  + getPlayer().deck.length.toString() + '/' + 22.toString();
  }

  /*clears the id cache for all table cell elements representing a card.
  * invoking a clear of the card/card-id(string) cache*/
  void clearTceIDs(){
    _tceIDs.clear();
    _clearCardCache();
  }

  /*clears the id cache for all div elements representing a card*/
  void clearDivIDs(){
    _divIDs.clear();
    _clearCardCache();
  }

  /*clears the card/card-id(string) card cache*/
  void _clearCardCache(){
    _cardCache.clear();
  }



  //******//
  //Getter//
  //******//
  List<Card> getPool()                        {return mc.getPlayerCardPool();}
  String  getPlayerName()                     {return mc.getPlayerName();}
  String  getPlayerLevel()                    {return mc.getPlayer().level.toString();}
  Player getPlayer()                          {return mc.getPlayer();}
  AI      getAI()                             {return mc.getGame().ai;}
  Game   getGame()                           {return mc.getGame();}
  String  getCardClass(String prefix, TableCellElement tce)
                                              {return prefix + _tceIDs[tce];}
  String  getDivClass(String prefix, DivElement div)
                                              {return prefix + _divIDs[div];}
  Card    getCard(Element e)                  {return _cardCache[e];}
  List<Card> getCardsSelection()              {return getPlayer().cardSelection;}
  List<Card> getCardsSelected()               {return getPlayer().deck;}
  List<TableCellElement> getReCardsSelection(){return view.reCardSelection.children;}
  List<TableCellElement> getReCardsSelected() {return view.reDeck.children;}
}
