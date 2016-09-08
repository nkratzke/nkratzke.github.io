package de.fhl.prog.aufgabe_13_1;

/**
 * Knoten eines Binaerbaums.
 * 
 * @author Nane Kratzke
 *
 */
public class Node {

  /**
   * Referenz auf linken Ast.
   */
  public Node left;

  /**
   * Referenz auf rechten Ast.
   */
  public Node right;

  /**
   * Wert des Knotens.
   */
  public int value;

  /**
   * Konstruktor zum Erzeugen eines Knotens.
   * 
   * @param v Wert des Knotens
   * @param l Referenz auf linken Ast des Knotens
   * @param r Referenz auf rechten Ast des Knotens
   */
  public Node(int v, Node l, Node r) {
    value = v;
    left = l;
    right = r;
  }

  /**
   * Erzeugt eine textuelle Repraesentation eines Knotens.
   * 
   * @return Knoten wird als sein Wert repraesentiert.
   */
  public String toString() {
    return value + " ";
  }

}
