import 'dart:html';
import 'package:ML_Web_Erathosthenes/ML_Web_Erathosthenes.dart';

/**
 * This is the starting point for client side processing.
 */
main() {

  final int NMAX = 100000;

  DivElement error_div = querySelector('#error');
  DivElement prims_div = querySelector('#prims');
  InputElement input = querySelector('#n');

  prims_div.innerHtml = "<em>Und hier könnten Ihre Primzahlen stehen ...</em>";
  int n = 0;

  input.onInput.listen((ev) {
    error_div.innerHtml = "";

    n = int.parse(ev.target.value, onError: (s) {
      error_div.innerHtml = "Bitte geben Sie eine positive ganze Zahl > 0 ein!";
      prims_div.innerHtml = "";
      return 0;
    });

    if (n <= 0) {
      error_div.innerHtml = "Bitte geben Sie eine positive ganze Zahl > 0 ein!";
      prims_div.innerHtml = "";
      n = 0;
    }

    if (n >= NMAX) {
      error_div.innerHtml = "Wir berechnen nur Primzahlen bis $NMAX!";
      prims_div.innerHtml = "";
      n = NMAX;
    }

    prims_div.innerHtml = toHtmlTable(prims(n), 13);
  });
}