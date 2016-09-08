package de.fhl.prog.aufgabe_07_1;

/**
 * Ausgabe einer Multiplikationstabelle.
 * 
 * @author Nane Kratzke
 */
public abstract class Aufgabe_07_1 {

  /**
   * Erzeugt eine Multiplikationstabelle fuer zwei ganzzahlige positive Zahlen.
   * 
   * @param z1 erste ganzzahlige positive Zahl
   * @param z2 zweite ganzzahlige positive Zahl
   * @return Zeichenkette mit der Multiplikationstabelle fuer die Zahlen <code>z1</code> und
   *         <code>z2</code>
   */
  public static String mtab(final int z1, final int z2) {
    String ret = "";
    for (int i = 1; i <= z2; i++) {
      for (int j = 1; j <= z1; j++) {
        ret += (i * j) + (j < z1 ? "\t" : "");
      }
      ret += i < z2 ? "\n" : "";
    }
    return ret;
  }

}
