part of spacepeons;

class SpacePeonsGame{


  // GameParameter, sämtliche Parameter sind die default Einstellungen
  // und werden später ggf. überschrieben
  int _EnemyShootDelay = 20;
  int _EnemyShootChance = 3;
  int _shootdelayCounter = 0;
  int _punkte = 0;
  var _rng = new Random();
  bool _endless = false;
  int _endlessMothershipcounter = 0;
  int _levelCounter = 0;

  //Datenhaltung der SpielObjekte
  Symbol _gamestate;
  List<Barrier>  _hero = new List<Barrier>();
  List<Barrier> _startingBarriers = new List<Barrier>();
  Hero _heroShip;
  List<HeroProjectile> _heroP = new List<HeroProjectile>();
  List<Enemy> _enemies = new List<Enemy>();
  List<EnemyProjectile> _enemyP = new List<EnemyProjectile>();
  List<Enemy> _enemyShooter = new List<Enemy>();
  List<PowerUp> _powerUps = new List<PowerUp>();
  List _level = new List();

  //Datenhaltung des aktiven Levels
  var _field = [];
  int _col = 40;
  int _row = 40;
  int _padding;
  String _currentLvl;

  //sämmtliche Benötigten setter und getter Methoden
  int get punkte => _punkte;
  String get currentLvl => _currentLvl;
  int get levelCounter => _levelCounter;
  int get col => _col;
  int get row => _row;
  Hero get heroShip => _heroShip;
  List<PowerUp> get powerUps => _powerUps;
  List<Barrier> get hero =>_hero;
  Symbol get gamestate => _gamestate;
  set gamestate(Symbol gs) => _gamestate = gs;
  set heroShip(Hero) => _heroShip;
  set powerUps(List) => _powerUps;
  bool get stopped => _gamestate == #stopped;
  bool get running  => _gamestate == #running;
  bool get levelWon => _gamestate == #levelWon;
  bool get pause => _gamestate == #pause;
  bool get gameOver => _gamestate == #gameOver;
  bool get gameWon => _gamestate == #gameWon;

  /**
   * Diese Methode liest eine JSON Datei aus
   */
  Future LoadConfig(String path) async{
    try {
      await HttpRequest.getString(path).then(processParameter);
    } catch (e) {
      print('Couldn\'t open $path');
    }
  }


  /**
   * Diese Methode verarbeitet einen ausgelesenen JSON String und befüllt damit die Spielparameter
   */
  void processParameter(String jsonString){

    final parameter = JSON.decode(jsonString);

    //Parameter nur für das game Objekt
    this._EnemyShootChance = parameter ['EnemyShootChance'];
    this._EnemyShootDelay = parameter['EnemyShootDelay'];
    this._levelCounter = parameter['Level'];

    // Parameter für die Helden Objekte
    HeroDMG = parameter['HeroDMG'];
    HeroHP = parameter['HeroHP'];
    BarrierHP = parameter['BarrierHP'];
    MaxHeroP = parameter['MaxHeroP'];
    SpeedHeroP = parameter['SpeedHeroP'];

    // Parameter für EnemyProjectile Objekte
    MaxEnemyP = parameter['MaxEnemyP'];
    SpeedEnemyP = parameter['SpeedEnemyP'];
    PowerUpDropSpeed = parameter['PowerUpDropSpeed'];

    // Parameter für die Motherships
    MotherShipDmg = parameter['MotherShipDmg'];
    MotherShipHp = parameter['MotherShipHp'];
    MotherShipSpeed = parameter['MotherShipSpeed'];
    MotherShipPoints = parameter['MotherShipPoints'];

    // Parameter für Peons
    PeonDmg = parameter['PeonDmg'];
    PeonHp = parameter['PeonHp'];
    PeonSpeed = parameter['PeonSpeed'];
    PeonPoints = parameter['PeonPoints'];

    // Parameter für PowerUps
    HpUpWert = parameter['HpUpWert'];
    ExtraPointsWert = parameter['ExtraPointsWert'];
    HeroDMGIncrease = parameter['HeroDMGIncrease'];
    MissileDmgIncrease = parameter['MissileDmgIncrease'];

  }


  /**
   * Diese Methode startet das Spiel in dem sie eine JSON Datei ausliest und das Level bauen lässt
   */
  Future startGame(String path) async{

    try {
      //var request = await HttpRequest.getString(path).then(buildLevel);
      var request = await HttpRequest.getString(path);
      this._level = JSON.decode(request);
      buildLevel();
    } catch (e) {
      print('Couldn\'t open $path');
    }
    // Erzeuge am Anfang das HeroShip

  }

