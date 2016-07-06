import 'Strategy.dart';
import '../Types/Position.dart';
import '../GameTable.dart';

/**
 * Follow-Strategy impementation
 */
class FollowStrategy extends Strategy{

  FollowStrategy();

  /**
   * Chooses next position closest to pacman
   */
  Position move(Position currPos, Position pacmanPos, GameTable gt ){
    return findPosBfs(currPos,pacmanPos,gt);
  }

  /**
   * Deprecated, calculates shortest way using absolut distance
   */
  Position findNearestAbs(Position currPos, Position pacmanPos, GameTable gt ){
    List<Position> positions = gt.adjPos(currPos);
    List<int> distances = new List();
    positions.forEach((p) => distances.add((p.x-pacmanPos.x)*(p.x-pacmanPos.x) +
        (p.y-pacmanPos.y)*(p.y-pacmanPos.y)));
    int lowest = distances.reduce((a,b) => a<b?a:b);
    return positions.elementAt(distances.indexOf(distances.firstWhere((a)=>a==lowest)));
  }


  /**
   * Breadth fist search
   */
  Position findPosBfs(Position src, Position dest,GameTable gt){

    List<Position> possible = gt.adjPos(src);

    // If next to pacman use this position
    if(possible.contains(dest))
      return dest;

    // If Ghost on pacman use random position
    if(src == dest){
      possible.shuffle();
      return possible.first;
    }


    bool found = false;
    List<Position> queue = new List();
    Map<Position,Position> parent = new Map();
    List<Position> visited = new List();

    // Starting with source position
    visited.add(src);
    possible.forEach((a){
      queue.add(a);
      parent.putIfAbsent((a),()=>src);
    });

    // while there are more positions on die field and pacman not found
    while(queue.isNotEmpty && !found){
      Position curr = queue.removeAt(0);
      if(curr!=dest){
        visited.add(curr);
        gt.adjPos(curr).forEach((p){
          if(!visited.contains(p)){
            queue.add(p);
            parent.putIfAbsent(p,()=>curr);
          }
        });
      }
      else{
        found = true;
      }
    }
    Position curr = parent[dest];

    // Find first position of path to pacman
    while(parent[curr] != src){
      curr = parent[curr];
    }

    return curr;
  }
}