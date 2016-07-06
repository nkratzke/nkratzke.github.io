import 'Types/Position.dart';
import 'Types/Direction.dart';
import 'GameObject.dart';
import 'GameTable.dart';
import '../Debug.dart';

class NomNom extends GameObject{
  int life;
  int level;
  int points = 0;
  bool eatableGhosts = false;
  Position pos;
  GameTable myTable;
  int currDirection;
  int desiredDirection;
  int tick = 0;
  int nomNomTickMax;
  int nomNomTickTemp;

  NomNom(this.myTable) : super(0) {
    this.level = this.myTable.parameters["level"];
    this.life = this.myTable.parameters["life"];
    this.nomNomTickMax = this.myTable.parameters["nomNomtickMax"];
    this.nomNomTickTemp = this.nomNomTickMax;
  }

  /**
   * Getter for life
   */
  int get Life => life;

  /**
   * Getter for level
   */
  int get Level => level;

  /**
   * Getter for points
   */
  int get Points => points;

  /**
   * Getter for position
   */
  Position get Pos => pos;

  /**
   * Tests if NomNom is allowed to move and go to a different direction if possible
   */
  void onTick() {
    tick++;
    if (tick >= nomNomTickTemp) {
      tick = 0;

      if(this.desiredDirection != this.currDirection)
        updateDirection();

      switch (this.currDirection) {
        case Direction.UP:
          this.moveUp();
          break;
        case Direction.DOWN:
          this.moveDown();
          break;
        case Direction.LEFT:
          this.moveLeft();
          break;
        case Direction.RIGHT:
          this.moveRight();
      }
    }
  }

  void updateDirection(){
    if(hasFreePosition(this.desiredDirection))
      this.currDirection = this.desiredDirection;
  }

  bool hasFreePosition(int direction){
    if(direction==Direction.UP)
      return this.myTable.field[pos.X-1][pos.Y][0]!=GameObject.block;
    if(direction==Direction.DOWN)
      return this.myTable.field[pos.X+1][pos.Y][0]!=GameObject.block;
    if(direction==Direction.LEFT)
      return this.myTable.field[pos.X][pos.Y-1][0]!=GameObject.block;
    if(direction==Direction.RIGHT)
      return this.myTable.field[pos.X][pos.Y+1][0]!=GameObject.block;
    return false;
  }

  /**
   * Change the current position to left
   */
  void moveLeft() {
    moveToPos(new Position(pos.X,pos.Y-1),GameObject.nomNomLeft);
  }

  /**
   * Change the current position to right
   */
  void moveRight() {
    moveToPos(new Position(pos.X,pos.Y+1),GameObject.nomNomRight);
  }

  /**
   * Change the current position to up
   */
  void moveUp() {
    moveToPos(new Position(pos.X-1,pos.Y),GameObject.nomNomUp);
  }

  /**
   * Change the current position to down
   */
  void moveDown() {
    moveToPos(new Position(pos.X+1,pos.Y),GameObject.nomNomDown);
  }

  /**
   * move NomNom to the new position and detects collision
   * @param nPos new Position to move
   * @param nomNomDirection Direction where NomNom want to move
   */
  void moveToPos(Position nPos, int nomNomDirection){

    if(detectCollisionWithDynamic(nPos)){
      int id = this.myTable.field[nPos.X][nPos.Y][1];

      this.collisionGhost(id);
    }

    if(detectCollisionWithStatic(nPos)){
      int id = this.myTable.field[nPos.X][nPos.Y][0];

      if(id == GameObject.block){
        return;
      }

      var obj = this.myTable.object[id];
      obj.onPickUp(this);
      if(obj.id == GameObject.point) myTable.coins--;

      this.myTable.field[nPos.X][nPos.Y][0] = GameObject.empty;
    }

    this.myTable.field[pos.X][pos.Y][1] = GameObject.empty;
    this.pos = nPos;
    this.myTable.field[pos.X][pos.Y][1] = nomNomDirection;
  }

  /**
   * Detects if collision is a ghost
   * @param id id of the Object
   * @return true if ghost, false if not a ghost
   */
  bool collisionGhost(int id){
    if( id >= 100 ){
      if(eatableGhosts){
        this.modifyPoints(myTable.object[id].points);
        myTable.killGhost(id);
        return true;
      } else {
        this.looseLife();
        return true;
      }
    }
    return false;
  }

  /**
   * Test if NomNom is blocked by a block
   * @param pos pos where NomNom wants to go
   * @return bool TRUE is blocked, FALSE is not blocked
   */
  bool isBlocked(Position pos){
    return this.myTable.field[pos.X][pos.Y][0] == GameObject.block;
  }

  /**
   * reset points of NomNom
   */
  void resetPoints() {
    points = 0;
  }

  /**
   * increase the points
   * @param points points which modify NomNom points
   */
  void modifyPoints(int points) {
    if(points <= 0){
      this.points > -points ? this.points += points : this.points = 0;
    } else {
      this.points += points;
    }
  }

  /**
   * decrease life
   */
  void looseLife() {
    if(this.life <= 1)
      myTable.gameOver=true;
    else
      life--;
  }

  /**
   * reset life of NomNom
   */
  void resetLife() {
    life = this.myTable.parameters["life"];
  }

  /**
   * increase level of NomNom
   */
  void levelUp() {
    level++;
  }

  /**
   * reset level of NomNom
   */
  void resetLevel() {
    level = this.myTable.parameters["level"];
  }


  /**
   * Detects if collision is with a dynamic object
   * @param pos Position of the Object
   * @return returns if is not an Empty
   */
  bool detectCollisionWithDynamic(Position pos){
    return this.myTable.field[pos.X][pos.Y][1] != GameObject.empty;
  }

  /**
   * Detects if collision is with a dynamic object
   * @param pos Position of the Object
   * @return returns if is not an Empty
   */
  bool detectCollisionWithStatic(Position pos){
    return this.myTable.field[pos.X][pos.Y][0] != GameObject.empty;
  }

/**
 * Adjust the speed on Pick up
 * @param id object
 * @param speed speedvalue
 */
  void adjustSpeed(int id, double speed){
    if(id < GameObject.blueBonbon){
      myTable.addEvent(id);
      this.nomNomTickTemp = (nomNomTickTemp * speed).round();
    }else{
      myTable.adjGhostSpeed(id, speed);
    }
  }

  /**
   * Set to normal speed
   */
  void normSpeed(){
    this.nomNomTickTemp = nomNomTickMax;
  }

  /**
   * Switch state of eatable
   */
  void switchEatAble(){
    this.eatableGhosts = !eatableGhosts;
  }


  /**
   * trigger Specialevents
   */
void doSpecial(int id){
  if(id == GameObject.greenBonbon){
    myTable.addEvent(id);
    if(!eatableGhosts) {
      switchEatAble();
    }
  }else if(id == GameObject.yellowBonbon){
    myTable.genNewGhost();
  }else if(id == GameObject.lemon){
    myTable.coins = 0;
    this.levelUp();
  }
}
}