part of spacepeons;

/**
 * Viewklasse
 * Der View bekommt vom Controller alle relevanten Daten und stellt diese Optisch dar
 */

class SpacePeonsView {
  /**
   * Variablen anlegen
   */
  var _gui;
  var _table;
  int _fadeCounter;
  ImageElement _hero;
  ImageElement _hero_doubleShot;
  ImageElement _schuss;
  ImageElement _schussEnemy;
  ImageElement _enemy1;
  ImageElement _mothership;
  ImageElement _hpUp;
  ImageElement _barrier;
  ImageElement _moreShot;
  ImageElement _extraPoints;
  ImageElement _barricade;
  ImageElement _missile;
  ImageElement _moreDmg;

  /**
   * Constructor
   * Variablen initialisieren, Bilder einlesen
   * und die Bilder der Größe des Gidsystems anpassen, damit kein Bild über seine Zelle/n guckt
   */
  SpacePeonsView() {
    _fadeCounter = -100;
    _table = querySelector('table') as TableElement;
    _gui = querySelector("#gui");
    _schuss = new ImageElement(src: "../pictures/schuss.png");
    _schuss.style.height = "16px";
    _schussEnemy = new ImageElement(src: "../pictures/schussEnemy.png");
    _schussEnemy.style.height = "16px";
    _mothership = new ImageElement(src: "../pictures/mothership.png");
    _mothership.style.width = "48px";
    _mothership.style.height = "32px";
    _enemy1 = new ImageElement(src: "../pictures/peon.png");
    _enemy1.style.width = "16px";
    _hpUp = new ImageElement(src: "../pictures/hpUp.png");
    _hpUp.style.width = "16px";
    _barrier = new ImageElement(src: "../pictures/shield.png");
    _barrier.style.width = "16px";
    _moreShot = new ImageElement(src: "../pictures/laser-blast.png");
    _moreShot.style.width = "16px";
    _extraPoints = new ImageElement(src: "../pictures/diamond.png");
    _extraPoints.style.width = "16px";
    _hero = new ImageElement(src: "../pictures/player.png");
    _hero.style.width = "48px";
    _hero.style.height = "32px";
    _hero_doubleShot = new ImageElement(src: "../pictures/player_doubleShot.png");
    _hero_doubleShot.style.width = "48px";
    _hero_doubleShot.style.height = "32px";
    _barricade = new ImageElement(src: "../pictures/whiteblock.png");
    _barricade.style.height = "16px";
    _missile = new ImageElement(src: "../pictures/missile.png");
    _missile.style.width = "16px";
    _moreDmg = new ImageElement(src: "../pictures/moreDmg.png");
    _moreDmg.style.width = "16px";
  }

  /**
   * Das Spielfeld inform der Tabelle aufbauen
   * col: die Anzahl der Spalten
   * rows: die Anzahl der Reihen
   */
  void buildField(int col, int rows) {
    querySelector("#button_container").style.display = "none";
    querySelector("#title").style.display = "none";
    _gui.style.visibility = "visible";
    _table.children.clear();                                       //cleart die Tabelle, da buildField auch mehrmals in einem Spielverlauf aufgerufen werden kann
    var tBody2 = _table.createTBody();
    var row;
    for (int i = 0; i < (rows + 1) * col; i++) {
      if (i % (col + 1) == 0) {
        row = tBody2.addRow();
      } else {
        row.addCell();
      }
    }
    _table = querySelectorAll('td');                             //schreibt alle 'td' Elemente in die Tabele um jeden ansprechen zu können
  }

