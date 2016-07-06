import 'dart:async';
import 'dart:html';
import '../Model/GameTable.dart';
import '../View/View.dart';
import '../Model/Types/Direction.dart';
import '../Debug.dart';
import '../GameKey/GameKey.dart';

const tickTime = const Duration(milliseconds: 10);
const updateView = const Duration(milliseconds: 33);
const durationGameKey = const Duration(milliseconds: 1000);

class Controller {
  GameTable game;
  View view;
  bool gameOver = false;
  bool pause = false;
  bool newGame;
  int pacDirection;

  GameKey gameKey;

  Timer ticker;
  Timer updater;
  Timer gameKeyTrigger;

  Map mapData;
  Map parameters;

  /**
   * Constructor
   */
  Controller(this.gameKey, this.newGame,this.mapData,this.parameters) {
    startController();
  }

  /**
   * Starts the controller and initialize the keylisteners, the timers and the connection test to the GameKey server
   */
  Future startController() async{
    var bt_pause = querySelector('#pauseButton');
    var map = null;
    if(!newGame) map = await this.getGame();

    game = new GameTable(map,this.mapData,this.parameters);
    view = new View(game.field);

    ticker = new Timer.periodic(tickTime, (_) => _onTick());
    updater = new Timer.periodic(updateView, (_) => _updateView());
    if(gameKey.offline == false){
      gameKeyTrigger = new Timer.periodic(durationGameKey, (_) => _triggerGameKey());
    }

    view.createGameField(game.field);

    window.onKeyDown.listen((KeyboardEvent ev) {
      if (gameOver) return;
      switch (ev.keyCode) {
        case KeyCode.LEFT:
          game.nomNom.desiredDirection = Direction.LEFT;
          break;
        case KeyCode.RIGHT:
          game.nomNom.desiredDirection = Direction.RIGHT;
          break;
        case KeyCode.UP:
          game.nomNom.desiredDirection = Direction.UP;
          break;
        case KeyCode.DOWN:
          game.nomNom.desiredDirection = Direction.DOWN;
          break;
      }
    });

    querySelector("#rightButton").onClick.listen((MouseEvent mv) {
      if (gameOver) return;
      game.nomNom.desiredDirection = Direction.RIGHT;
    });

    querySelector("#leftButton").onClick.listen((MouseEvent mv) {
      if (gameOver) return;
      game.nomNom.desiredDirection = Direction.LEFT;
    });

    querySelector("#upButton").onClick.listen((MouseEvent mv) {
      if (gameOver) return;
      game.nomNom.desiredDirection = Direction.UP;
    });

    querySelector("#downButton").onClick.listen((MouseEvent mv) {
      if (gameOver) return;
      game.nomNom.desiredDirection = Direction.DOWN;
    });



    bt_pause.onClick.listen((Event ev){
      Debug.print("MouseDownPause");
      if(pause == false) {
        pause = true;
        bt_pause.value = "Start";
        if(gameKey.offline == false) {
          querySelector("#welcome").appendHtml("<input id=\"saveButton\" type=\"button\" value=\"Save\">");
          querySelector("#saveButton").onClick.listen((MouseEvent mv) {
            this.saveState();
          });
        }
      }else{
        pause = false;
        bt_pause.value = "Pause";
        if(gameKey.offline == false){
          querySelector("#saveButton").remove();
        }
      }
    });
  }

  /**
   * Restore the saved game from the GameKey server for a registred user
   */
  Future<Map> getGame() async{
    if(gameKey.offline == false){
      print("Lets get the game");
      var gamestates = await gameKey.getStates();
      var state = null;
      for(var gamestate in gamestates){
        if(gamestate["userid"] == gameKey.userid){
          state = gamestate;
          break;
        }
      }
      if(state != null)
        return state["state"];

    }
    return null;
  }

  /**
   * This stops the game and set the Last updates
   */
  Future _gameOver()async {
    ticker.cancel();
    updater.cancel();
    if(gameKey.offline == false) gameKeyTrigger.cancel();
    view.reachedLevelEnd(game.field,game.nomNom, gameOver);

    if(gameOver){
      if(await gameKey.authenticate() == true){
        this.saveState();
      }
      return;
    }else{
      querySelector("#levelupButton").onMouseDown.listen((MouseEvent ev){
        this.nextLevel();
      });
    }
  }

  /**
   * Ticks nomNom, the ghosts and events to give them a time for interaction
   * stops when the game is over or pause the game
   */
  void _onTick() {
    if(!pause) {
      if (gameOver) {
        _gameOver();
        return;
      };
      game.onTick();
    }
  }


  /**
   * Test if the Gamekey connenction is online
   */
  Future _triggerGameKey()async {
    if(await this.gameKey.authenticate()){
      querySelector("#onoff").setInnerHtml("<span>ONLINE</span>");
    }else{
      querySelector("#onoff").setInnerHtml("<span>OFFLINE</span>");
    }
  }

  /**
   * Updates the Field and the Stats and test if game over
   */
  void _updateView() {
    if (game.coins <= 0 || game.gameOver){
      gameOver = game.gameOver;
      this._gameOver();
    }  else{
      view.updateGameField(game.field);
      view.updateStats(game.nomNom);
    }
  }

  /**
   * Store the state to the GameKey server if it is online
   */
  Future saveState() async{
    Map mscore = {
      "points" : game.nomNom.points,
      "level" : game.nomNom.level,
      "life": game.nomNom.life
    };
    if(await gameKey.storeState(gameKey.userid,mscore)){
      if(!gameOver)window.alert("Game saved");
      print(mscore);
    }else
        if(!gameOver)window.alert("Couldn't save the Game");
  }


  /**
    Sets the Next Level
   */
  void nextLevel(){
    game.nomNom.levelUp();
    try{
      game.generateGameTable();
      view.createGameField(game.field);
      this._updateView();

      ticker = new Timer.periodic(tickTime, (_) => _onTick());
      updater = new Timer.periodic(updateView, (_) => _updateView());
    }catch(e){
      querySelector("#leveledUp").innerHtml="Congratulation, you reached the end of the game";
      querySelector("#levelupButton").remove();
    }

  }
}
