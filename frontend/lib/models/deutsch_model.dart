/// DeutschModel enthält Aufgabenbereiche für Deutsch, Klassen 5–13 Gymnasium (Dummy-Daten).

class DeutschModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = [
    'Wortarten bestimmen',
    'Satzarten erkennen',
    'Nomen in Einzahl/Mehrzahl',
    'Verben im Präsens',
    'Adjektive steigern',
    'Groß- und Kleinschreibung',
    's/ss/ß unterscheiden',
    'Leseverständnis: Kurzer Text',
    'Satzbau ordnen',
    'Wörtliche Rede markieren',
  ];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Zeitformen: Präsens, Präteritum',
    'Direkte und indirekte Rede',
    'Satzglieder bestimmen',
    'Kommasetzung bei Aufzählungen',
    'Textzusammenfassung schreiben',
    'Wortfelder und Synonyme',
    'Leseverständnis: längerer Text',
    'Rechtschreibregeln erweitern',
    'Adverbien erkennen',
    'Erzählperspektiven unterscheiden',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Nebensätze erkennen',
    'Relativsätze bilden',
    'Textanalyse: Kurzgeschichte',
    'Wortschatz erweitern',
    'Steigerung von Adjektiven',
    'Satzbau: Haupt- und Nebensatz',
    'Erörterung: Aufbau',
    'Rechtschreibung: schwierige Wörter',
    'Lyrik: Gedichtformen',
    'Wörtliche Rede und indirekte Rede',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'Interpretation literarischer Texte',
    'Sachtexte analysieren',
    'Argumentationsstruktur erkennen',
    'Erörterung: dialektisch',
    'Satzgefüge und Satzreihe',
    'Rechtschreibung: Kommaregeln',
    'Sprachliche Mittel erkennen',
    'Charakterisierung schreiben',
    'Drama: Aufbau und Analyse',
    'Medienkompetenz: Zeitungsartikel',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'Literaturgeschichte: Epochen',
    'Analyse von Balladen',
    'Erörterung: freie Themen',
    'Textgebundene Erörterung',
    'Rhetorische Mittel',
    'Interpretation von Dramen',
    'Sprachwandel',
    'Rechtschreibung: Groß-/Kleinschreibung',
    'Lyrik: Analyse moderner Gedichte',
    'Medienkritik',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Analyse von Novellen',
    'Argumentation: Pro und Contra',
    'Textinterpretation: Sachtexte',
    'Literaturgeschichte: Moderne',
    'Essay schreiben',
    'Sprachliche Analyse',
    'Rechtschreibung: Zeichensetzung',
    'Drama: Figurenkonstellation',
    'Lyrik: Vergleich',
    'Medien: Fake News erkennen',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Literatur des 20. Jahrhunderts',
    'Interpretation komplexer Texte',
    'Erörterung gesellschaftlicher Themen',
    'Sprachliche Varietäten',
    'Essay: Aufbau und Stil',
    'Rhetorik und Argumentation',
    'Rechtschreibung: Sonderfälle',
    'Drama: Analyse klassischer Werke',
    'Lyrik: Symbolik',
    'Medienanalyse',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Literaturtheorie: Grundbegriffe',
    'Interpretation: Epik, Lyrik, Dramatik',
    'Analyse politischer Reden',
    'Sprachentwicklung',
    'Essay: literarische Themen',
    'Rhetorische Analyse',
    'Rechtschreibung: Prüfungsvorbereitung',
    'Drama: moderne Stücke',
    'Lyrik: Epochenvergleich',
    'Medien: Sprache in der Werbung',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Abiturvorbereitung: Textanalyse',
    'Vergleichende Literaturbetrachtung',
    'Interpretation: Abiturtexte',
    'Sprachphilosophie',
    'Essay: gesellschaftliche Fragestellungen',
    'Rhetorik: Analyse und Anwendung',
    'Rechtschreibung: Abiturtraining',
    'Drama: Interpretation im Kontext',
    'Lyrik: Abiturthemen',
    'Medien: Sprache und Manipulation',
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
