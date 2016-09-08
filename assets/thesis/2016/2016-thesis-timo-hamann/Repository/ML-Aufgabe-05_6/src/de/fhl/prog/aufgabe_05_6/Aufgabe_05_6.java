package de.fhl.prog.aufgabe_05_6;

import java.util.Scanner;

/**
 * Musterloesung zu Aufgabe 5.6 (Schaltjahr)
 * 
 * @author Nane Kratzke
 *
 */
public abstract class Aufgabe_05_6 {

  /**
   * Hauptprogramm.
   * 
   * @param args Kommandozeilenparameter (werden nicht ausgewertet).
   */
  public static void main(String[] args) {
    Scanner in = new Scanner(System.in);
    System.out.print("Bitte geben sie eine beliebige Jahreszahl ein: ");
    int jahr = in.nextInt();

    boolean durch4Teilbar = jahr % 4 == 0;
    boolean durch100Teilbar = jahr % 100 == 0;
    boolean durch400Teilbar = jahr % 400 == 0;

    boolean schaltjahr = durch4Teilbar && (!durch100Teilbar || durch400Teilbar);

    System.out.println(jahr + (schaltjahr ? " ist ein Schaltjahr." : " ist kein Schaltjahr."));

    in.close();
  }
}
