import '../Model/Game.dart';
import 'dart:html';
import 'dart:async';

class View{
  Game _game;
  Animation _timeleft;


  View(this._game);

  /*
  Update das Level im View
   */
  void updateLevel(){
    Element nextLevelDiv = querySelector(".nextLevel");
    nextLevelDiv.innerHtml = "Level "+_game.level.toString();
    if (_game.level <= _game.levels.length) {
      nextLevelDiv.appendHtml( "<p>" + _game.levels[_game.level - 1]['name'] + "</p>");
    }
    nextLevelDiv.style.opacity = "1";
    new Timer(const Duration(seconds: 4), () => nextLevelDiv.style.opacity = "0");
  }

/*
Update die Legende(Lebensanzeige, Score und Level)
 */
  void updateLegend(){
    String life = "";
    for(int i = 0; i < _game.player.life; i++) {
      life += "<img src=\"./Images/itemlife.gif\" />";
    }
    querySelector("#gameLife").innerHtml = life;
    querySelector("#gameScore").innerHtml = _game.score.toString().padLeft(8, "0");
    querySelector("#gameLevel").innerHtml = "Level: " + _game.level.toString();
  }

  /*
  Update die Asteroiden auf dem Spielfeld
   */
  void updateAsteroids() {
    Element gameFieldDiv = querySelector("#gameField");
    for (var asteroid in _game.asteroids){
      var asteroidDiv = querySelector("#id_"+asteroid.elementId.toString());
      if (asteroid.valid < 1 && asteroidDiv != null){
        asteroidDiv.remove();
        gameFieldDiv.appendHtml("<div class='pointsMade' id='points_"+asteroid.elementId.toString()+"'>+"+asteroid.points.toString()+"</div>");
        Element pointsMade = querySelector("#points_"+asteroid.elementId.toString());
        pointsMade.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * asteroid.xPosition).toString() + "px";
        pointsMade.style.top = ((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - asteroid.yPosition)).toString() + "px";
        new Timer(const Duration(seconds: 4), () => pointsMade.remove());
      } else if (asteroid.valid > 0 && asteroidDiv == null){
        gameFieldDiv.appendHtml("<div class='asteroid' id='id_"+asteroid.elementId.toString()+"'></div>");
        asteroidDiv = querySelector("#id_"+asteroid.elementId.toString());
        double sizeInt = querySelector("#gameField").clientWidth / _game.gameFieldXLength;
        var size = sizeInt.toString()+"px";
        asteroidDiv.style.width = size;
        asteroidDiv.style.height = size;
        asteroidDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * asteroid.xPosition).toString() + "px";
        asteroidDiv.animate([{"top":((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - asteroid.yPosition)).toString() + "px"},
        {"top":(gameFieldDiv.clientHeight-sizeInt).toString()+"px"}], (((_game.options['tickRate'] * _game.levels[_game.level-1]['enemyMove'] )/1000)*(_game.gameFieldYLength-(_game.gameFieldYLength-asteroid.yPosition)))*1000);
      }
    }
  }


  /*
  Update die Die obere Leiste, die die Zeit angibt.
   */
  void updateTimeleft(){
    Element timeleftDiv = querySelector(".timeleft");
    _timeleft = timeleftDiv.animate([{"width": "100%"}, {"width":"0%"}], _game.levels[_game.level-1]['time']*1000);
  }


  /*
  Update den Status des Spiels zu Game Over.
   */
  void updateGameStatus(){
    Element gameFieldDiv = querySelector("#gameField");
    gameFieldDiv.innerHtml = "<div class='gameOver'>Game Over!<br>Points: "+_game.score.toString()+"<br><div class='link'><a class='zurück_button'>Zurück</a></div></div>";
    querySelectorAll(".zurück_button").onClick.listen((MouseEvent e) => updateMenu());
  }

  /*
  Update die gegnerischen Shuttles.
   */
  void updateEnemysShuttle() {
    Element gameFieldDiv = querySelector("#gameField");
    for (var enemy in _game.enemysShuttle){
      var enemyDiv = querySelector("#id_"+enemy.elementId.toString());
      if (enemy.valid < 1 && enemyDiv != null){
        enemyDiv.remove();
        gameFieldDiv.appendHtml("<div class='pointsMade' id='points_"+enemy.elementId.toString()+"'>+"+enemy.points.toString()+"</div>");
        Element pointsMade = querySelector("#points_"+enemy.elementId.toString());
        pointsMade.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * enemy.xPosition).toString() + "px";
        pointsMade.style.top = ((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - enemy.yPosition)).toString() + "px";
        print(((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - enemy.yPosition)).toString() + "px");
        new Timer(const Duration(seconds: 4), () => pointsMade.remove());
      } else if (enemy.valid > 0 && enemyDiv == null){
        gameFieldDiv.appendHtml("<div class='enemyShuttle' id='id_"+enemy.elementId.toString()+"'></div>");
        enemyDiv = querySelector("#id_"+enemy.elementId.toString());
        double sizeInt = (querySelector("#gameField").clientWidth / _game.gameFieldXLength);
        var size = sizeInt.toString()+"px";
        enemyDiv.style.width = size;
        enemyDiv.style.height = size;
        enemyDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * enemy.xPosition).toString() + "px";
        enemyDiv.animate([{"top":((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - enemy.yPosition)).toString() + "px"},
        {"top":(gameFieldDiv.clientHeight-sizeInt).toString()+"px"}], (((_game.options['tickRate'] * _game.levels[_game.level-1]['enemyMove'] )/1000)*(_game.gameFieldYLength-(_game.gameFieldYLength-enemy.yPosition)))*1000);
      }
    }
  }


  /*
  Update die Position des Spielers.
   */
  void updatePlayer() {
    Element playerShuttle = querySelector(".playerShuttle");
    if (playerShuttle == null){
      querySelector("#gameField").appendHtml("<div class='playerShuttle'></div>");
    }
    playerShuttle.style.left = ((querySelector("#gameField").clientWidth / _game.gameFieldXLength)*_game.player.xPosition).toString()+"px";
    var size = (querySelector("#gameField").clientWidth / _game.gameFieldXLength).toString()+"px";
    playerShuttle.style.width = size;
    playerShuttle.style.height = size;
    playerShuttle.style.transition = "0.2s";
  }


