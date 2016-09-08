part of spacepeons;


const gamekeySettings = 'gamekey.json';


const secret = 'bdc8ebdd4f394719';

const frameTimer = const Duration(milliseconds: 40);
const fadeTimer = const Duration(milliseconds: 20);
const gameKeyTimer = const Duration(seconds: 30);

class SpacePeonsController {

  bool _ignoreInput;

  SpacePeonsView _view;
  SpacePeonsGame _game;
  GameKey _gamekey;

/**
 * Constructor
 * Gibt allen Buttons einen onClick-Listener
 * Initialisiert den View, den Gamekey und faded das Startmenü ein
 */
  SpacePeonsController() {
    querySelector("#start").onClick.listen(startGame);
    querySelector("#playmode").onClick.listen(changePlaymode);
    querySelector("#difficulty").onClick.listen(changeDifficult);
    querySelector("#highscorebutton").onClick.listen(showHighscore);
    querySelector("#confirm").onClick.listen(setHighscore);
    querySelector("#cancelGameOver").onClick.listen(reloadWindow);
    querySelector("#cancelHighscore").onClick.listen(reloadWindow);


    _ignoreInput = false;
    _view = new SpacePeonsView();
    _game = new SpacePeonsGame();
    initGameKey(gamekeySettings);
    new Timer.periodic(fadeTimer, _view.fadeInStart);
  }

  /**
   * Methode die mit dem Klick auf den Startbutton aufgerufen wird
   * initialisiert die Eingabemethoden und das GameObjekt
   * lädt je nach Spielmodi und Schwierigkeitsgrad die entsprechenden Gameeinstellungen
   * lässt das spielfeld aufbauen und startet den Timer, welcher die Framerate angibt
   */
  startGame(Event e) async {
    querySelector("#left").onClick.listen(mobile_left);
    querySelector("#right").onClick.listen(mobile_right);
    querySelector("#fire").onClick.listen(mobile_fire);
    window.onKeyDown.listen(input);

    if(querySelector("#difficulty").innerHtml == "Leicht") await _game.LoadConfig("gameconfigeasy.json");
    if(querySelector("#difficulty").innerHtml == "Mittel") await _game.LoadConfig("gameconfigmedium.json");
    if(querySelector("#difficulty").innerHtml == "Schwer") await _game.LoadConfig("gameconfighard.json");

    if (querySelector("#playmode").innerHtml == "Endless") {
        await _game.startGame("endlesslevel1.json");
      }
      else {
        await _game.startGame("arcadelevel1.json");
      }

      _view.buildField(_game.col, _game.row);
      new Timer.periodic(frameTimer, updateFrame);

      try {
        new Timer.periodic(gameKeyTimer, (_) async {
          if (await this._gamekey.authenticate()) {
            _view.updateStatus("");
          } else {
            _view.updateStatus("Gamekey-Service offline, keine Highscores verfügbar");
          }
        });
      }
      catch (error, stacktrace) {
        print("Controller caused error $error");
        print("$stacktrace");
        _view.updateStatus("Gamekey-Settings konnten nicht geladen werden, keine Highscores verfügbar");
      }
  }

  /**
   * Die Hauptmethode, sie wird vom Timer getriggert und stößt
   * je nach Gamestate die Berechnungen und das Update des Views an.
   */
  updateFrame(Timer e) async{
    _game.updateFrame();
    if(_game.running){
      updateView();
      _ignoreInput = false;
    }
    if(_game.levelWon){
      _game.NextLevel();
      _view.buildField(_game.col, _game.row);
    }
    if(_game.pause);
    if(_game.gameOver){
      _view.gameOver(_game.punkte);
    }
    if(_game.gameWon){
      _view.gameWon(_game.punkte);
    }

  }

  /**
   * Lade Settings fuer gamekey
   */
  initGameKey(String path) async{
    var request;
    try {
      request = await HttpRequest.getString(path);
    } catch (e) {
      print('Couldn\'t open $path');
    }
    final settings = JSON.decode(request);
    _gamekey = new GameKey(settings['gameid'], new Uri.http("${settings['host']}:${settings['port']}", "/"), secret);
    if(!await this._gamekey.authenticate())
      _view.updateStatus("Gamekey-Service offline, keine Highscores verfügbar");
  }

  /**
   * Liefert eine Liste mit maximal 10 Highscores
   * Liste kann auch leer sein
   */
  Future<List<Map>> getHighscore() async {
    var scores = [];
    try {
      final states = await _gamekey.getStates();
      scores = states.map((entry) => {
        'name' : "${entry['username']}",
        'score' : entry['state']['points']
      }).toList();
      scores.sort((a, b) => b['score'] - a['score']);
    } catch (error, stacktrace) {
      print (error);
      print (stacktrace);
    }
  return scores.take(10);
  }

