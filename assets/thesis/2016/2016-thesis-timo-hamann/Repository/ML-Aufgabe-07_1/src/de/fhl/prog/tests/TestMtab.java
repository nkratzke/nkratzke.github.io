package de.fhl.prog.tests;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import de.fhl.prog.aufgabe_07_1.Aufgabe_07_1;

/**
 * Test zur Aufgabe 7.1
 * 
 * @author Nane Kratzke, Timo Hamann
 */
public class TestMtab {

  @Test
  public void testEinMalEins() {
    assertEquals("1", Aufgabe_07_1.mtab(1, 1));
  }

  @Test
  public void testEinZeilig() {
    assertEquals("1\t2\t3", Aufgabe_07_1.mtab(3, 1));
  }

  @Test
  public void testEinSpaltig() {
    assertEquals("1\n2", Aufgabe_07_1.mtab(1, 2));
  }

  @Test
  public void testLeer() {
    assertEquals("", Aufgabe_07_1.mtab(0, 0));
  }

  @Test
  public void testLeereSpalte() {
    assertEquals("", Aufgabe_07_1.mtab(1, 0));
  }

  @Test
  public void testLeereZeile() {
    assertEquals("", Aufgabe_07_1.mtab(0, 1));
  }

  @Test
  public void testNegativeParameter() {
    assertEquals("", Aufgabe_07_1.mtab(-1, -1));
  }

  @Test
  public void test4x5() {
    assertEquals(
        "1\t2\t3\t4\n" + "2\t4\t6\t8\n" + "3\t6\t9\t12\n" + "4\t8\t12\t16\n" + "5\t10\t15\t20",
        Aufgabe_07_1.mtab(4, 5));
  }

  @Test
  public void test13x3() {
    assertEquals("1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t11\t12\t13\n"
        + "2\t4\t6\t8\t10\t12\t14\t16\t18\t20\t22\t24\t26\n"
        + "3\t6\t9\t12\t15\t18\t21\t24\t27\t30\t33\t36\t39", Aufgabe_07_1.mtab(13, 3));
  }

}
