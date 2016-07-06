import 'Types/Position.dart';
import 'Ghost.dart';
import 'NomNom.dart';
import 'GameObject.dart';
import 'Items/Block.dart';
import 'Items/PointItem.dart';
import 'Items/SpeedItem.dart';
import 'Items/SpecialItem.dart';
import 'Items/Item.dart';
import 'dart:math';
import 'LevelGen/levelGen.dart';
import 'Strategies/FollowStrategy.dart';
import 'Strategies/EscapeStrategy.dart';
import 'Strategies/RightStrategy.dart';
import 'Strategies/LeftStrategy.dart';
import 'Strategies/Strategy.dart';
import 'ItemEvent.dart';


/**
 * Central game class
 */
class GameTable {
  int DIM;
  int SEED;

  int pointPoints;
  int cherryPoints;
  int orangePoints;
  double raspberrySpeed;
  double blueBonbonSpeed;
  double redBonbonSpeed;
  int speed;
  Event tempDelete = null;

  Random _rng;
  List<List<List<num>>> field;
  List<num> fruitList = new List();
  List<num> pillList = new List();
  List<Ghost> ghosts = new List();
  List<num> ghostsList = new List();

  List<Event> events = new List();
  List<Position> moveablePos = new List();
  List<Position> ghostSpawnPositions = new List();
  List<Position> itemSpawnPositions = new List();

  NomNom nomNom;
  num levelscale;
  Map object = new Map();
  int coins = 0;
  bool gameOver = false;
  Map mapData;
  Map parameters;
  List<int> killedGhosts = new List();

  /**
   * Constructor
   */
  GameTable(Map states, this.mapData,this.parameters) {

    // Map parameters
    DIM = this.mapData["dim"];
    SEED = this.mapData["seed"];

    // Game parameters
    pointPoints = parameters["pointPoints"];
    cherryPoints = parameters["cherryPoints"];
    orangePoints = parameters["orangePoints"];
    raspberrySpeed = parameters["raspberrySpeed"];
    blueBonbonSpeed = parameters["blueBonbon"];
    redBonbonSpeed = parameters["redBonbon"];
    speed = parameters["speed"];

    _rng = new Random(SEED);
    nomNom = new NomNom(this);
    nomNom.resetPoints();

    this.setGameStats(states);
    generateGameTable();
  }

  /**
   *
   */
  void setGameStats(Map map){
      if(map != null && map["level"] != 0){
        nomNom.level = map["level"];
        nomNom.points = map["points"];
        nomNom.life = map["life"];
      }
  }

  /**
   * Ticks NomNom, the Ghosts and the Events, to gave them a time to act
   * Delete events, when the time runs out and delete ghost, when they're dead
   */
  void onTick(){
    nomNom.onTick();
    ghosts.forEach((ghost) => ghost.onTick());
    events.forEach((event) => event.onTick());

    if(tempDelete != null){
      events.remove(tempDelete);
      tempDelete = null;
    }

    if(killedGhosts.isNotEmpty){
      killedGhosts.forEach((gid) {
        Ghost g = this.object[gid];
        this.ghosts.remove(g);
        this.field[g.pos.X][g.pos.Y][1] = GameObject.empty;
        this.object[gid] = null;
      });
      killedGhosts.clear();
    }
  }

  /**
   * Adjust Speed of Ghosts
   * @param id Id from the item, to create a new event
   * @param speed The speed which the ghosts run faster or slower
   */
  void adjGhostSpeed(int id, double speed){
    addEvent(id);
    ghosts.forEach((ghost) => ghost.adjustSpeed(speed));
  }
  /**
   * Add a new Event to the Eventlist
   * @param type Id from the item, to change it back later
   */
  void addEvent(int type){
    events.add(new Event(this,type));
  }

  /**
   * remove event
   * @param type What should be changed back
   * @param e The event which should be deleted
   */
  void removeEvent(int type, Event e){
    if(type == 1){
      nomNom.normSpeed();
    }else if(type == 2){
      ghosts.forEach((ghost) => ghost.normSpeed());
    }else{
      nomNom.switchEatAble();
    }
    tempDelete = e;
  }

  /**
   * Adds a new ghost to the field
   */
  void genNewGhost(){
    Ghost g = new Ghost(GameObject.pinkGhost, new FollowStrategy(), getNextGhostSpawnPosition(), this);
    ghosts.add(g);
    this.object[GameObject.pinkGhost] = g;
  }

  /**
   * Set NomNom to a Direction
   * @param dir in which dir NomNom set to
   */
  void setDirNomNom(int dir) {
    nomNom.currDirection = dir;
  }


  /**
   * Search Positions in which Ghosts can move
   * @param pos current Position of the Ghost
   * @return List of position where the Ghost can move
   */
  List<Position> adjPos(Position pos) {
    List<Position> positions = new List();

    //up
    if (field[pos.X][(pos.Y - 1)][0] != GameObject.block) {
      positions.add(new Position(pos.X, (pos.Y - 1)));
    }
    //down
    if (field[pos.X][(pos.Y + 1)][0] != GameObject.block) {
      positions.add(new Position(pos.X, (pos.Y + 1)));
    }
    //left
    if (field[(pos.X - 1)][pos.Y][0] != GameObject.block) {
      positions.add(new Position((pos.X - 1), pos.Y));
    }
    //right
    if (field[(pos.X + 1)][pos.Y][0] != GameObject.block) {
      positions.add(new Position((pos.X + 1), pos.Y));
    }
    return positions;
  }

