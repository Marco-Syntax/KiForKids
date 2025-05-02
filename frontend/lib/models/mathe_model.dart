/// MatheModel enthält Aufgabenbereiche für Mathematik, Klassen 5–13 Gymnasium (Dummy-Daten).

class MatheModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = [
    'Addition und Subtraktion',
    'Multiplikation und Division',
    'Textaufgaben',
    'Zahlenraum bis 1.000.000',
    'Geometrische Grundformen',
    'Längen, Gewichte, Zeit',
    'Brüche: Einführung',
    'Sachaufgaben',
    'Runden und Überschlagen',
    'Diagramme lesen',
  ];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Brüche: Rechnen',
    'Dezimalzahlen',
    'Prozentrechnung: Einführung',
    'Geometrie: Flächen und Umfang',
    'Negative Zahlen',
    'Gleichungen: einfache Formen',
    'Sachaufgaben mit Diagrammen',
    'Winkel messen',
    'Symmetrie',
    'Körper und Volumen',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Terme und Gleichungen',
    'Proportionalität',
    'Lineare Funktionen',
    'Geometrie: Dreiecke und Vierecke',
    'Brüche: Erweiterung',
    'Kreis: Umfang und Fläche',
    'Zufall und Wahrscheinlichkeit',
    'Daten und Diagramme',
    'Sachaufgaben: komplexer',
    'Wurzeln: Einführung',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'Quadratische Gleichungen',
    'Lineare Gleichungssysteme',
    'Funktionen: Einführung',
    'Geometrie: Pythagoras',
    'Kreisberechnungen',
    'Prozent- und Zinsrechnung',
    'Statistik: Mittelwerte',
    'Wahrscheinlichkeit: Erweiterung',
    'Sachaufgaben: Zinsen',
    'Trigonometrie: Grundlagen',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'Funktionen: Quadratisch',
    'Geometrie: Raumfiguren',
    'Trigonometrie: Sinus, Kosinus',
    'Wahrscheinlichkeit: Kombinatorik',
    'Statistik: Streuung',
    'Lineare Optimierung',
    'Sachaufgaben: Anwendungen',
    'Wachstumsprozesse',
    'Zinseszins',
    'Datenanalyse',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Analysis: Ableitung',
    'Integralrechnung: Einführung',
    'Geometrie: analytisch',
    'Funktionen: ganzrational',
    'Trigonometrie: Anwendungen',
    'Statistik: Regression',
    'Wahrscheinlichkeit: Binomial',
    'Sachaufgaben: komplex',
    'Lineare Algebra: Vektoren',
    'Abschlussprüfungsvorbereitung',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Analysis: Ableitung & Integral',
    'Funktionen: Exponential',
    'Vektorrechnung',
    'Geometrie: Raum',
    'Stochastik: Grundlagen',
    'Matrizenrechnung',
    'Komplexe Zahlen',
    'Statistik: Vertiefung',
    'Sachaufgaben: Abitur',
    'Abiturvorbereitung: Teil 1',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Analysis: Kurvendiskussion',
    'Integralrechnung: Anwendungen',
    'Vektorgeometrie: Vertiefung',
    'Stochastik: Wahrscheinlichkeitsverteilungen',
    'Matrizen: Anwendungen',
    'Komplexe Zahlen: Erweiterung',
    'Statistik: Hypothesentests',
    'Sachaufgaben: Abitur',
    'Abiturvorbereitung: Teil 2',
    'Mathematische Beweise',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Abiturvorbereitung: Analysis',
    'Abiturvorbereitung: Geometrie',
    'Abiturvorbereitung: Stochastik',
    'Funktionen: Abiturthemen',
    'Vektorrechnung: Abitur',
    'Statistik: Abitur',
    'Komplexe Zahlen: Abitur',
    'Mathematische Modelle',
    'Sachaufgaben: Abitur',
    'Mathematik in Naturwissenschaften',
  ];

  static Map<String, List<String>> aufgabenbereiche = {
    'Klasse 5': _klasse5,
    'Klasse 6': _klasse6,
    'Klasse 7': _klasse7,
    'Klasse 8': _klasse8,
    'Klasse 9': _klasse9,
    'Klasse 10': _klasse10,
    'Klasse 11': _klasse11,
    'Klasse 12': _klasse12,
    'Klasse 13': _klasse13,
  };
}
