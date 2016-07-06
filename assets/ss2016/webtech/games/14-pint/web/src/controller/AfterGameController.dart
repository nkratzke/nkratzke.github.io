import '../view/AfterGameView.dart';
import '../model/static/Enum.dart';
import 'MasterController.dart';
import 'dart:html';
import '../model/cards/Card.dart';
import '../model/cards/Hero.dart';
import '../model/Player.dart';
import '../model/Game.dart';
import '../model/static/CardData.dart';
import '../controller/GamekeyConnection.dart';
import 'buttonElements/AGVButtons.dart';
import 'dart:math';

class AfterGameController{
  /*reference to the view class controlled by this controller class*/
  AfterGameView     view;
  /*reference to the master controller controlling this class*/
  MasterController  mc;
  /*reference to the helper class generating button elements including
  * their logic for the view*/
  AGVButtons        _buttons;
  /*list of cards won by the player either defined by the corresponding list
  * of cards a player can win for a specific level or by random selection
  * of suitable, non-hero, non-weather cards*/
  List<Card>        wonCards;

  AfterGameController(MasterController masterController){
    this.mc  = masterController;
    _buttons = new AGVButtons(this);
    view     = new AfterGameView(this);
    wonCards = new List<Card>();
  }

  /*updates after game state*/
  update()async{
    _playerLevel();
    view.update();
    _playerReset();
    await _playerSafe();
    print('controller updated!');
  }

  /*clears after game view*/
  void clearView(){
    view.clear();
  }

  /*resets datastructures*/
  void reset(){
    wonCards.clear();
  }

  /*after game activity. handles leveling up the player if the levelup-threshold
  * is reached and giving a random card to the player (no hero cards) for each
  * level not specified in the preferences. otherwise adding the cards specified
  * in the list of card ids for the corresponding level.
  * alerts if a player leveld up and is resetting players levelpoints in case
  * of a levelup*/
  void _playerLevel(){
    Map _levelupBonuscards = mc.settings.get('agc_levelupBonusCards');
    int levelAI     = getGame().ai.level,
        levelPlayer = getPlayer().level,
        levelup     = mc.settings.get('agc_levelupThreshold'),
        bonusMin    = mc.settings.get('agc_levelupBonusMin'),
        bonusDef    = mc.settings.get('agc_levelupDef'),
        bonusMax    = mc.settings.get('agc_levelupBonusMax');

    if(levelAI < levelPlayer) {getPlayer().levelpoints += bonusMin;}
    if(levelAI == levelPlayer){getPlayer().levelpoints += bonusDef;}
    if(levelAI > levelPlayer) {getPlayer().levelpoints += bonusMax;}
    if(getPlayer().levelpoints >= levelup){
      print('levelup!');
      getPlayer().increaseLevel();
      getPlayer().levelpoints = 0;
      _levelupBonuscards.keys.forEach((String s){
        if('lvl'+playerLevel() == s){
          getPlayer().pool.addAll(_levelupBonuscards[s]);
          wonCards.addAll(getCardData().cloneIDs(_levelupBonuscards[s]));
        }
      });
      print('agc: playerLevelup');
      window.alert('Levelup!');
    }
     if(wonCards.isEmpty){
       wonCards.addAll(_randomCardsFor(getPlayer(), 1));
     }
    wonCards.forEach((Card c) => print('agc: _playerLevel: wonCards: ' + c.debugInfo()));
  }

  /*invokes players reset method*/
  _playerReset(){
    getPlayer().reset();
  }

  /*saves player state in gamekey providing gamekey is up*/
  _playerSafe()async{
    if(await getGamekey().checkConnection()){
      Map<String, dynamic> state  = new Map<String, String>();
      List<String>          deck  = new List<String>();
      List<String>          pool  = new List<String>();

      deck.addAll(getCardData().getIDs(getPlayer().deck));
      pool.addAll(getPlayer().pool);

      print('player safe deck length: ' + getPlayer().deck.length.toString());

      state.putIfAbsent('deck',       () => deck);
      state.putIfAbsent('pool',       () => pool);
      state.putIfAbsent('level',      () => playerLevel());
      state.putIfAbsent('levelpunkte',() => playerLevelpoints());

      getGamekey().storeState(getPlayer().id, state);
      print('STATE GESPEICHERT FÜR '+getPlayer().name);
    }else{
      print('WARNING: agc: gamekeyTimeout');
    }
  }

