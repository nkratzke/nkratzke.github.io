import 'Strategy.dart';
import '../Types/Position.dart';
import '../GameTable.dart';

/**
 * Runaway-Strategy implementation
 */
class EscapeStrategy extends Strategy{
  /**
   * Chooses next position farthest away of pacman
   */
  Position move(Position currPos, Position pacmanPos, GameTable gt){
    List<Position> possible = gt.adjPos(currPos);

    // calculate 2d-distances (excluding square root, as dist >= 1 )
    List<int> distances = new List();
    possible.forEach((p) => distances.add((p.x-pacmanPos.x)*(p.x-pacmanPos.x) +
        (p.y-pacmanPos.y)*(p.y-pacmanPos.y)));

    // get farthest distance
    int highest = distances.reduce((a,b) => a<b?b:a);
    // return position of farthest distance
    return possible.elementAt(distances.indexOf(distances.firstWhere((a)=>a==highest)));
  }
}