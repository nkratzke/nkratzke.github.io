import 'dart:math';
import 'Player.dart';
import 'Asteroid.dart';
import 'Shot.dart';
import 'EnemyShuttle.dart';
import 'Points.dart';
import 'LifeUpgrade.dart';
import 'Aimbot.dart';
import 'Item.dart';
import 'dart:async';



class Game{
  // Spielfeldgröße der X-Achse
  int _gameFieldXLength;
  int get gameFieldXLength => _gameFieldXLength;
  // Spielfeldgröße der Y-Achse
  int _gameFieldYLength;
  int get gameFieldYLength => _gameFieldYLength;
  // Variable zum checken ob item Aimbot aktiv ist für Bewegungen der Schüsse
  bool _aimbotactiv = false;
  // Akteuelles Level
  int _level;
  int get level => _level;
  // Aktuelle Punkteanzahl
  int _score;
  int get score => _score;
  // Der Spieler selber
  Player _player;
  Player get player => _player;
  // Ein Counter der Elemente um jedem Element eine eindeutige ID zuzuweisen.
  int _elementCounter;
  int get elementCounter => _elementCounter;
  // Liste mit allen Schüssen des Spielers
  List<Shot> _playerShots = new List<Shot>();
  List<Shot> get playerShots => _playerShots;
  // Liste mit allen gegnerischen Schiffe
  List<EnemyShuttle> _enemysShuttle = new List<EnemyShuttle>();
  List<EnemyShuttle> get enemysShuttle => _enemysShuttle;
  // Liste mit allen Asteroiden
  List<Asteroid> _asteroids = new List<Asteroid>();
  List<Asteroid> get asteroids => _asteroids;
  // Liste mit allen gegnerischen Schüssen
  List<Shot> _shots = new List<Shot>();
  List<Shot> get shots => _shots;
  // Liste mit allen Aimbot items
  List<Aimbot> _aimbots = new List<Aimbot>();
  List<Aimbot> get aimbots => _aimbots;
  // Liste mit allen Punkte items
  List<Points> _points = new List<Points>();
  List<Points> get points => _points;
  // Liste mit allen Leben items
  List<LifeUpgrade> _lifeupgrades = new List<LifeUpgrade>();
  List<LifeUpgrade> get lifeupgrades => _lifeupgrades;
  // JSON/Map mit den parametrisierten Optionen
  Map _options;
  Map get options => _options;
  // JSON/Map mit allen Levels
  Map _levels;
  Map get levels => _levels;


  Game(Map options, Map Levels) {
    _elementCounter = 0;
    this._options = options;
    this._levels = Levels;
    _gameFieldXLength = this._options["gameFieldXLength"];
    _gameFieldYLength = this._options["gameFieldYLength"];
    _score = 0;
    _player = new Player((_gameFieldXLength / 2).toInt(), 0, _options['startLife'],_elementCounter++);
    _level = 1;
  }


  /* Abfrage ob alle Listen für Controller für das neue Level leer sind */
  bool allListEmpty(){
    if (_asteroids.isEmpty && _enemysShuttle.isEmpty && _lifeupgrades.isEmpty && _points.isEmpty){
      return true;
    }
    return false;
  }


/*
Erhöhe das Level um 1
 */
  void incLevel(){
    this._level++;
  }

  /*
  Erhöhe den Score mit dem übergebenen Integer.
   */
  void incScore(int score){
    this._score += score;
  }


  /*************************************************/
  /* SHOTS */
  /*************************************************/

  /*
  Bewegt die gegnerischen Schüsse und überprüft anschließend, ob einen Kollision mit dem Spieler stattgefunden hat.
   */
  void enemyMoveShot() {
    _shots.removeWhere((shots) => shots.valid <= 0);
    for (var shot in _shots) {
      shot.setYPosition(shot.yPosition - 1);
    }
    shotCheckEnemysCollision();
  }

  /*
  Erzeugt einen gegnerischen Schuss.
   */
  void  enemyCreateShot(){
    for (var enemy in _enemysShuttle) {
      if (enemy.valid > 0){
        _shots.add(new Shot.enemy(enemy.xPosition, enemy.yPosition - 1, _elementCounter++));
      }
    }
  }

  /*
  Überprüft, ob ein gegnerischer Schuss den Spieler gettoffen hat.
  Wurde der Spieler getroffen, wird dem Spieler auch leben abgezogen.
   */
  void shotCheckEnemysCollision() {
    for (var shot in _shots) {
      if(shot.xPosition == _player.xPosition &&
          shot.yPosition == _player.yPosition && shot.valid > 0) {
        _player.decLife();
        shot.decValid();
      } else if (shot.yPosition <= 0){
        shot.decValid();
      }
    }
  }


  /*************************************************/
  /* ENEMYS */
  /*************************************************/