  /**
   * Hauptfunktion des Views, das Feld wird mit den Errechneten Daten, inform eines Arrays, dargestellt.
   * In diesem Array befinden sich int-Werte die jeweils ein Objekt darstellen, indem für jeden Wert ein Bild angezeigt wird
   * field: das Feld als Array, jedes Feld hat ein Wert im Array
   * guidaten: die Daten für die _gui als Array übergeben, um Übersichtlichkeit zu bewahren
   */
  void updateView(var field, var guidaten) {
    int i = 0;
    _gui.innerHtml = "<br><br>Level:<br>" +
        guidaten[0].toString() +
        " " +
        guidaten[1] +
        "<br><br>Punkte:<br>" +
        guidaten[2].toString() +
        "<br><br>Leben:<br>" +
        guidaten[3].toString() +
        "<br><br>Schaden:<br>" +
        guidaten[4].toString();

    for (var c in field) {
      switch (c) {
        case 0:
          _table[i].style.backgroundColor = "transparent";
          _table[i].children.clear();
          break;
        case 1:
          if (_table[i].children.isEmpty)
            _table[i].children.add(_schuss.clone(true));
          break;
        case 2:
          if (_table[i].children.isEmpty)
            _table[i].children.add(_schussEnemy.clone(true));
          break;
        case 3:
          break;
        case 4:
          _table[i].children.add(_mothership.clone(true));
          break;
        case 5:
          if (_table[i].children.isEmpty)
            _table[i].children.add(_hero.clone(true));
          break;
        case 6:
          _table[i].children.add(_enemy1.clone(true));
          break;
        case 7:
          _table[i].children.add(_extraPoints.clone(true));
          break;
        case 8:
          _table[i].children.add(_moreShot.clone(true));
          break;
        case 9:
          _table[i].children.add(_hpUp.clone(true));
          break;
        case 10:
          _table[i].children.add(_barrier.clone(true));
          break;
        case 11:
          if (_table[i].children.isEmpty)
            _table[i].children.add(_barricade.clone(true));
          break;
        case 12:
          if (_table[i].children.isEmpty)
            _table[i].children.add(_hero_doubleShot.clone(true));
          break;
        case 13:
          if (_table[i].children.isEmpty)
            _table[i].children.add(_missile.clone(true));
          break;
        case 14:
          if (_table[i].children.isEmpty)
            _table[i].children.add(_moreDmg.clone(true));
          break;
      }
      i++;
    }
  }

  /**
   * Der GameOverscreen wird angezeigt und sämmtliche andere Elemente werden ausgeblendet
   * punkte: die Punkte die der Spieler erreicht hat
   */
  void gameOver(int punkte) {
    querySelector("#gui").style.display = "none";
    querySelector('table').style.display = "none";
    querySelector('#gameoverscreen').style.display = "block";
    querySelector('#punkte').innerHtml = "Punkte: " + punkte.toString();
  }

  /**
   * Der GameWonscreen wird angezeigt und sämmtliche andere Elemente werden ausgeblendet
   * punkte: die Punkte die der Spieler erreicht hat
   */
  void gameWon(int punkte) {
    querySelector("#gui").style.display = "none";
    querySelector('table').style.display = "none";
    querySelector('#gameoverscreen').style.display = "block";
    (querySelector('#gameover') as ImageElement).src = "../pictures/Win.png";
    querySelector('#punkte').innerHtml = "Punkte: " + punkte.toString();
  }

  /**
   * Der Highscorescreen wird angezeigt und sämmtliche anderen Elemente werden ausgeblendet
   * highscore: der vom Gamekey errechnete highscore
   */
  void showHighscore(var highscore) {
    querySelector("#button_container").style.display = "none";
    querySelector("#title").style.display = "none";
    querySelector("#gameoverscreen").style.display = "none";
    querySelector('#gameoverscreen').style.visibility = "hidden";
    querySelector('#cancelHighscore').style.display = "block";
    var list = highscore
        .map((entry) => "${entry['name']}: ${entry['score']} <br>")
        .join("");
    querySelector('#highscore').innerHtml = list;
  }

  /**
   * die Animation des Startmenüs
   * e: der Timer der die animation triggert
   */
  void fadeInStart(Timer e) {
    querySelector("#title").style.marginTop = _fadeCounter.toString() + "px";
    querySelector("#button_container").style.marginTop = (420 - _fadeCounter).toString() + "px";
    _fadeCounter += 5;
    if (_fadeCounter > 130) {          //der Wert gibt an wieweit gefaded wird
      e.cancel();
      _fadeCounter = -100;
    }
  }

  /**
   * neue Zeilen in das Statusfenster einfügen
   * s: die einzutragene Zeile als String
   */
  void updateStatus(String s) {
    querySelector("#statusWindow").innerHtml = s;
  }

  /**
   * sämtliche Elemente mit einem halbtransparenten Bild überdecken um einen Pausestatus zu verdeutlichen
   */
  void pause() {
    querySelector("body").style.backgroundImage = "url('../pictures/halbtransparent.png')";
    querySelector("pauseText").style.display = "inline";
  }

  /**
   * das halbtransparenten Bild wegnehmen, damit das Spiel weiter laufen kann
   */
  void unpause() {
    querySelector("body").style.backgroundImage = "";
    querySelector("pauseText").style.display = "none";
  }

  void changePlaymode(){
    if(querySelector("#playmode").innerHtml == "Arcade"){
      querySelector("#playmode").innerHtml = "Endless";
    }
    else{
      querySelector("#playmode").innerHtml = "Arcade";
    }
  }

  void changeDifficult(){
    var dif = querySelector("#difficulty");
    switch(dif.innerHtml){
      case "Leicht":  dif.innerHtml = "Mittel";
      break;
      case "Mittel":  dif.innerHtml = "Schwer";
      break;
      case "Schwer":  dif.innerHtml = "Leicht";
      break;
    }
  }
}

