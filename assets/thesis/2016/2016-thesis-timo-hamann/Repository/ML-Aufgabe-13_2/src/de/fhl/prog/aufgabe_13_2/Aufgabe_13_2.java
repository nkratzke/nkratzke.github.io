package de.fhl.prog.aufgabe_13_2;

import de.fhl.prog.aufgabe_13_1.Node;

/**
 * Aufgabe 13.2. Eclipse-Projekt ist abhaengig von Musterloesung zu Aufgabe 13.1. Daher bitte
 * ML-Aufgabe-13_1 im buildpath eintragen!
 * 
 * @author Nane Kratzke
 *
 */
public abstract class Aufgabe_13_2 {

  /**
   * Zaehlt die Knoten in einem Binaerbaum.
   * 
   * @param tree Wurzelknotens des Binaerbaums
   * @return Anzahl an Knoten im Binaerbaum mit der Wurzel <code>tree</code>
   */
  public static int countNodes(Node tree) {
    if (tree == null) {
      return 0;
    }
    return 1 + countNodes(tree.left) + countNodes(tree.right);
  }

  /**
   * Zaehlt die Kanten in einem Binaerbaum.
   * 
   * @param tree Wurzelknotens des Binaerbaums
   * @return Anzahl an Kanten im Binaerbaum mit der Wurzel <code>tree</code>
   */
  public static int countEdges(Node tree) {
    if (tree == null) {
      return 0;
    }
    return (tree.left != null ? 1 : 0) + (tree.right != null ? 1 : 0) + countEdges(tree.left)
        + countEdges(tree.right);

    // Oder knapper
    // return countNodes(tree) - 1;
  }

  /**
   * Bestimmt die Hoeher eines Binaerbaums.
   * 
   * @param tree Wurzelknotens des Binaerbaums
   * @return Hoehe des Binaerbaums mit der Wurzel <code>tree</code>
   */
  public static int height(Node tree) {
    if (tree == null) {
      return 0;
    }
    return 1 + Math.max(height(tree.left), height(tree.right));
  }

}
