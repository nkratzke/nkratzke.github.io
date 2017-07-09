import '../Model/Game.dart';
import '../View/View.dart';
import 'dart:html';
import 'dart:async';
import 'dart:convert';

/*
 Zwei globale Variablen, worin die Tickrate gespeichert wird sowohl auch die Tickrate in der sich der Spieler bewegt.
 */
var tickRate;
var updatePlayerTickRate;

class Controller{
  // Das Game Model
  Game _game;
  // Die View
  View _view;
  // Timer für die intervals
  Timer _tick;
  // Timer für die Geschwindigkeit des Players
  Timer _updatePlayerTick;
  // Boolean ob das game pausiert ist
  bool _paused = false;
  // Boolean um zu warten bis level zuende ist
  bool waitForEndLevel = false;
  // JSON/Map für die optionen
  Map _options;
  // JSON/Map für die Levels
  Map _levels;

  // Intervall wann der Schuss des Spielers bewegt werden soll
  int _playerMoveShot;
  // Intervall wann für den Spieler ein Schuss erstellt werden soll
  int _playerCreateShot;
  // Intervall wann der Schuss des gegners bewegt werden soll
  int _enemyMoveShot;
  // Intervall wann ein Schuss des gegners erstellt werden soll
  int _enemyCreateShot;
  // Intervall wann die Gegner sich um eins bewegen
  int _enemyMove;
  // Intervall wann ein Gegner erstellt werden soll
  int _enemyCreate;

  // Der intervall der hoch gezählt wird
  int _intervall = 1;

/*
Der Constructor erstellt das Game und die View.
 */
  Controller(){
    HttpRequest.getString("options.json").then((JSONfile){
      var inputJSON = JSON.decode(JSONfile);
      print(inputJSON);
      _options = inputJSON['options'];
      _levels = inputJSON['levels'];
      _game = new Game(_options, _levels);
      _view = new View(_game);
      configureListener();
      tickRate = new Duration(milliseconds: _options['tickRate']);
      updatePlayerTickRate = new Duration(milliseconds: _options['updatePlayerTickRate']);
    });
  }

/*
loadLevel lädt die neuen Intervalle von dem neuen Level in die Variablen.
 */
  void loadLevel(){
    _playerMoveShot = _levels[_game.level-1]['playerMoveShot'];
    _playerCreateShot = _levels[_game.level-1]['playerCreateShot'];
    _enemyMoveShot = _levels[_game.level-1]['enemyMoveShot'];
    _enemyCreateShot = _levels[_game.level-1]['enemyCreateShot'];
    _enemyMove = _levels[_game.level-1]['enemyMove'];
    _enemyCreate = _levels[_game.level-1]['enemyCreate'];
  }
/*
Diese Funktion beendet die Timer und updated die View zum Gameover
 */
  void cancelGame(){
    _tick.cancel();
    _updatePlayerTick.cancel();
    _view.updateGameStatus();
  }

  /*
  Pausiert das spiel und updated die View zum Pause-Screen
   */
  void pauseGame(){
    _paused = true;
    _view.updatePauseGame();
    _updatePlayerTick.cancel();
  }

