import 'Game.dart';
import 'Row.dart';
import 'static/Enum.dart';
import 'cards/Card.dart';

/*representation of the field of the play game phase*/
class Field{
  /*reference to the game class this field is used in*/
  Game game;
  /*list of rows owned by the player*/
  Map<ROWTYPE, Row> rowsPlayer;
  /*list of rows owned by the AI*/
  Map<ROWTYPE, Row> rowsAI;

  Field(Game s){
    rowsPlayer = new Map<ROWTYPE, Row>();
    rowsAI = new Map<ROWTYPE, Row>();
    initRows();
    game = s;
  }

  /*summing up the players and AIs AP and setting the corresponding
  * attributes of the player and AI object*/
  void updatedSummedAP(){
    game.player.summedAP = 0;
    game.ai.summedAP = 0;

    rowsPlayer.values.forEach((Row r){
      game.player.summedAP += r.sumAP();
    });

    rowsAI.values.forEach((Row r){
      game.ai.summedAP += r.sumAP();
    });
  }

  /*clears all rows on the field by putting all cards from all rows
  * in the corresponding player/AI discard pile and removing all
  * weather effects from each row*/
  void rowsClearAll(){
    _clearRowsAI();
    _clearRowsPlayer();
  }
  void _clearRowsPlayer(){
    rowsPlayer.values.forEach((Row r){
      r.getCards().forEach((Card k){
        k.owner != null ?
        game.player.discard.add(k) :
        game.ai.discard.add(k);
      });
      r.clearCardsAndWeather();
    });
  }
  void _clearRowsAI(){
    rowsAI.values.forEach((Row r){
      r.getCards().forEach((Card k){
        k.owner != null ?
        game.player.discard.add(k) :
        game.ai.discard.add(k);
      });
      r.clearCardsAndWeather();
    });
  }

  /*resetting the fields state by reinitialising all rows*/
  void reset(){
    initRows();
  }
  void initRows(){
    _initRowsPlayer();
    _initRowsAI();
  }
  void _initRowsPlayer(){
    rowsPlayer.putIfAbsent(ROWTYPE.CLOSE, ()=>new Row(ROWTYPE.CLOSE, ROWTYPEDIST.PLAYERCLOSE, this, PLAYERTYPE.PLAYER));
    rowsPlayer.putIfAbsent(ROWTYPE.DIST, ()=>new Row(ROWTYPE.DIST, ROWTYPEDIST.PLAYERDIST, this, PLAYERTYPE.PLAYER));
    rowsPlayer.putIfAbsent(ROWTYPE.SIEGE, ()=>new Row(ROWTYPE.SIEGE, ROWTYPEDIST.PLAYERSIEGE, this, PLAYERTYPE.PLAYER));
  }
  void _initRowsAI(){
    rowsAI.putIfAbsent(ROWTYPE.SIEGE, ()=>new Row(ROWTYPE.SIEGE, ROWTYPEDIST.AISIEGE, this, PLAYERTYPE.AI));
    rowsAI.putIfAbsent(ROWTYPE.DIST,()=>new Row(ROWTYPE.DIST, ROWTYPEDIST.AIDIST, this, PLAYERTYPE.AI));
    rowsAI.putIfAbsent(ROWTYPE.CLOSE,()=>new Row(ROWTYPE.CLOSE, ROWTYPEDIST.AICLOSE, this, PLAYERTYPE.AI));
  }
}