import 'PreGameController.dart';
import 'GameController.dart';
import 'AfterGameController.dart';
import '../model/cards/Card.dart';
import '../model/Game.dart';
import '../model/static/Enum.dart';
import '../view/MasterView.dart';
import 'GamekeyConnection.dart';
import '../model/ai/AI.dart';
import 'dart:html';
import '../model/Player.dart';
import '../model/static/CardData.dart';
import 'dart:async';
import '../model/static/Settings.dart';
import 'buttonElements/MVButtons.dart';

/*main controller class. prepares the model for the game and enables the player
* to log in if a gamekey service is available or offline if somehow the gamekey
* is unreachable*/
class MasterController{
  /*reference to the helper class holding the settings read from
  * the preferences.json file*/
  Settings            settings;
  /*reference to the helper class providing buttons and their logic used by
  * the view class controlled by this controller class*/
  MVButtons           _buttons;
  /*reference to the controller of the pre game phase*/
  PreGameController   pgc;
  /*reference to the controller of the game phase*/
  GameController      gc;
  /*reference to the controller of the after game phase*/
  AfterGameController agc;
  /*reference to the view class controlled by this controller class*/
  MasterView          view;
  /*reference to the class providing connection with a gamekey service*/
  GamekeyConnection   gamekey;
  /*reference to the class representing the games state*/
  Game                _game;
  /*providing information wether the gamekey service is available or not*/
  bool                gamekeyAvailable;

  MasterController(Settings settings){
    this.settings = settings;
    _buttons = new MVButtons(this);
    pgc  = new PreGameController(this);
    gc   = new GameController(this);
    agc  = new AfterGameController(this);
    view = new MasterView(this);
  }

  /*updates the master controller
  * there are four game phases. each phase got its own controller except for
  * the login phase which is handled by this class.
  * on each update the view of the previous */
  Future update(GAMEPHASE phase, bool isKI) async{
      if(phase==GAMEPHASE.LOGIN){
        querySelector('#loadingGame').innerHtml = '';
        if(settings.get('gamekeyCutoff') == 0){
          await gamekeyCheck();
        }else{
          gamekeyAvailable = false;
        }
        _game.player = newPlayer();
        _game.player.pool.addAll(settings.get('mc_defaultDeckBlue'));
        _game.player.pool.addAll(settings.get('mc_defaultDeckRed'));
        getCardData().cloneFor(FACTION.NEUTRAL, true).forEach((Card k){
          if(k.level <= getPlayer().level){
            getPlayer().pool.add(k.id);
          }
        });
        view.update();
      }
      if(phase==GAMEPHASE.PREPAREDECK){
        print('masterController: update: phase: prepare deck');
        view.clear();
        agc.view.clear();
        pgc.update();
      }
      if(phase==GAMEPHASE.PLAY){
        print('masterController: phase: play');
        getPlayer().takeOwnershipOfCards();
        pgc.view.clear();
        gc.update(isKI);
      }
      if(phase==GAMEPHASE.DISPLAYRESULT){
        print('masterController: phase: display result');
        gc.view.clear();
        agc.update();
      }
    print('masterController updated!');
  }

  //****//
  //Misc//
  //****//
  /*let the AI do a turn*/
  void aiTurn(){
    if(getAIHandLength()>0){
      _game.ai.makeAMove(this);
    }
    if(getAIHandLength()<=0){
      _game.ai.hasFold = true;
    }
  }

  /*tries to load a player if gamekey is available and the password-length is > 0.
    does not check gamekey availability.
    if somehow the map returned by the gamekey is null,
    the controller will update back to login*/
  Future playerLoad() async {
    print('spieler laden...');
    setPlayerName(getUsername());
    print('pwLength: ' + getPwdLength().toString());
    if(getPwdLength()==0){
      view.update();
    }
    print('available gamekey: ' + gamekeyAvailable.toString());

    if(getPwdLength() > 0 && gamekeyAvailable){
      setPlayerPwd(getPassword());
      Map m = await gamekey.getUser(getPlayer().name, getPlayer().password);

      if(m==null){
        //window.alert('getting user state failed!');
        print('FATAL: Map returned by gamekey-service is null!');
        this.update(GAMEPHASE.LOGIN, false);
      }else{
        getPlayer().id = m['id'];
        List<Map> user = await gamekey.getState(getPlayer().id);

        print('_playerLoad got user: \n');
        print(user);
        if(!user.isEmpty && user[0].containsKey('state')){
          Map<String, dynamic> spielerZustand =  user[0]['state'];

          if(spielerZustand.containsKey('level')){
            getPlayer().level = int.parse(spielerZustand['level']);
          }else{print('level konnte nicht geladen werden!');
          }
          if(spielerZustand.containsKey('levelpunkte')){
            getPlayer().levelpoints = int.parse(spielerZustand['levelpunkte']);
          }else{print('levelpunkte konnte nicht geladen werden!');
          }
          if(spielerZustand.containsKey('deck')){
            getPlayer().deck = getCardData().cloneIDs(spielerZustand['deck']);
          }else{print('deck konnte nicht geladen werden!');
          }
          if(spielerZustand.containsKey('pool')){
            getPlayer().pool.clear();
            getPlayer().pool.addAll(spielerZustand['pool']);
          }else{print('pool konnte nicht geladen werden!');}

          print('Spieler Deck geladen:\n');
          getPlayer().deck.forEach((Card k) => print(k.id));
          print('pool geladen mit:\n');
          getPlayer().pool.forEach((String s) => print(s));
          print('Spieler geladen mit id: '+getPlayer().id);
        }//map contains state
        update(GAMEPHASE.PREPAREDECK, false);
      }//map was not null
    }//pwd length ok and gamekey available
  }

