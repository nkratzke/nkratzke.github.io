import '../Types/Position.dart';
import '../GameTable.dart';

/**
 * Base-Strategy
 */
abstract class Strategy{
  /**
   * Movement function
   */
  Position move(Position currPos, Position pacmanPos, GameTable gt){
    return gt.adjPos(currPos).removeAt(0);
  }
}