  /**
   * Diese Methode baut aus einer ausgelesenen JSON Datei das Level
   */
  void buildLevel() {
    //final level = JSON.decode(path);

    // Leere die Datenhaltung
    _heroP.clear();
    _enemies.clear();
    _enemyP.clear();
    _startingBarriers.clear();
    _hero.clear();


    // Füge die Levelparameter ein
    this._currentLvl = _level[_levelCounter]['levelname'];
    this._col = _level[_levelCounter]['cols'];
    this._row = _level[_levelCounter]['rows'];
    this._padding = _level[_levelCounter]['padding'];
    this._endless = _level[_levelCounter]['endless'];

    //Erzeuge das HeroShip oder setze es in die Mitte des Levels und Füge es wieder der Datenhaltung hinzu
    if(_heroShip == null){
      _heroShip = new Hero(HeroHP, null,this ,3);
    }else{
      List<Pos> newBody = new List<Pos>();
      newBody.add(new Pos(this._row, (this._col/2).round()));
      newBody.add(new Pos(this._row, (this._col/2).round()-1));
      newBody.add(new Pos(this._row, (this._col/2).round()+1));
      newBody.add(new Pos(this._row-1, (this._col/2).round()));
      _heroShip.body = newBody;
    }
    this._hero.add(_heroShip);

    //Erzeuge die Spielfeldtabelle
    _field = [];
    for (int i = 0; i < this._row * this._col; i++) {
      _field.add(0);
    }

    //Verarbeite die Peonswarms
    Map Peonswarms = _level[_levelCounter]['Peonswarms'];

    if (Peonswarms != null) {
      Peonswarms.forEach((k, PS) {
        int PSstartingcol = PS['startingcol'];
        int PSendcol = PS['endcol'];
        int PSabstandPx = PS['abstandPx'];
        int PSabstandPy = PS['abstandPy'];
        int abstandPx = 0;
        int abstandPy = PSabstandPy;

        for (var _row = PSstartingcol; _row < PSendcol; _row++) {
          abstandPy++;
          if (abstandPy > PSabstandPy) {
            abstandPy = 0;
            for (var _col = 0; _col < this._col; _col++) {
              abstandPx++;
              if (_col > _padding && _col + _padding < this._col &&
                  abstandPx > PSabstandPx) {
                abstandPx = 0;
                _enemies.add(new Peon(this, new Pos(_row, _col)));
              }
            }
          }
        }
      });
    }

    //Verarbeite die Peonrows
    Map Peonrows = _level[_levelCounter]['Peonrows'];

    if (Peonrows != null) {
      Peonrows.forEach((k, PR) {
        int PRcol = PR['PeonRowCol'];
        int PRabstandPx = PR['abstandPx'];
        int abstandPx = 0;

        for (var _col = 0; _col < this._col; _col++) {
          abstandPx++;
          if (_col > _padding && _col + _padding < this._col &&
              abstandPx > PRabstandPx) {
            abstandPx = 0;
            _enemies.add(new Peon(this, new Pos(PRcol, _col)));
          }
        }
      });
    }

    //Verarbeite die einzelnen Peons
    Map Peons = _level[_levelCounter]['Peons'];

    if (Peons != null) {
      Peons.forEach((k, P) {
        int Pcol = P['col'];
        int Prow = P['row'];
        _enemies.add(new Peon(this, new Pos(Prow, Pcol)));
      });
    }

    //Verarbeite die Mothership
    Map Motherships = _level[_levelCounter]['Motherships'];

    if (Motherships != null) {
      Motherships.forEach((k, MS) {
        int MScol = MS['col'];
        int MSrow = MS['row'];
        _enemies.add(new MotherShip(this, new Pos(MSrow, MScol)));
      });
    }

    //Verarbeite die PowerUps
    Map PowerUps = _level[_levelCounter]['PowerUps'];

    if(PowerUps != null) {
      PowerUps.forEach((k, PU) {
        int PUcol = PU['col'];
        int PUrow = PU['row'];
        int PUkind = PU['kind'];
        spawnPowerUp(new Pos(PUrow, PUcol), PUkind);
      });
    }

    //Verarbeite die BarrikadenRows
    Map BarrikadenRows = _level[_levelCounter]['BarrikadenRows'];

    if(BarrikadenRows != null) {
      BarrikadenRows.forEach((k, BR) {
        int BRcol = BR['BRcol'];
        int BRabstandBx = BR['abstandBx'];
        int abstandBx = 0;

        for (var _col = 0; _col < this._col; _col++) {
          abstandBx++;
          if (_col > _padding && _col + _padding < this._col &&
              abstandBx > BRabstandBx) {
            abstandBx = 0;
            List<Pos> newBody = new List<Pos>();
            newBody.add(new Pos(BRcol, _col));
            newBody.add(new Pos(BRcol - 1, _col));
            newBody.add(new Pos(BRcol - 1, _col + 1));
            newBody.add(new Pos(BRcol - 1, _col + 2));
            newBody.add(new Pos(BRcol, _col + 2));
            Barrier newBarrier = new Barrier(BarrierHP, newBody, this);
            _hero.add(newBarrier);
            Barrier newBarrierDummy = new Barrier(BarrierHP, newBody, this);
            _startingBarriers.add(newBarrierDummy);

          }
        }
      });
    }

    //Verarbeite die einzelnen Barrikaden
    Map Barrikaden = _level[_levelCounter]['Barrikaden'];

    if(Barrikaden != null) {
      Barrikaden.forEach((k, B) {
        int Bcol = B['col'];
        int Brow = B['row'];
        List<Pos> newBody = new List<Pos>();
        newBody.add(new Pos(Brow + 1, Bcol - 1));
        newBody.add(new Pos(Brow, Bcol - 1));
        newBody.add(new Pos(Brow, Bcol));
        newBody.add(new Pos(Brow, Bcol + 1));
        newBody.add(new Pos(Brow + 1, Bcol + 1));
        Barrier newBarrier = new Barrier(BarrierHP, newBody, this);
        _hero.add(newBarrier);
        Barrier newBarrierDummy = new Barrier(BarrierHP, newBody, this);
        _startingBarriers.add(newBarrierDummy);
      });
    }

    //Setze das Spiel auf laufend
    _gamestate = #running;
  }

