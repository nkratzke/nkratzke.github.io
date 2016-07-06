import 'field.dart';

/**
 * Map construction
 */
class LevelGen{

  int dim;
  final rng;
  Field field;

  Map _mapJson;

  LevelGen(this.rng, this.dim,this._mapJson){}


  /**
   * Parses map by pacman level from json file
   */
  void parseJsonMap(int level){
    List<String> map = _mapJson["level"][level-1]["map"];
    this.field = new Field(map.length,map.length);

    for(int i = 0; i<map.length;i++){
      for(int j = 0; j<map[0].length;j++){
        this.field.setField(i,j,int.parse(map[i][j]));
      }
    }
  }

}