  /*trys to register a new player with the gamekey.
  * if somehow the map returned by the gamekey is
  * null, the controller updates back to login*/
  playerRegister() async{
    setPlayerName(getUsername());
    setPlayerPwd(getPassword());
    Map m = await gamekey.registerUser(getPlayer().name, getPlayer().password);

    if(m == null){
      window.alert('oops! unknown error registering user!');
      update(GAMEPHASE.LOGIN, false);
    }else{
      getPlayer().id = m['id'];
      print('Player created with id: '+getPlayer().id);
      update(GAMEPHASE.PREPAREDECK, false);
    }
  }

  /*resetting the AI by creating a new AI*/
  void resetAI()    {_game.ai = _newAI();}
  /*resetting the game by calling games reset method*/
  void resetGame()  {_game.reset();}
  /*resetting the players state by calling the players reset method*/
  void resetPlayer(){_game.player.reset();}
  /*clearing all rows of the field by calling the fields row clear method*/
  void clearReihen(){_game.field.rowsClearAll();}
  /*checking gamekey availability by calling the connection checking method
  * of the GamekeyConnection.dart class*/
  Future gamekeyCheck()async{gamekeyAvailable = await gamekey.checkConnection();}

  /*creates a new AI with default-settings from settings.
  * the optional parameter defines the faction of the new AI
  * */
  AI _newAI([FACTION f]){
    List<Card> aiDeck  = new List<Card>();
    if(f!=null){
      aiDeck = _game.cardData.cloneFor(f, true);
    }else{
      aiDeck = _game.cardData.cloneFor(FACTION.ROT, true);
    }
    AI ai  = new AI(
        settings.get('mc_newAILives'),
        settings.get('mc_newAILevel'),
        settings.get('mc_newAILevelPoints'),
        settings.get('mc_newAIAP'),
        settings.get('mc_newAIFaction'),
        _game.field,new List<Card>(), aiDeck, new List<Card>());
    print('Neue KI erzeugt mit Karten/Deck: ' + aiDeck.length.toString() + '/n');
    return ai;
  }

  /* Creates a new Player with default-settings from settings
   * the optional parameter defines the faction of the new player
   */
  Player newPlayer([FACTION f]){
    print('settings new player faction: '+ settings.get('mc_newPlayerFaction').toString());
    return f == null ?
    new Player(
        settings.get('mc_newPlayerLives'),
        settings.get('mc_newPlayerLevel'),
        settings.get('mc_newPlayerLevelPoints'),
        settings.get('mc_newPlayerAP'),
        settings.get('mc_newPlayerFaction'),
        _game.field, new List<Card>(), new List<Card>(), new List<Card>()):
    new Player(
        settings.get('mc_newPlayerLives'),
        settings.get('mc_newPlayerLevel'),
        settings.get('mc_newPlayerLevelPoints'),
        settings.get('mc_newPlayerAP'),
        f,
        _game.field, new List<Card>(), new List<Card>(), new List<Card>());
  }


  //*************//
  //HTML Elements//
  //*************//
  /*button element enabling the player to log in if username, password
  * and gamekey-connection are available.
  * @param s  optional name for the button*/
  ButtonElement beLogin([String s]){
    return _buttons.beLogin(s);
  }
  /*button element enabling the player to register his username/password
  * combination with the available gamekey-service
  * @param s  optional name for the button*/
  ButtonElement beRegister([String s]){
    return _buttons.beRegister(s);
  }
  /*button element enabling the player to play offline if a username
  * is provided
  * @param s  optinal name for this button*/
  ButtonElement bePlayOffline([String s]){
    return _buttons.bePlayOffline(s);
  }
  /*input element enabling the player to enter its username
  * @param s  optional placeholder for this element*/
  InputElement ieUsername([String s]){
    return _buttons.ieUsername(s);
  }
  /*input element enabling the player to enter its passowrd
  * @param s  optional placeholder for this element*/
  InputElement iePassword([String s]){
    return _buttons.iePassword(s);
  }


  //******//
  //Getter//
  //******//
  Game       getGame()            {return _game;}
  Player     getPlayer()          {return _game.player;}
  CardData   getCardData()        {return _game.cardData;}
  int        getAILive()          {return _game.ai.lives;}
  String     getUsername()        {return view.ieUsername.value;}
  String     getPassword()        {return view.iePassword == null ? "" : view.iePassword.value;}
  List<Card> getPlayerDeck()      {return _game.player.getDeck();}
  int        getPlayerLive()      {return _game.player.lives;}
  String     getPlayerName()      {return _game.player.name;}
  FACTION    getPlayerFaction()   {return _game.player.getFaction();}
  int        getPlayerLevel()     {return _game.player.level;}
  int        getAIHandLength()    {return _game.ai.hand.length;}
  List<Card> getPlayerCardPool()  {return _game.player.cardSelection;}
  int        getPwdLength()       {return view.iePassword == null ? 0 : view.iePassword.value.length;}
  int        getPlayerHandLength(){return _game.player.hand.length;}


  //******//
  //Setter//
  //******//
  void setPlayerFold  (bool b)  {_game.player.hasFold = b;}
  void setPlayerAP    (int i)   {_game.player.summedAP = i;}
  void setPlayerLive  (int i)   {_game.player.lives += i;}
  void setAIFold      (bool b)  {_game.ai.hasFold = b;}
  void setAIAP        (int i)   {_game.ai.summedAP = i;}
  void setAILive      (int i)   {_game.ai.lives += i;}
  void playerAddToDeck(Card k)  {_game.player.getDeck().add(k);}
  void setGame        (Game s)  {_game = s;}
  void setPlayerPwd   (String s){_game.player.password = s;}
  void setPlayerName  (String s){_game.player.name = s;}
}