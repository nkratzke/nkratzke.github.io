package de.fhl.prog.aufgabe_13_1;

/**
 * Aufgabe 13.1
 * 
 * @author Nane Kratzke
 *
 */
public abstract class Aufgabe_13_1 {

  /**
   * Erzeugt eine Zeichenkette indem ein Binaerbaum in inorder Strategie durchlaufen wird.
   * 
   * @param n Wurzel des zu durchlaufenden Binaerbaums.
   * @return Zeichenkette in inorder Reihenfolge der Knoten des Binaerbaums
   */
  public static String inorder(Node n) {
    if (n == null) {
      return "";
    }
    return inorder(n.left) + n + inorder(n.right);
  }

  /**
   * Erzeugt eine Zeichenkette indem ein Binaerbaum in preorder Strategie durchlaufen wird.
   * 
   * @param n Wurzel des zu durchlaufenden Binaerbaums.
   * @return Zeichenkette in preorder Reihenfolge der Knoten des Binaerbaums
   */
  public static String preorder(Node n) {
    if (n == null) {
      return "";
    }
    return n + preorder(n.left) + preorder(n.right);
  }

  /**
   * Erzeugt eine Zeichenkette indem ein Binaerbaum in postorder Strategie durchlaufen wird.
   * 
   * @param n Wurzel des zu durchlaufenden Binaerbaums.
   * @return Zeichenkette in postorder Reihenfolge der Knoten des Binaerbaums
   */
  public static String postorder(Node n) {
    if (n == null) {
      return "";
    }
    return postorder(n.left) + postorder(n.right) + n;
  }

  /**
   * Hauptprogramm.
   * 
   * @param args Kommandozeilenparameter (werden nicht ausgewertet)
   */
  public static void main(String[] args) {

    Node tree = new Node(5, new Node(3, new Node(1, null, null), new Node(4, null, null)),
        new Node(8, new Node(6, null, null), new Node(9, null, null)));

    System.out.println(inorder(tree));
    System.out.println(preorder(tree));
    System.out.println(postorder(tree));

  }

}