  /**
   * Register powerups
   */
  void generateObjects(){
    this.object[GameObject.block] = new Block(GameObject.block);
    this.object[GameObject.point] = new PointItem(GameObject.point, pointPoints);
    this.object[GameObject.cherry] = new PointItem(GameObject.cherry, cherryPoints);
    this.object[GameObject.orange] = new PointItem(GameObject.orange, orangePoints);
    this.object[GameObject.raspberry] = new SpeedItem(GameObject.raspberry, raspberrySpeed);
    this.object[GameObject.lemon] = new SpecialItem(GameObject.lemon);
    this.object[GameObject.blueBonbon] = new SpeedItem(GameObject.blueBonbon, blueBonbonSpeed);
    this.object[GameObject.redBonbon] = new SpeedItem(GameObject.redBonbon, redBonbonSpeed);
    this.object[GameObject.greenBonbon] = new SpecialItem(GameObject.greenBonbon);
    this.object[GameObject.yellowBonbon] = new SpecialItem(GameObject.yellowBonbon);

    fruitList.add(GameObject.cherry);
    fruitList.add(GameObject.orange);
    fruitList.add(GameObject.raspberry);
    fruitList.add(GameObject.lemon);

    pillList.add(GameObject.blueBonbon);
    pillList.add(GameObject.redBonbon);
    pillList.add(GameObject.greenBonbon);
    pillList.add(GameObject.yellowBonbon);
  }

  /**
   * Generate Ghosts
   */
  void generateGhosts(int count){
    ghosts.clear();


    ghostsList.add(GameObject.yellowGhost);
    ghostsList.add(GameObject.greenGhost);
    ghostsList.add(GameObject.redGhost);
    ghostsList.add(GameObject.blueGhost);

    for(int i = 0; i < count; i++){
      Ghost g = new Ghost(ghostsList[i], getStrategy(i), getNextGhostSpawnPosition(), this);
      ghosts.add(g);
      this.object[ghostsList[i]] = g;
    }
  }

  Strategy getStrategy(int strategyNumber){
    switch (strategyNumber) {
      case 0:
        return new RightStrategy(_rng);
      case 1:
        return new LeftStrategy(_rng);
      case 2:
        return new FollowStrategy();
      case 3:
        return new EscapeStrategy();
    }
    return null;
  }

  /**
   * Returns random position
   */
  Position getNextRndPosition(){
    return moveablePos.elementAt(_rng.nextInt(moveablePos.length));
  }

  /**
   * Returns random GhostSpawn
   */
  Position getNextGhostSpawnPosition(){
    Position ret;
    if(this.ghostSpawnPositions.isNotEmpty)
      ret = this.ghostSpawnPositions.removeAt(_rng.nextInt(this.ghostSpawnPositions.length));
    else
      ret = getNextRndPosition();

    return ret;
  }

  /**
   * Returns random item spawn place
   */
  Position getNextItemSpawnPosition(){
    Position ret;
    if(this.itemSpawnPositions.isNotEmpty)
      ret = this.itemSpawnPositions.removeAt(_rng.nextInt(this.itemSpawnPositions.length));
    else
      ret = getNextRndPosition();
    return ret;
  }

  /**
   * generates the GameTable
   */
  void generateGameTable() {
    this.object.clear();
    this.moveablePos.clear();
    this.ghostSpawnPositions.clear();
    this.itemSpawnPositions.clear();
    levelscale = nomNom.level * 0.25;

    LevelGen gen = new LevelGen(_rng,DIM,mapData);
    //gen.generateField(new Field(DIM,DIM));
    gen.parseJsonMap(nomNom.level);

    field = new List.generate(DIM, (i) => new List.generate(DIM, (j) => new List.filled(2,0)));

    for(int i = 0; i<DIM; i++){
      for(int j = 0; j<DIM; j++){
        var tmp = gen.field.getField(i,j);

        if(tmp == this.mapData["defines"]["wall"]){
          field[i][j][0] = GameObject.block;
        }
        else{
          field[i][j][0] = GameObject.point;
          moveablePos.add(new Position(i,j));

          if(tmp == this.mapData["defines"]["ghosts"])
            this.ghostSpawnPositions.add(new Position(i,j));

          if(tmp == this.mapData["defines"]["items"])
            this.itemSpawnPositions.add(new Position(i,j));
        }
        field[i][j][1] = GameObject.empty;
      }
    }

    generateObjects();

    var pos;

    levelscale = levelscale.ceil();

    for(int i = 0; i < levelscale; i++){
      pos = getNextItemSpawnPosition();
      field[pos.X][pos.Y][0] = fruitList[i];
      pos = getNextItemSpawnPosition();
      field[pos.X][pos.Y][0] = pillList[i];
    }

    generateGhosts(levelscale);

    nomNom.pos = getNextRndPosition();
    field[nomNom.pos.X][nomNom.pos.Y][1] = GameObject.nomNomRight;


    for(List<List<num>> line in field){
      for(List<num> column in line){
        if(column[0] == GameObject.point)
          coins++;
      }
    }

  }

  /**
   * Gives the number of the Dynamic Object of the Field
   * @param x column number
   * @param y row number
   * @return id of the Object
   */
  int getDynFieldObject(int x, int y){
    return field[x][y][1];
  }

  /**
   * Gives the number of the static Object of the Field
   * @param x column number
   * @param y row number
   * @return id of the Object
   */
  int getStaticFieldObject(int x, int y){
    return field[x][y][0];
  }

  /**
   * Kills ghost
   */
  void killGhost(int id) {
    this.killedGhosts.add(id);
  }
}