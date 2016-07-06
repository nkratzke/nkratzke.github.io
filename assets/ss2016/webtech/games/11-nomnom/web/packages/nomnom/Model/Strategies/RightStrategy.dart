import 'Strategy.dart';
import '../Types/Position.dart';
import 'dart:math';
import '../GameTable.dart';

/**
 * Always-Right-Strategy implementation
 */
class RightStrategy extends Strategy{

  Random _rng;
  Position _last;

  RightStrategy(this._rng){
  }

  /**
   * Calculates and moves to right-direction based on last position
   */
  Position move(Position currPos, Position pacmanPos, GameTable gt){
    List<Position> positions = gt.adjPos(currPos);

    // Start with random direction
    if(_last == null){
      _last = currPos;
      return positions.elementAt(_rng.nextInt(positions.length));
    }

    Position movement,left,straight,right;

    // going back is always an option
    movement = _last;

    // calculate movement vector
    Position moveVector = new Position(currPos.x - _last.x,currPos.y - _last.y);

    // check for vertical movement
    if(moveVector.x==0){
      right = new Position(currPos.x - (moveVector.y * -1), currPos.y);
      straight = new Position(currPos.x, currPos.y + moveVector.y);
      left = new Position(currPos.x - moveVector.y, currPos.y);
    }
    else{
      right = new Position(currPos.x, currPos.y - moveVector.x);
      straight = new Position(currPos.x+moveVector.x, currPos.y);
      left = new Position(currPos.x - moveVector.y, currPos.y - (moveVector.x * -1));
    }

    // possible movements ordered by priority
    if(positions.contains(left))
      movement = left;
    if(positions.contains(straight))
      movement = straight;
    if(positions.contains(right))
      movement = right;

    _last = currPos;
    return movement;
  }
}