  /*
  Bewegt die Gegner(gegnerische Schiffe und Asteroide) und überprüft anschließend, ob einen Kollision mit dem Spieler stattgefunden hat.
   */

  void enemyMove(){
    for (var asteroid in _asteroids) {
      asteroid.setYPosition(asteroid.yPosition - 1);
    }
    for (var enemy in _enemysShuttle) {
      enemy.setYPosition(enemy.yPosition - 1);
    }
    _enemysShuttle.removeWhere((enemyShuttle) => enemyShuttle.valid <= 0);
    _asteroids.removeWhere((asteroid) => asteroid.valid <= 0);
    enemyCheckCollision();
  }

  /*
  Überprüft, ob ein Gegner (Schiff, Asteroid) mit dem Spieler Kollidiert.
  Hat eine Kollision stattgefunden, wir das Objekt zerstört und der Spieler verliert Leben.
   */
  void enemyCheckCollision() {
    for (var asteroid in _asteroids) {
      if (asteroid.xPosition == _player.xPosition &&
          asteroid.yPosition == _player.yPosition && asteroid.valid > 0) {
        _player.decLife();
        asteroid.decValid();
      }
      if (asteroid.yPosition <= 0){
        asteroid.decValid();
      }
    }
    for (var enemy in _enemysShuttle) {
      if(enemy.xPosition == _player.xPosition &&
          enemy.yPosition == _player.yPosition && enemy.valid > 0){
        _player.decLife();
        enemy.decValid();
      }
      if (enemy.yPosition <= 0){
        enemy.decValid();
      }
    }
    shotCheckEnemysCollision();
  }

  /*
  Erzeugt einen gegner.
   */
  void enemyCreate() {
    var random =  new Random();
    int ranNum = random.nextInt(100);
    if (ranNum <= _levels[_level-1]["asteroidSpawnChance"]){
      int ranX = random.nextInt(_gameFieldXLength);
      _asteroids.add(new Asteroid(ranX, _gameFieldYLength-1, 1,_elementCounter++, _levels[_level-1]["asteroidDestroyPoints"], 1));
    } else if (ranNum <= (_levels[_level-1]["asteroidSpawnChance"] + _levels[_level-1]["shuttleSpawnChance"]) && ranNum > _levels[_level-1]["asteroidSpawnChance"]){
      int ranX = random.nextInt(_gameFieldXLength);
      _enemysShuttle.add(new EnemyShuttle(ranX, _gameFieldYLength-1, 1,_elementCounter++, _levels[_level-1]["shuttleDestroyPoints"], 1));
    }
  }

  /*************************************************/
  /* PLAYER */
  /*************************************************/

  /*
  Bewegt das PlayerShuttle und überprüft, ob das Shuttle mit einem Gegner oder einem gegnerischen Schuss kollidiert.
   */
  void playerMove() {
    if(_player.xTarget != null) {
      if(_player.xPosition - _player.xTarget == 1 || _player.xPosition - _player.xTarget == -1) {
        _player.setXPosition(_player.xTarget);
      } else if (_player.xPosition != _player.xTarget) {
        if (_player.xPosition > _player.xTarget) {
          _player.setXPosition(_player.xPosition - 1);
        }
        else {
          _player.setXPosition(_player.xPosition + 1);
        }
      }
      enemyCheckCollision();
    }
  }

  /*
  Erzeugt Spieler Schuss.
   */
  void playerCreateShot() {
    _playerShots.add(new Shot.player(_player.xPosition, _player.yPosition+1, _elementCounter++, _aimbotactiv));
  }

  /*
  Bewegt den spielerischen Schuss und überprüft, ob der Schuss mit einem Gegner Kollidiert.
   */
  void playerMoveShot() {
    _playerShots.removeWhere((playerShots) => playerShots.valid <= 0);
    playerCheckShotCollision();
    int xAsteroid;
    int yAsteroid;
    int xShuttle;
    int yShuttle;
    Item minObject = null;
    for(var shot in _playerShots) {
      if(shot.isAimbot) {
        for(int i= 0; i < _asteroids.length; i++) {
          if (_asteroids[i].yPosition > shot.yPosition) {
            xAsteroid = _asteroids[i].xPosition;
            yAsteroid = _asteroids[i].yPosition;
            break;
          }
        }
        for(int i= 0; i < _enemysShuttle.length; i++) {
          if (_enemysShuttle[i].yPosition > shot.yPosition) {
            xShuttle = _enemysShuttle[i].xPosition;
            yShuttle = _enemysShuttle[i].yPosition;
            break;
          }
        }
        if (yAsteroid != null && yShuttle == null){
          moveShot(shot, xAsteroid);
        } else if (yAsteroid == null && yShuttle != null){
          moveShot(shot, xShuttle);
        } else if(yAsteroid != null && yShuttle != null && yAsteroid < yShuttle) {
          moveShot(shot, xAsteroid);
        } else if (yAsteroid != null && yShuttle != null && yAsteroid > yShuttle){
          moveShot(shot, xShuttle);
        }
      }
      shot.setYPosition(shot.yPosition + 1);
    }
    playerCheckShotCollision();
  }

