package de.fhl.prog.test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import org.junit.After;
import org.junit.Before;

/**
 * Abstrakte Basisklasse zum Testen mit Konsoleninteraktion.
 * 
 * @see #writeToConsole(String)
 * @see #readFromConsole()
 * 
 * @author Timo Hamann
 */
public abstract class AbstractConsoleTest {

  private final ByteArrayOutputStream outByteStream = new ByteArrayOutputStream();

  @Before
  public void setUp() {
    System.setOut(new PrintStream(outByteStream));
  }

  @After
  public void cleanUp() {
    System.setIn(null);
    System.setOut(null);
  }

  /**
   * Schreibt einen Text in die Konsoleneingabe.
   * 
   * @param text Text
   */
  protected void writeToConsole(String text) {
    System.setIn(new ByteArrayInputStream(text.getBytes()));
  }

  /**
   * Liest einen Text von der Konsolenausgabe.
   * 
   * @return Text
   */
  protected String readFromConsole() {
    return new String(outByteStream.toByteArray());
  }

}
