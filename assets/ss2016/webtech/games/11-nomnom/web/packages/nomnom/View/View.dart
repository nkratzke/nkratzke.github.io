import 'dart:html';
import '../Model/GameObject.dart';
import '../Model/NomNom.dart';

class View{
  var gameMap = {
    0:"nomNomNeutral",
    1:"nomNomLeft",
    2:"nomNomRight",
    3:"nomNomDown",
    4:"nomNomUp",
    10:"block",
    11:"empty",
    20:"point",
    21:"cherryFruit",
    22:"orangeFruit",
    30:"raspberryFruit",
    31:"lemonFruit",
    40:"blueBonbon",
    41:"redBonbon",
    50:"greenBonbon",
    51:"yellowBonbon",
    100:"yellowGhost",
    101:"greenGhost",
    102:"blueGhost",
    103:"redGhost",
    104:"pinkGhost"
  };

  final score = querySelector('#score');
  final life = querySelector('#life');
  final level = querySelector('#level');
  final game = querySelector('#nomNomtable');
  final legende = querySelector('#legende');
  final buttons = querySelector('#buttons');


  List<List<HtmlElement>> htmlField;

  View(var gameField){
    this.createGameField(gameField);
    this.updateGameField(gameField);
    legende.innerHtml = "<img id=\"legende\" src=\"styles/pictures/legende.png\"></p>";
  }

  /**
   * Updates the GameField View in the Browser
   * @param gameField List of the Gamefield which we want to show
   */
  void updateGameField(List<List<List<int>>> gameField){
    for(int row = 0; row < gameField.length; row++){
      for(int col = 0; col < gameField[row].length;col++){
        final td = htmlField[row][col];
        if(td!=null){
          td.classes.clear();
          if(gameField[row][col][1] != GameObject.empty) {
            td.classes.add('${gameMap[gameField[row][col][1]]}');
          }
          else{
            td.classes.add('${gameMap[gameField[row][col][0]]}');
          }
        }
      }
    }
  }

  void createGameField(List<List<List<int>>> gameField){
    String table= "<table>";

    for(int row = 0; row<gameField.length;row++){
      table +="<tr>";
      for(int col = 0; col < gameField[row].length; col++){
        final assignment = gameMap[gameField[row][col][0]];
        final pos = "field_${row}_${col}";
        table += "<td id='$pos' class='$assignment'></td>";
      }
      table += "</tr>";
    }
    table += "</table>";

    game.innerHtml = table;

    htmlField = new List<List<HtmlElement>>(gameField.length);

    for(int row = 0; row < gameField.length;row++){
      htmlField[row] = [];
      for(int col = 0; col < gameField[row].length;col++){
        htmlField[row].add( game.querySelector("#field_${row}_${col}"));
      }
    }

    buttons.innerHtml = "<input id=\"upButton\" type=\"button\" value=\"UP\"/><br>" +
                      "<input id=\"leftButton\" type=\"button\" value=\"LEFT\"/>" +
                      "<input id=\"downButton\" type=\"button\" value=\"DOWN\"/>" +
                      "<input id=\"rightButton\" type=\"button\" value=\"RIGHT\"/>";

  }


  /**
   * Updates the Stats in the View
   * @param pm We need NomNom, because the Data which is needed is in there
   */
  void updateStats(NomNom pm){
    level.innerHtml = "Level:" + pm.level.toString();
    life.innerHtml = "Life:";
    for(int i = 0; i < pm.life; i++){
       life.innerHtml += "<span class=\"nomNomLeftLife\"></span>";
    }
    score.innerHtml = "Highscore: ${pm.points}";
  }

  /**
   * Function to Display the GameOver
   * @param gameField to Update the GameField One Last Time
   * @param pm to updates the Stats
   */
  void reachedLevelEnd(List<List<List<int>>> gameField, NomNom pm, bool gameOver){
    this.updateGameField(gameField);
    this.updateStats(pm);

    if(gameOver == true){
      game.innerHtml = "<p id=\"gameover\">GAME OVER</p>";
      level.remove();
      life.remove();
    }
    else{
      game.innerHtml = "<p id=\"leveledUp\">Congratulation you leveled UP!</p>"
          + "<input id=\"levelupButton\" type=\"button\" value=\"Next Level\">";
    }
  }
}