  void moveShot(Shot shot, int xPos){
    if(shot.xPosition > xPos){
      shot.setXPosition(shot.xPosition - 1);
    } else if(shot.xPosition < xPos) {
      shot.setXPosition(shot.xPosition + 1);
    }
  }


/*
  Überprüft, ob die eigenen Schüsse einen Shuttle und/oder Asteroid treffen.
  Wurde ein Gegner getroffen, so wird die Score erhöht und das Shuttle und Asteroid zerstört.
  Außerdem wird ggf. ein Item erstellt, sobald ein Gegner Shuttle getroffen wurde.

 */
  void playerCheckShotCollision() {
    bool foundAlready;
    for(var shot in _playerShots) {
      foundAlready = false;
      if (shot.yPosition >= _gameFieldYLength-1){
        shot.decValid();
      }
      for(var enemy in _enemysShuttle) {
        if(shot.xPosition == enemy.xPosition && shot.yPosition == enemy.yPosition && enemy.valid > 0 && shot.valid > 0) {
          incScore(enemy.points);
          enemy.decValid();
          shot.decValid();
          itemCreate(enemy.xPosition, enemy.yPosition);
          foundAlready = true;
          break;
        }
      }
      if (foundAlready == false) {
        for (var asteroid in _asteroids) {
          if (shot.xPosition == asteroid.xPosition &&
              shot.yPosition == asteroid.yPosition &&
              asteroid.valid > 0 && shot.valid > 0 &&
              asteroid.yPosition > 0) {
            incScore(asteroid.points);
            asteroid.decValid();
            shot.decValid();
            itemCreate(asteroid.xPosition, asteroid.yPosition);
            break;
          }
        }
      }
    }

  }


  /*************************************************/
  /* ITEM */
  /*************************************************/
  /*

  Erstellt ein Item je nach der Prozentchance von dem Level.
   */
  void itemCreate(int x, int y) {
    var random =  new Random();
    int randomNum = random.nextInt(100);
    int pointsChance = _levels[_level-1]["itemPointChance"];
    int lifeChance = _levels[_level-1]["itemHealChance"];
    int aimbotChance = _levels[_level-1]["itemAimbotChance"];

    if (randomNum <= pointsChance){
      _points.add(new Points(x, y, _elementCounter++, 1, 1000));

    } else if (randomNum > pointsChance && randomNum <= (lifeChance + pointsChance)){
      _lifeupgrades.add(new LifeUpgrade(x, y, _elementCounter++, 1, 1));
    } else if(randomNum > pointsChance+ lifeChance && randomNum <= (lifeChance + pointsChance + aimbotChance)) {
      _aimbots.add(new Aimbot(x, y, _elementCounter++, 1, 10));
    }
  }


  /*
  Bewegt die Items um eine Position in der Y achse nach unten.
   */
  void itemMove() {
    for (var point in _points) {
      point.setYPosition(point.yPosition - 1);
    }
    _points.removeWhere((point) => point.valid <= 0);

    for (var life in _lifeupgrades){
      life.setYPosition(life.yPosition-1);
    }
    _lifeupgrades.removeWhere((life) => life.valid <= 0);
    for (var aimbot in _aimbots){
      aimbot.setYPosition(aimbot.yPosition-1);
    }
    _aimbots.removeWhere((aimbot) => aimbot.valid <= 0);
    itemCheckCollision();
  }
  /*
  Checkt ob ein Item mit dem Spielershuttle kollidiert. Ob es aufgenommen wurde oder noch nicht.
  Außerdem checkt ob das Item schon das Spielfeld verlassen hat.
   */
  void itemCheckCollision(){
    for(var point in _points) {
      if(point.xPosition == _player.xPosition && point.yPosition == _player.yPosition) {
        _score = point.incPoints(_score);
        point.decValid();
      }
      if (point.yPosition <= 0){
        point.decValid();
      }
    }
    for(var life in _lifeupgrades) {
      if(life.xPosition == _player.xPosition && life.yPosition == _player.yPosition) {
        _player.incLife();
        life.decValid();
      }
      if (life.yPosition <= 0){
        life.decValid();
      }
    }

    for(var aimbot in _aimbots) {
      if(aimbot.xPosition == _player.xPosition && aimbot.yPosition == _player.yPosition) {
        _aimbotactiv = true;
        new Timer(const Duration(seconds: 10), () => _aimbotactiv = false);
        aimbot.decValid();
      }
      if (aimbot.yPosition <= 0){
        aimbot.decValid();
      }
    }

  }
}