  /**
   *Diese Methode wird aufgerufen, wenn das level gewonnen wurde. Sie
   *setzt den levelCounter einen weiter falls es noch ein Level gibt
   *wird dieses gebaut sonst hat man das Spiel gewonnen
   */
  void NextLevel(){

    _levelCounter++;
    if(_levelCounter < _level.length){
      this._hero.clear();
      this._hero.add(_heroShip);
      buildLevel();
      //_gamestate = #nextLevel;
    }else{
      _gamestate = #gameWon;
    }

  }

  /**
   *Diese Methode erzeugt die EndlosFlut, immer wenn 5 Reihen frei sind wird etwas neues gespawnt.
   *Entweder eine Reihe Peons oder ein MotherShip.
   */
  void endlessflood(){
    bool canSpawn = true;
    _enemies.forEach((e) {
      e.body.forEach((b){
        if(b._row < 5) canSpawn = false;
      });
    });

    if(canSpawn) {
      int abstandPx = 0;
      if (_rng.nextInt(21 - _endlessMothershipcounter) + _endlessMothershipcounter < 19) {
        _endlessMothershipcounter++;
        for (var _col = 0; _col < this._col; _col++) {
          abstandPx++;
          if (_col > _padding && _col + _padding < this._col && abstandPx > 2) {
            abstandPx = 0;
            _enemies.add(new Peon(this, new Pos(1, _col)));
          }
        }
      }else{
        _endlessMothershipcounter = 0;
        _enemies.add(new MotherShip(this, new Pos(1, (_rng.nextInt(this._col-6)+3))));
      }
    }
  }

  /**
   *Diese Methode wird in einem TimerIntervall vom Controller angestoßen. Hier wird falls das Spiel
   *läuft das Modell einen Schritt voran gesetzt.
   */
  updateFrame(){
    if(_gamestate == #running) {
      if (_endless) endlessflood();

      //Verarbeite die HeroProjectile
      if (_heroP.isNotEmpty) {
        _heroP.forEach((p) => p.move());
        _heroP.removeWhere((p) => p.getHit == true);
      }

      //Verarbeite die EnemyProjectile
      if (_enemyP.isNotEmpty) {
        _enemyP.forEach((p) => p.move());
        _enemyP.removeWhere((p) => p.getHit == true);
      }

      //Verarbeite die PowerUps
      if (_powerUps.isNotEmpty) {
        _powerUps.forEach((p) => p.move());
        _powerUps.removeWhere((p) => p.getHit == true);
      }

      //Verarbeite die Enemys
      if (_enemies.isNotEmpty) {
        _enemies.forEach((e) => e.move());
      }

      //Entferne die "toten" Objekte
      _enemies.removeWhere((e) => e.HP <= 0);
      _hero.removeWhere((h) => h.healthPoints <= 0);

      //Lass die Enemys schiessen
      enemiesShooting();

      //Endloseflut?
      if (_endless) endlessflood();

      //stand des Spiels prüfen
      setGamestate();
    }
  }


