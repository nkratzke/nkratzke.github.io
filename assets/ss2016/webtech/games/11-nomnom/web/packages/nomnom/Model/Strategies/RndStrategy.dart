import 'Strategy.dart';
import '../Types/Position.dart';
import 'dart:math';
import '../GameTable.dart';

/**
 * Random-Strategy implementation
 */
class RndStrategy extends Strategy{

  Random rng;

  RndStrategy(this.rng){

  }

  /**
   * Choose random movement
   */
  Position move(Position currPos, Position pacmanPos, GameTable gt){
    List<Position> possible = gt.adjPos(currPos);
    return possible.elementAt(rng.nextInt(possible.length));
  }
}