/*
Update die Schüsse der Gegner
 */
  void updateEnemyShot() {
    Element gameFieldDiv = querySelector("#gameField");
    for (var shot in _game.shots){
      var shotDiv = querySelector("#id_"+shot.elementId.toString());
      if (shot.valid < 1 && shotDiv != null){
        shotDiv.remove();
      } else if(shot.valid > 0 && shotDiv == null){
        gameFieldDiv.appendHtml("<div class='enemyShot' id='id_"+shot.elementId.toString()+"'></div>");
        shotDiv = querySelector("#id_"+shot.elementId.toString());
        shotDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * shot.xPosition).toString() + "px";
        double sizeInt = querySelector("#gameField").clientWidth / _game.gameFieldXLength;
        var size = sizeInt.toString()+"px";
        shotDiv.style.width = size;
        shotDiv.style.height = size;
        int level = (_game.level > _game.levels.length) ? _game.levels.length-1 : _game.level-1;
        if (((_game.options['tickRate'] * _game.levels[level]['enemyMoveShot'])*shot.yPosition) > 0){
          shotDiv.animate([{"top":((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - shot.yPosition)).toString() + "px"},
          {"top":(gameFieldDiv.clientHeight-sizeInt).toString()+"px"}], ((_game.options['tickRate'] * _game.levels[_game.level-1]['enemyMoveShot'])*shot.yPosition));
        }
      }
    }
  }

  /*
  Update die Schüsse des Spieler Shuttles
   */
  void updatePlayerShot() {
    Element gameFieldDiv = querySelector("#gameField");
    for (var shot in _game.playerShots){
      var shotDiv = querySelector("#id_"+shot.elementId.toString());
      if (shot.valid < 1 && shotDiv != null){
        print("removing shotdiv " + shot.elementId.toString());
        shotDiv.remove();
      } else if (shot.valid > 0 && shotDiv == null){
        print("adding shotdiv " + shot.elementId.toString() +" - "+ shot.valid.toString());
        gameFieldDiv.appendHtml("<div class='playerShot' id='id_"+shot.elementId.toString()+"'></div>");
        shotDiv = querySelector("#id_"+shot.elementId.toString());
        double sizeInt = querySelector("#gameField").clientWidth / _game.gameFieldXLength;
        var size = sizeInt.toString()+"px";
        shotDiv.style.width = size;
        shotDiv.style.height = size;
        shotDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * shot.xPosition).toString() + "px";
        shotDiv.animate([{"top":(((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - shot.yPosition))-sizeInt).toString() + "px"},
        {"top":"0px"}], (((_game.options['tickRate'] * _game.levels[_game.level-1]['playerMoveShot'] )/1000)*(_game.gameFieldYLength-shot.yPosition))*1000);
      } else if (shot.valid > 0 && shotDiv != null){
        shotDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * shot.xPosition).toString() + "px";
      }
    }
  }

  /*
  Update die Items
   */
  void updateItem() {
    Element gameFieldDiv = querySelector("#gameField");
    double sizeInt = querySelector("#gameField").clientWidth / _game.gameFieldXLength;
    var size = sizeInt.toString()+"px";
    for (var itemPoints in _game.points){
      var itemPointsDiv = querySelector("#id_"+itemPoints.elementId.toString());
      if (itemPoints.valid < 1 && itemPointsDiv != null){
        itemPointsDiv.remove();
      } else if (itemPoints.valid > 0 && itemPointsDiv == null){
        gameFieldDiv.appendHtml("<div class='Point' id='id_"+itemPoints.elementId.toString()+"'></div>");
        itemPointsDiv = querySelector("#id_"+itemPoints.elementId.toString());
        itemPointsDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * itemPoints.xPosition).toString() + "px";
        itemPointsDiv.style.width = size;
        itemPointsDiv.style.height = size;
        itemPointsDiv.animate([{"top":((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - itemPoints.yPosition)).toString() + "px"},
        {"top":(gameFieldDiv.clientHeight-sizeInt).toString()+"px"}], ((_game.options['tickRate'] * _game.levels[_game.level-1]['enemyMove'])*itemPoints.yPosition));
      }
    }
    for (var itemLife in _game.lifeupgrades){
      var lifeupgradesDiv = querySelector("#id_"+itemLife.elementId.toString());
      if (itemLife.valid < 1 && lifeupgradesDiv != null){
        lifeupgradesDiv.remove();
      } else if (itemLife.valid > 0 && lifeupgradesDiv == null){
        gameFieldDiv.appendHtml("<div class='itemLife' id='id_"+itemLife.elementId.toString()+"'></div>");
        lifeupgradesDiv = querySelector("#id_"+itemLife.elementId.toString());
        lifeupgradesDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * itemLife.xPosition).toString() + "px";
        lifeupgradesDiv.style.width = size;
        lifeupgradesDiv.style.height = size;
        lifeupgradesDiv.animate([{"top":((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - itemLife.yPosition)).toString() + "px"},
        {"top":(gameFieldDiv.clientHeight-sizeInt).toString()+"px"}], ((_game.options['tickRate'] * _game.levels[_game.level-1]['enemyMove'])*itemLife.yPosition));
      }
    }
    for (var aimbot in _game.aimbots){
      var aimbotDiv = querySelector("#id_"+aimbot.elementId.toString());
      if (aimbot.valid < 1 && aimbotDiv != null){
        aimbotDiv.remove();
      } else if (aimbot.valid > 0 && aimbotDiv == null){
        gameFieldDiv.appendHtml("<div class='aimbot' id='id_"+aimbot.elementId.toString()+"'></div>");
        aimbotDiv = querySelector("#id_"+aimbot.elementId.toString());
        aimbotDiv.style.left = ((gameFieldDiv.clientWidth / _game.gameFieldXLength) * aimbot.xPosition).toString() + "px";
        aimbotDiv.style.width = size;
        aimbotDiv.style.height = size;
       aimbotDiv.animate([{"top":((gameFieldDiv.clientHeight / _game.gameFieldYLength) * (_game.gameFieldYLength - aimbot.yPosition)).toString() + "px"},
        {"top":(gameFieldDiv.clientHeight-sizeInt).toString()+"px"}], ((_game.options['tickRate'] * _game.levels[_game.level-1]['enemyMove'])*aimbot.yPosition));
      }
    }
  }

  /*
  Erstelle das Gamefield und update dann die ersten Objekte.
   */
  void createGamefield() {
    querySelector("#gameField").innerHtml = "";
    var Shuttle = querySelector(".playerShuttle");
    if (Shuttle == null){
      querySelector("#gameField").appendHtml("<div class='playerShuttle'></div>");
    }
    if (querySelector(".nextLevel") == null){
      querySelector("#gameField").appendHtml("<a class='nextLevel'>Level 1</a>");
    }
    updatePlayer();
    updateTimeleft();
    updateLevel();
  }

  /*
 Update die View zu einem Pausescreen.
   */

  void updatePauseGame(){
    _timeleft.pause();
    querySelector("#gameField").innerHtml = "<span class='movePhone'>Please hold your phone vertical.</span>";
  }

  /*
  Wechsle vom Hauptmenü zur HowTo page.
   */
  void updateHowto(){
    querySelector(".howto_page").style.display = "inherit";
    querySelector(".index_page").style.display = "none";
  }

  /*
  Wechsle vom Hauptmenü zur About page.
   */
  void updateAbout(){
    querySelector(".about_page").style.display = "inherit";
    querySelector(".index_page").style.display = "none";
  }

  /*
  Wechsle von About/Howto zum Hauptmenü
   */
  void updateMenu(){
    querySelector(".about_page").style.display = "none";
    querySelector(".howto_page").style.display = "none";
    querySelector(".game_page").style.display = "none";
    querySelector(".index_page").style.display = "inherit";
  }

  /*
  Spiel wird fortgesetzt. Updated die View zum Spielfeld
   */
  void updateUnpauseGame(){
    _timeleft.play();
    querySelector(".movePhone").remove();
    updateAll();
  }

  /*
  Wechsle zu der Gamepage vom Hauptmenü
   */
  void updateGameField(){
    querySelector(".game_page").style.display = "inherit";
    querySelector(".index_page").style.display = "none";
  }

  /*
  Updated alles im View
   */
  void updateAll(){
    createGamefield();
    updateAsteroids();
    updateEnemyShot();
    updateEnemysShuttle();
    updateItem();
    updatePlayerShot();
    updateLegend();
  }

}