  /**
   *Diese Methode bestimmt ob ein Level gewonnen oder verloren wurde
   */
   void setGamestate(){
    if(_enemies.isEmpty && _powerUps.isEmpty && !_endless){
      _gamestate = #levelWon;
      return;
    }

    _enemies.forEach((e) {
      e.body.forEach((b){
        if(b._row > (this._row-2)) _gamestate = #gameOver;
      });
    });
  }

  /**
   * Diese Methode berechnet ob von welchem Enemy geschossen wird
   */
  void enemiesShooting() {
    _shootdelayCounter++;
    //Aufruf in bestimmten Delay
    if (_shootdelayCounter > _EnemyShootDelay) {
      _shootdelayCounter=0;
      //33 % Chance das Geschossen wird und nicht mehr als MaxEnemyP schüsse
      if (_rng.nextInt(_EnemyShootChance) == 0 && _enemyP.length < MaxEnemyP) {
        _enemyShooter.clear();
        _enemies.forEach((e) {
          if (e is Peon && e.lowest())
              _enemyShooter.add(e);
          if(e is MotherShip){
            _enemyShooter.add(e);
          }
        });

        //Mische die möglichen Schützen und lasse den ersten aus der Liste Schiessen
        _enemyShooter.shuffle();
        _enemyShooter.first.shoot();
      }
    }
  }

  /**
   * Diese Methode berechnet das Feld welches vom View interpretiert wird
   */
  List calcField(){

    //Leere das Feld
    for(int i= 0 ; i < _field.length; i++){
      _field[i] = 0;
    }

    //Gehe die HeldenProjektile durch
    _heroP.forEach((p){_field[((p._anchor._row-1)*this._col + p._anchor._col)] = 1;});
    //Gehe die EnemyProjektile durch
    _enemyP.forEach((p){_field[((p._anchor._row-1)*this._col + p._anchor._col)] = 2;});
    //Gehe die Helden Objekte durch
    _hero.forEach((h){
      if(h == _heroShip){
        if(h.Weapon is DoubleShot)
          _field[((h.body.first._row - 2) * this._col + h.body.first._col - 1)] = 12;
        else if(h.Weapon is TripleShot)
          _field[((h.body.first._row - 2) * this._col + h.body.first._col - 1)] = 12;
        else
          _field[((h.body.first._row - 2) * this._col + h.body.first._col - 1)] = 5;
      }
      else {
        for (Pos p in h.body) {
          _field[((p._row - 1) * this._col + p._col)] = 11;
        }
      }
    });
    //Gehe die Feinde durch
    _enemies.forEach((e){
      if(e is Peon) {
        _field[((e._anchor._row - 1) * this._col + e._anchor._col)] = 6;
      }
      if(e is MotherShip){
        _field[((e._anchor._row - 1) * this._col + e._anchor._col - 1)] = 4;
      }
    });

    //Gehe die PowerUps durch
    for(PowerUp p in _powerUps){
      if(p is ExtraPoints)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 7;
      if(p is WeaponUp)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 8;
      if(p is DoubleShot)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 8;
      if(p is HpUp)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 9;
      if(p is BarrierUp)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 10;
      if(p is TripleShot)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 8;
      if(p is MoreDmgPowerUp)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 14;
      if(p is HomeingMissile)
        _field[((p._anchor._row-1)*this._col + p._anchor._col)] = 13;
    }

    return _field;
  }


  /**
   * Diese Methode erzeugt ein PowerUp an einer gegebenen Position der
   * Integer bestimmt die Art. Bei null wird ein zufälliger bestimmt
   */
  void spawnPowerUp(Pos pos, int kind) {
    if (kind == null) kind = _rng.nextInt(5);

    switch (kind) {
      case 0:
        this._powerUps.add(new ExtraPoints(this, pos));
        break;
      case 1:
        this._powerUps.add(new WeaponUp(this, pos));
        break;
      case 2:
        this._powerUps.add(new HpUp(this, pos));
        break;
      case 3:
        this._powerUps.add(new MoreDmgPowerUp(this, pos));
        break;
      case 4:
        if(_startingBarriers.isNotEmpty) {
          this._powerUps.add(new BarrierUp(this, pos));
        }else{
          spawnPowerUp(pos, null);
        }
        break;
      case 5:
        this._powerUps.add(new DoubleShot(this, pos));
        break;
      case 6:
        this._powerUps.add(new TripleShot(this, pos));
        break;
      case 7:
        this._powerUps.add(new HomeingMissile(this, pos));
        break;
      default:
        this._powerUps.add(new DoubleShot(this, pos));
        break;
    }
  }

  /**
   * Diese Methode Spawnt die StartBarrikaden neu
   */
  void spawnBarrikaden(){
    _hero.clear();
    _hero.add(_heroShip);
    _startingBarriers.forEach((b){
      Barrier newBarrierDummy = new Barrier(b.healthPoints, b.body, this);
      _hero.add(newBarrierDummy);
    });
  }
}

