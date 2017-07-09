
class Position{
  // Position in der X-Achse
  int _xPosition;
  int get xPosition => _xPosition;
  // Position in der Y-Achse
  int _yPosition;
  int get yPosition => _yPosition;

  Position(this._xPosition, this._yPosition);


/*
Setze die neue X Position
 */
  void setXPosition(int x) {
    this._xPosition = x;
  }

  /*
  Setze die neue Y Position
   */
  void setYPosition(int y) {
    this._yPosition = y;
  }
}