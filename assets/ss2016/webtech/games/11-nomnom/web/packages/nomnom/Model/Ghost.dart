import 'Strategies/Strategy.dart';
import 'Types/Position.dart';
import 'GameObject.dart';
import 'GameTable.dart';

final String PATH = "parameter.json";

class Ghost extends GameObject{
  int points;
  int tick = 0;
  int ghostTickMax;
  int ghostTickTemp;
  Position pos;
  Strategy strategy;
  GameTable gametable;

  Ghost(int id, this.strategy, this.pos, this.gametable) : super(id){
    points = this.gametable.parameters["ghostPoints"];
    ghostTickMax = this.gametable.parameters["ghosttickMax"];
    ghostTickTemp = ghostTickMax;
  }

  void getEaten(){

  }

  /**
   * Tick the Ghost
   * @return Position of the Ghost
   */

  Position onTick(){
    tick++;
    if(tick >= ghostTickTemp){
      tick = 0;
      return move();
    }else{
      return this.pos;
    }
  }

  /**
   * Adjust speed of the ghost
   */
  void adjustSpeed(double speed){
    this.ghostTickTemp = (ghostTickTemp * speed).round();
  }

  /**
   * Set ghost to normal speed
   */
  void normSpeed(){
    this.ghostTickTemp = ghostTickMax;
  }

  /**
   * Move the Ghost to the next position
   * @return new Position of the Ghost
   */
  Position move(){
    this.gametable.field[this.pos.X][this.pos.Y][1] = GameObject.empty;
    Position npos = strategy.move(this.pos,this.gametable.nomNom.pos,this.gametable);

    if(detectCollision(npos)){
      this.handleCollision(npos);
    }
    else{
      this.gametable.field[npos.X][npos.Y][1] = this.id;
    }
    this.pos = npos;
    return this.pos;
  }

  bool detectCollision(Position pos){
    return this.gametable.field[pos.X][pos.Y][1] != GameObject.empty;
  }

  String toString(){
    return "Ghost #"+this.id.toString()+" at: "+this.pos.toString();
  }

  void handleCollision(Position pos) {
    int collisionId = this.gametable.field[pos.X][pos.Y][1];
    if(collisionId == GameObject.nomNomNeutral ||
      collisionId == GameObject.nomNomLeft ||
      collisionId == GameObject.nomNomRight ||
      collisionId == GameObject.nomNomUp ||
      collisionId == GameObject.nomNomDown){
      this.gametable.nomNom.collisionGhost(this.id);
    }
  }
}