/**
 * Diese Hilfsklasse wird benutzt um die Position
 * in der Spielfeldtabelle zu halten
 */
class Pos {
    int _row;
    int _col;

    Pos(int _row,int _col){
      this._col = _col;
      this._row = _row;
    }
    int get row =>this._row;
    int get col =>this._col;

    bool equal(Pos position){
      if(position._col==this._col && position._row==this._row){
        return true;
      }else{
        return false;
      };
    }
    void setRow(int _row){
      this._row = _row;
    }

    void setCol(int _row){
      this._col = _row;
    }
  }

/**
 * Die Klasse Hero erweitert die Barrikaden und beschreibt das HeldenSchiff.
 * Der Hero hat HP, einen body, eine game Referenz, einen turm und eine Waffe.
 * Der Turm wird benötigt zur ausrichtung der Geschosse.
 * Die Waffe beschreibt den Schussmodus.
 */
  class Hero extends Barrier{
    int _turret;
    PowerUp _weapon;

    Hero(int hp, List<Pos> position, SpacePeonsGame game, int turret) : super(hp, position, game) {
      if(position==null){
        body.add(new Pos(_game._row, (_game._col/2).round()));
        body.add(new Pos(_game._row, (_game._col/2).round()-1));
        body.add(new Pos(_game._row, (_game._col/2).round()+1));
        body.add(new Pos(_game._row-1, (_game._col/2).round()));
      }else{
        for(Pos posi in position){
            body.add(posi);
        }
      }
      this._turret = turret;
      _weapon = null;
    }

    Pos get Turret=> new Pos(this.body[_turret]._row-1,body[_turret]._col);

    PowerUp get Weapon => this._weapon;

    void setWeapon(PowerUp Weapon){
      this._weapon = Weapon;
    }

    /**
     * Diese Methode bewegt den Hero.
     */
    void move(int range){
        bool canMove = true;
        for(Pos posi in body){
          if(posi._col==0 && range < 0)
            canMove = false;
          if(posi._col==_game._col-1 && range > 0)
            canMove = false;
        }
      if(canMove){
        for(Pos posi in body){
          posi.setCol(posi._col + range);
        }
        hit();
      }
    }

    /**
     * Diese Methode beschädigt den Hero.
     */
    void damage(int dmg, Pos hit){
      this.healthPoints-=dmg;
      if(healthPoints<=0){
        _game._gamestate = #gameOver;
      }

    }

    /**
     * Diese Methode lässt den Hero schiessen.
     * Wenn er eine Waffe hat wird deren Schussmodus ausgeführt, sonst der
     * shootDefault.
     */
    void shoot(){
      if(_weapon != null){
        _weapon.doPowerUpStuff();
      }else{
        shootDefault();
      }
    }

    void shootDefault(){
      if(_game._heroP.length < MaxHeroP ){
        _game._heroP.add(new HeroProjectile(_game,HeroDMG, new Pos(body[_turret]._row-1,body[_turret]._col)));
      }

    }

    //In einem EnemyProjectile?
    void hit(){
      _game._enemyP.forEach((p){p.hit();});

    }
  }

/**
 * Die Klasse Barrier beschreibt die Barrikaden.
 * Barrikaden haben HP, einen body und eine game Referenz.
 */
class Barrier
{

  int healthPoints;
  SpacePeonsGame _game;
  List<Pos> body = new List();

  Barrier(int hp, List<Pos> position, SpacePeonsGame game){
    this._game = game;
    this.healthPoints = hp;
    if(position != null){
      for(Pos posi in position){
        body.add(posi);
      }
    }
  }

  /**
   * Diese Methode beschädigt die Barrikade.
   * Wenn ein teil der Barrikade getroffen wird wird er zerstört.
   * Die Barrikade hat trotzdem noch lebenspunkte wenn diese auf
   * null fallen verschwindet die Barrikade.
   */
  void damage(int dmg, Pos hit) {

      body.removeWhere((p) => p.equal(hit));
      if(healthPoints > 0) {
        healthPoints = healthPoints - dmg;
      }

  }

}

/**
 * Die abstrakte Klasse Projectile beschreibt grundlegend Geschosse.
 * Geschosse haben einen Schadenswert, eine Position, eine TrefferFlag und eine game Referenz.
 */

abstract class Projectile{
  int _speedCounter = 0;
  int _speed;
  int dmg;
  SpacePeonsGame _game;
  Pos _anchor;
  bool _hit = false;
  bool get getHit => this._hit;