  /*Selects n suitable bonus cards for the player, excluding heroe.
  * For persistence (requires available gamekey) card-ids
  * are added to the players card pool*/
  List<Card> _randomCardsFor(Player s, int cardCount){
    List<Card> meta   = new List<Card>();
    List<Card> reflux = new List<Card>();
    Random rand       = new Random();
    int cardCounter   = 0,
        playerLevel   = getPlayer().level;
    FACTION  playerFaction   = getPlayer().getFaction(),
                neutralFaction  = FACTION.NEUTRAL;

    getCardData().cloneAll().forEach((Card c){
      bool  levelOk    = c.level <= playerLevel,
            isNoHero   = !(c is Hero),
            factionFit = c.faction == neutralFaction || c.faction == playerFaction,
            weather    =  c.effects.isNotEmpty //weather cards are hero cards. so we need to override the isNoHero bool
                      && (c.effects[0] == EFFECTS.WEATHER || c.effects[0] == EFFECTS.GOODWEATHER);
      if( (levelOk && isNoHero && factionFit) || weather){
        meta.add(c);
      }
    });
    meta.forEach((Card c) => print('agc: meta contains: ' + c.id));
    while(cardCounter<cardCount){
      reflux.add(meta.removeAt(rand.nextInt(meta.length)));
      cardCounter++;
    }
    reflux.forEach((Card c) => s.pool.add(c.id));
    reflux.forEach((Card c) => print('agc: randomCard for Player: ' + c.id));

    return reflux;
  }

  /*Returns a String representing each rounds result*/
  String calculateWinner(){
    return  playerLivesLeft()    ? 'Spieler hat gewonnen mit: <br>'  + resultString() :
            aiLivesLeft()         ? 'KI hat gewonnen mit: <br>'       + resultString() :
            (!playerLivesLeft()
             && !aiLivesLeft())   ? 'Unentschieden mit: <br>'         + resultString() :
                                      'ERGEBNIS UNBEKANNT!';
  }

  /*Clears available data structures preparing for a new game*/
  void restart(){
    clearView();
    wonCards.clear();
    mc.resetAI();
    mc.resetGame();
    mc.update(GAMEPHASE.PREPAREDECK, false);
  }

  /*returns a button enabling the player to restart the game*/
  ButtonElement beNeustart(){
    return _buttons.beNeustart();
  }

  /*prepares the string representing each rounds summed up AP for player/ai*/
  String resultString(){
    String reflux = '';
    print('Results length: ' + roundsPlayed().toString());
    for(int i=0; i<roundsPlayed(); i+=2){
      reflux += resultAt(i).toString() + '/' + resultAt(i+1).toString() + '<br>';
    }
    return reflux;
  }


  //******//
  //Getter//
  //******//
  GamekeyConnection getGamekey() {return mc.gamekey;}
  int    resultAt(int index)     {return mc.getGame().results[index];}
  List<Card> getPlayerDeck()     {return mc.getPlayer().deck;}
  String playerLevelpoints()     {return mc.getPlayer().levelpoints.toString();}
  CardData getCardData()         {return mc.getGame().cardData;}
  bool playerLivesLeft()         {return mc.getPlayerLive() == 0 ? false : true;}
  int    roundsPlayed()          {return mc.getGame().results.length;}
  String playerLevel()           {return mc.getPlayer().level.toString();}
  int getPlayerLevel()           {return mc.getPlayer().level;}
  Player getPlayer()             {return mc.getPlayer();}
  bool aiLivesLeft()             {return mc.getAILive() == 0 ? false : true;}
  Game  getGame()                {return mc.getGame();}
}