  /**
   * Diese Methode uebergibt die Liste mit Highscores an den SpacePeonsView
   */
  showHighscore(Event e) async {
    await this._gamekey.authenticate();
    final highscore = await getHighscore();
    _view.showHighscore(highscore);
  }

  /**
   * Diese Methode liest die Nutzereingaben zu Name und Passwort ein und traegt den Highscore ein.
   * Existiert der User noch nicht, wird er registriert
   */
  setHighscore(Event e) async {
    String name = (querySelector('#name') as InputElement).value;
    String pw = (querySelector('#pw') as InputElement).value;
    String id = await _gamekey.getUserId(name);
    if(id == null){
      final usr = await _gamekey.registerUser(name, pw);
      if(usr != null)
      {
        _view.updateStatus("User $name wurde angelegt");
        await _gamekey.storeState(usr['id'], {
          'version': '1.0',
          'points': _game.punkte
        });
        final highscore = await getHighscore();
        _view.showHighscore(highscore);
      }

      else
        _view.updateStatus("User konnte nicht angelegt werden");
    }
    else{
      final usr = await _gamekey.getUser(id, pw);

      if(usr == null)
      {
        _view.updateStatus("Falsches Passwort fuer User '$name'");
      }
      else
      {
        await _gamekey.storeState(usr['id'], {
          'version': '1.0',
          'points': _game.punkte
        });
        _view.updateStatus("Highscore wurde eingetragen");
        final highscore = await getHighscore();
        _view.showHighscore(highscore);
      }

    }

  }

  /**
   * Restarte das Spiel
   */
  void reloadWindow(Event e){
    window.location.reload();
  }

  /**
   * Änderung des Spielmodi, da später auf den String der innerHtml geprüft wird,
   * ist keine Variable nötig
   */
  void changePlaymode(Event e){
    _view.changePlaymode();
  }

  /**
   * Änderung der Spielschwere, da später auf den String der innerHtml geprüft wird,
   * ist keine Variable nötig
   */
  void changeDifficult(Event e){
    _view.changeDifficult();
  }

  /**
   * Diese Methode setzt alle Guiparameter hinter das Spielfeldarray
   */
  updateView(){
    _view.updateView(_game.calcField(), [_game.levelCounter + 1, _game.currentLvl, _game.punkte, _game.heroShip.healthPoints, HeroDMG]);
  }

  /**
   * Diese Methode pausiert das Spiel
   */
  void pause()
  {
    _game.gamestate = #notRunning;
    _view.pause();
  }

  /**
   * Diese Methode startet das Spiel nachdem es pausiert wurde
   */
  void unPause()
  {
    _game.gamestate = #running;
    _view.unpause();
  }

  /**
   * Diese Methode wird beim Drücken eines Knopfes aufgerufen und triggert die entprechenden Methoden im Model
   */
  void input(KeyboardEvent e) {
    if(_game.running){
      if(!_ignoreInput){
        _ignoreInput = true;
        if (e.keyCode == KeyCode.LEFT){
          _game.heroShip.move(-1);
          updateView();
        }
        if (e.keyCode == KeyCode.RIGHT){
          _game.heroShip.move(1);
          updateView();
        }
        if (e.keyCode == KeyCode.SPACE){
          _game.heroShip.shoot();
          updateView();
        }
        if (e.keyCode == KeyCode.ESC)
        {
          pause();
        }
      }
   }
    else if(_game.stopped)
    {
      if(e.keyCode == KeyCode.ESC)
      {
        unPause();
      }
    }
  }

  /**
   * Diese Methode wird beim drücken auf den linken Mobilebutton aufgerufen und triggert die entprechenden Methoden im Model
   */
  void mobile_left(Event e) {
        _game.heroShip.move(-1);
        updateView();
  }

  /**
   * Diese Methode wird beim drücken auf den rechten Mobilebutton aufgerufen und triggert die entprechenden Methoden im Model
   */
  void mobile_right(Event e) {
      _game.heroShip.move(1);
      updateView();
  }

  /**
   * Diese Methode wird beim drücken auf den zum schießen verantwortliche Mobilebutton aufgerufen und triggert die entprechenden Methoden im Model
   */
  void mobile_fire(Event e) {
      _game.heroShip.shoot();
      updateView();
  }
}