  Projectile(this._game, this.dmg,this._anchor){
  }

  void move();
  void hit();
}

/**
 * Die Klasse Missile erweitert das HeroProjectile.
 * Missile ist ein zielsuchendes Geschoss.
 */
class Missile extends HeroProjectile {
  Enemy aim;
  Missile(SpacePeonsGame game, int dmg, Pos anchor)
      : super(game, dmg, anchor);

  /**
   * Diese Methode bewegt das Projektil
   */
  void move() {
    //Suche neues Ziel falls du kein gültiges hast
    if (aim == null || aim.HP <= 0) {
      int distance = 100;
      int newdistance = 0;
      _game._enemies.forEach((e) {
        int rows = (e._anchor._row - this._anchor._row).abs();
        int cols = (e._anchor._col - this._anchor._col).abs();
        newdistance = rows + cols;
        if (newdistance < distance && e.HP > 0) {
          aim = e;
          distance = newdistance;
        }
      });
    }
    //Ein Ziel gefunden
    if (aim != null) {
      int rows = (aim._anchor._row - this._anchor._row).abs();
      int cols = (aim._anchor._col - this._anchor._col).abs();
      if (rows > cols) {
        //Fall Y entfernung größer als X entfernung
        int rows = (aim._anchor._row - this._anchor._row);
        if (rows > 0) {
          //Fall Geschoß über dem Gegner
          this._anchor._row++;
        } else {
          //Fall Geschoß unter dem Gegner
          this._anchor._row--;
        }
      } else {
        // Fall X entfernung größer als Y entfernung
        int cols = (aim._anchor._col - this._anchor._col);
        if (cols > 0){
          //Fall Geschoß links vom Gegner
          this._anchor._col++;
        } else {
          //Fall Geschoß rechts vom Gegner
          this._anchor._col--;
        }
      }
      //Kein Ziel gefunden
    }else {
      this._anchor._row--;
    }
    if (this._anchor._row < 2) {
      this._hit = true;
    }
    hit();
  }
}

/**
 * Die Klasse HeroProjectile erweitert das Projectile.
 * HeroProjectile beschreibt die Projectile von den Helden.
 */
class HeroProjectile extends Projectile {
  HeroProjectile(SpacePeonsGame game, int dmg, Pos anchor) : super(game, dmg, anchor){
    _speed = SpeedHeroP;
  }

  /**
   * Diese Methode bewegt das Projektil
   */
  void move() {
    _speedCounter++;
    if (_speedCounter > _speed) {
      _speedCounter = 0;
      if (this._anchor._row < 2) {
        this._hit = true;
      } else {
        this._anchor._row--;
        hit();
      }
    }
  }

  /**
   * Diese Methode prüft ob ein Enemy getroffen wird
   */
  void hit() {
    //bool _hit = false;
    _game._enemies.forEach((e) {
      e.body.forEach((b) {
        if (this._anchor.equal(b))
        {
          _hit = true;
          e.damage(this.dmg);
        }
      });
    });
  }
}

  /**
   *  Die Klasse EnemyProjectile erweitert das Projectile.
   *  EnemyProjectile beschreibt die Projectile der Enemys
   */
  class EnemyProjectile extends Projectile {

    EnemyProjectile(SpacePeonsGame game, int dmg, Pos anchor) : super(game, dmg, anchor){
      _speed = SpeedEnemyP;
    }

    /**
     * Diese Methode bewegt das Projektil
     */
    void move() {
      _speedCounter++;
      if (_speedCounter > _speed) {
        _speedCounter = 0;
        if (this._anchor._row > _game._row - 1) {
          this._hit = true;
        } else {
          this._anchor._row++;
          hit();
        }
      }
    }

    /**
     * Wurde ein Hero getroffen?
     */
    void hit() {
      _game.hero.forEach((h) {
        h.body.forEach((b) {
          if (this._anchor.equal(b))
          {
            _hit = true;
            h.damage(this.dmg, this._anchor);
          }
        });
      });
    }
  }

/**
 * Die abstrakte Klasse PowerUp erweitert EnemyProjectile.
 * PowerUp hat eine PowerUpKind.
 */
abstract class PowerUp extends EnemyProjectile {

  PowerUpKind _kind;

  PowerUp(SpacePeonsGame game, Pos anchor) : super(game, 0, anchor) {
    _speedCounter = 0;
    _speed =PowerUpDropSpeed;
  }

  /**
   * Wurde das HeroSchiff getroffen?
   */
  void hit() {
    _game.heroShip.body.forEach((p) {
        if (this._anchor.equal(p)) _hit = true;
      });
      if (_hit) {
        if(this._kind == PowerUpKind.Once){
          this.doPowerUpStuff();
        }else {
          _game.heroShip._weapon = this;
        }
      }
  }