  /*
  Diese Funktion triggert von dem Timer.
  Sie checkt zuerst ob das Fenster des Spiels inaktiv ist und ob es kein Smartphone Format ist.
  Das Spiel wird dann pausiert. Andernfalls läuft das Spiel weiter.
  In jedem bestimmten Intervall, dass in dem Level festgelegt ist, werden die Methoden in der Game aufgerufen und die View dann geupdatet.
  Beim durchlaufen der Zeit wird jedoch gewartet bis alle Objekte aus den Listen in der Game leer sind, um einen besseren Übergang zu gestalten.
  Zum Schluss wird der Intervall inkrementiert.
   */
  void updateGame() {
    if (querySelector("#gameField").clientWidth > querySelector("#gameField").clientHeight || document.visibilityState == "hidden"){
      pauseGame();
      return;
    }
    if (_paused){
      startTick();
      _paused = false;
      _view.updateUnpauseGame();
    }
    if (_game.player.life < 1){
      cancelGame();
      return;
    }
    if (waitForEndLevel == true){
      if (_game.allListEmpty()){
        _intervall = 1;
        _game.incLevel();
        loadLevel();
        waitForEndLevel = false;
        _view.updateLevel();
        _view.updateTimeleft();
        _view.updateLegend();
      }
    } else if (_intervall % (_levels[_game.level-1]['time'] * 1000 / _options["tickRate"]) == 0){
      if (_game.level >= _levels.length){
        cancelGame();
        return;
      }
      waitForEndLevel = true;
      return;
    }

    if(_intervall % _playerCreateShot == 0) {
      _game.playerCreateShot();
      _view.updatePlayerShot();
    }

    if(_intervall % _playerMoveShot == 0) {
      _game.playerMoveShot();
      _view.updatePlayerShot();
      _view.updateLegend();
      _view.updateAsteroids();
      _view.updateEnemysShuttle();
    }

    if(_intervall % _enemyCreateShot == 0) {
      _game.enemyCreateShot();
      _view.updateEnemyShot();
    }

    if(_intervall % _enemyMoveShot == 0) {
      _game.enemyMoveShot();
      _view.updateEnemyShot();
      _view.updateLegend();
    }
    if (waitForEndLevel != true){
      if(_intervall % _enemyCreate == 0) {
        _game.enemyCreate();
        _view.updateEnemysShuttle();
        _view.updateAsteroids();
      }
    }


    if(_intervall % _enemyMove == 0) {
      _game.enemyMove();
      _view.updateAsteroids();
      _view.updateEnemysShuttle();
      _view.updateLegend();
      _game.itemMove();
      _view.updateItem();
    }
    _view.updateEnemyShot();
    _intervall++;

  }

  /*
  Diese Funktion startet die Timer falls sie noch nicht laufen.
   */
  void startTick(){
    if (_tick == null || !_tick.isActive){
      _tick = new Timer.periodic(tickRate, (_) => updateGame());
    }
    if (_updatePlayerTick == null || !_updatePlayerTick.isActive){
      _updatePlayerTick = new Timer.periodic(updatePlayerTickRate, (_) => updatePlayerMove());
    }
  }

  /*
  Diese Funktion setzt einen Listener auf alle Buttons, um so durch das Menü zu navigieren.
   */

  void configureListener() {
    querySelector(".open_game").onClick.listen((MouseEvent e) => configureGameButton());
    querySelectorAll(".zurück_button").onClick.listen((MouseEvent e) => _view.updateMenu());
    querySelector(".open_howto").onClick.listen((MouseEvent e) => _view.updateHowto());
    querySelector(".open_about").onClick.listen((MouseEvent e) => _view.updateAbout());
  }

  /*
  Diese Funktion wird getriggert, sobald der Button zum starten des Spiels gedrückt wurde.
  Es ruft die Methoden auf um das Level zu laden, neues Spiel zu erstellen und die View upzudaten.
  Außerdem wird der Listener gesetzt um den Spieler zu positionieren.
   */
  void configureGameButton(){
    if (_options != null){
      _game = new Game(_options, _levels);
      _view = new View(_game);
      _view.updateGameField();
      _intervall = 1;
      loadLevel();
      _view.createGamefield();
      startTick();
      /*
        Listener für die Spieler Steuerung
       */
      Element gameFieldDiv = querySelector("#gameField");
      gameFieldDiv.onMouseMove.listen((ev) {
        _game.player.setXTarget(((_game.gameFieldXLength / gameFieldDiv.clientWidth)* ev.client.x).toInt());
      });
    }
  }

  /*
  Diese Funktion wird getriggert von dem Spieler positions timer, sodass ein Spieler nicht komplett
  von einer Position zu der anderen positioniert wird, sondern durch jedes Raster einmal durch muss,
  dass dazwischen liegt.
   */
  void updatePlayerMove() {
    _game.playerMove();
    _view.updatePlayer();
  }

}