  PowerUpKind get Kind=> _kind;

  /**
   * Diese Methode führt die Logik des PowerUps aus
   */
  void doPowerUpStuff();
}

/**
 * Das PowerUp BarrierUp stellt start Barrikaden wieder her
 */
class BarrierUp extends PowerUp{
  BarrierUp(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    this._kind = PowerUpKind.Once;
  }


  @override
  void doPowerUpStuff() {
    _game.spawnBarrikaden();
  }
}


/**
 * Das PowerUp HpUp gibt dem Heldenschiff extra leben
 */
class HpUp extends PowerUp{
  HpUp(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    this._kind = PowerUpKind.Once;
  }


  @override
  void doPowerUpStuff() {
    _game._heroShip.healthPoints = _game._heroShip.healthPoints + HpUpWert;
  }
}

/**
 * Das PowerUp ExtraPoints gibt extra Punkte
 */
class ExtraPoints extends PowerUp{
  ExtraPoints(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    _kind = PowerUpKind.Once;
  }


  @override
  void doPowerUpStuff() {
    _game._punkte = _game._punkte + ExtraPointsWert;
  }
}

/**
 * Das PowerUp WeaponUp verbessert die Waffe des HeroShips.
 * singleShot -> doubleShot -> tripleShot -> homeingMissile
 */
class WeaponUp extends PowerUp{
  WeaponUp(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    _kind = PowerUpKind.Once;
  }


  @override
  void doPowerUpStuff() {
    if(_game._heroShip.Weapon == null) {
      _game._heroShip.setWeapon(new DoubleShot(_game, null));
      return;
    }
    if(_game._heroShip.Weapon is DoubleShot) {
      _game._heroShip.setWeapon(new TripleShot(_game, null));
      return;
    }
    if(_game._heroShip.Weapon is TripleShot) {
      _game._heroShip.setWeapon(new HomeingMissile(_game, null));
      return;
    }
  }
}

/**
 * Das PowerUp DoubleShot ist eine Waffe die zwei Projektile erzeugt.
 */
class DoubleShot extends PowerUp{
  DoubleShot(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    _kind = PowerUpKind.Weapon;
  }

   @override
  void doPowerUpStuff() {
     if(_game._heroP.length < MaxHeroP ){
       _game._heroP.add(new HeroProjectile(_game,HeroDMG,new Pos(_game.heroShip.Turret._row,_game.heroShip.Turret._col+1)));
       _game._heroP.add(new HeroProjectile(_game,HeroDMG,new Pos(_game.heroShip.Turret._row,_game.heroShip.Turret._col-1)));
     }
  }
}

/**
 *  Das PowerUp MoreDmgPowerUp erhöht den Schaden der HeroShip Projektile.
 */
class MoreDmgPowerUp extends PowerUp{

   MoreDmgPowerUp(SpacePeonsGame game, Pos anchor) : super(game, anchor){
     _kind = PowerUpKind.Once;
   }

  @override
  void doPowerUpStuff() {
    HeroDMG= HeroDMG + HeroDMGIncrease;
    MissileDmg= MissileDmgIncrease;

  }
}

/**
 * Das PowerUp TripleShot ist eine Waffe, welche drei Projektile erzeugt.
 */
class TripleShot extends PowerUp{
  TripleShot(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    _kind = PowerUpKind.Weapon;
  }


  @override
  void doPowerUpStuff() {
    if(_game._heroP.length < MaxHeroP ){
      _game._heroP.add(new HeroProjectile(_game,HeroDMG,new Pos(_game.heroShip.Turret._row,_game.heroShip.Turret._col+1)));
      _game._heroP.add(new HeroProjectile(_game,HeroDMG,new Pos(_game.heroShip.Turret._row,_game.heroShip.Turret._col)));
      _game._heroP.add(new HeroProjectile(_game,HeroDMG,new Pos(_game.heroShip.Turret._row,_game.heroShip.Turret._col-1)));
    }
  }
}

/**
 * Das PowerUp HomeingMissile ist eine Waffe, welche eine Homeing Missile erzeugt.
 */
class HomeingMissile extends PowerUp{
  HomeingMissile(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    _kind = PowerUpKind.Weapon;
  }


  @override
  void doPowerUpStuff() {
    if(_game._heroP.length < MaxMissiles ){
      _game._heroP.add(new Missile(_game,MissileDmg,new Pos(_game.heroShip.Turret._row,_game.heroShip.Turret._col)));
    }
  }
}


/**
 * Die abstrakte Klasse Enemy beschreibt grundlegende Feinde.
 * Enemys haben HP, einen Anker, einen body, eine Geschwindigkeit und eine game Referenz
 */
abstract class Enemy {
  int HP;
  Pos _anchor;
  SpacePeonsGame _game;
  int _speed;
  List<Pos> _body = new List();

  Enemy(SpacePeonsGame game, Pos anchor){
    this._game    = game;
    this._anchor  = anchor;
    _body.add(_anchor);
  }

  List<Pos> get body =>this._body;
  Pos set(Pos position) => this._anchor=position;

  //Diese Methode bewegt den Enemy
  void move();

  //Diese Methode beschädigt den Enemy
  void damage(int dmg);

  //In einem HeroProjectile?
  void hit(){
    _game._heroP.forEach((p){p.hit();});

  }

  //Diese Methode lässt den Enemy schiessen
  void shoot();
}

/**
 * Die Klasse MotherShip erweitert den Enemy.
 * Das Mutterschiff bewegt sich von links nach rechts und dann von rechts nach links.
 * Jeden sechsten Schritt bewegt es sich nach unten.
 */
class MotherShip extends Enemy{
  int _speedCounter = 0;
  int _moveCounter=0;
  bool _moveRight = true;
  int _dmg = MotherShipDmg;

  MotherShip(SpacePeonsGame game, Pos anchor) : super(game, anchor){
    this.HP = MotherShipHp;
    _body.add(new Pos(_anchor._row, _anchor._col+1));
    _body.add(new Pos(_anchor._row, _anchor._col-1));
    _body.add(new Pos(_anchor._row-1, _anchor._col));
    _body.add(new Pos(_anchor._row-1, _anchor._col+1));
    _body.add(new Pos(_anchor._row-1, _anchor._col-1));
    this._speed = MotherShipSpeed;
  }

  @override
  void move() {
    _speedCounter++;
    if (_speedCounter > _speed) {
      _speedCounter = 0;
      if (_moveCounter < 6) {
        bool switchMove = false;
        for (Pos posi in _body) {
          if (posi._col == 0) switchMove = true;
          if (posi._col == _game._col - 1) switchMove = true;
        }
        if (switchMove) _moveRight = !_moveRight;
        if (_moveRight) {
          for (Pos posi in _body) {
            posi.setCol(posi._col + 1);
          }
        } else {
          for (Pos posi in _body) {
            posi.setCol(posi._col - 1);
          }
        }
        this._moveCounter++;
      } else {
        for (Pos posi in _body) {
          posi.setRow(posi._row + 1);
        }
        this._moveCounter = 0;
      }
      hit();
    }
  }

  @override
  void shoot() {
    _game._enemyP.add(new EnemyProjectile(_game,_dmg, new Pos(_anchor._row+1,_anchor._col)));
  }

  @override
  void damage(int dmg) {
    if (HP > 0) {
      HP -= dmg;
      if(HP <= 0){
        _game._punkte +=MotherShipPoints;
        _game.spawnPowerUp(new Pos(this._anchor._row+1,this._anchor._col), null);
      }
    }
  }
}

/**
 * Die Klasse Peon erweitert den Enemy.
 * Der Peon bewegt sich sechsmal nach rechts, dann ein runter, dann sechsmal nach links,
 * dann ein runter usw.
 */
class Peon extends Enemy {
  bool moveRight=true;
  int _moveCounter=0;
  int _speedCounter=0;
  int _dmg = PeonDmg;

  Peon(SpacePeonsGame game, Pos position) : super(game, position){
    this.HP = PeonHp;
    this._speed = PeonSpeed;
  }

  void move() {
    _speedCounter++;
    if (_speedCounter > _speed) {
      _speedCounter = 0;
      if (_moveCounter < 6) {
        if (moveRight) {
          this._anchor._col++;
        } else {
          this._anchor._col--;
        }
        _moveCounter++;
      } else {
        this._anchor._row++;
        this._moveCounter = 0;
        this.moveRight = !moveRight;
      }
      hit();
    }
  }

  /**
   * Diese Methode prüft ob der Peon der unterste enemy in der Reihe ist.
   */
  bool lowest(){
    //Bin ich der unterste Peon in meiner reihe
    bool _lowest = true;
    _game._enemies.forEach((e){
      if(e is Peon && e._anchor._col==this._anchor._col && e._anchor._row>this._anchor._row){
        _lowest = false;
      }
    });
    return _lowest;
  }

  void shoot(){
    _game._enemyP.add(new EnemyProjectile(_game,_dmg, new Pos(_anchor._row+1,_anchor._col)));
  }

  void damage(int dmg) {

    if (HP > 0) {
      HP -= dmg;
      if(HP <= 0) _game._punkte+=PeonPoints;
    }
  }
}