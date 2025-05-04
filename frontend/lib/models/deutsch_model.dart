/// DeutschModel enthält Aufgabenbereiche für Deutsch, Klassen 5–13 Gymnasium (Dummy-Daten).

class DeutschModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = ['Wortarten', 'Satzarten', 'Rechtschreibung', 'Leseverständnis', 'Satzbau'];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Zeitformen',
    'Satzglieder & Satzbau',
    'Rechtschreibung',
    'Leseverständnis',
    'Schreiben & Zusammenfassen',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Nebensätze & Relativsätze',
    'Textanalyse',
    'Wortschatz & Stil',
    'Rechtschreibung',
    'Erörterung',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'Textinterpretation',
    'Erörterung & Argumentation',
    'Satzbau & Sprachliche Mittel',
    'Rechtschreibung',
    'Medienkompetenz',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'Literaturgeschichte',
    'Erörterung & Analyse',
    'Lyrik & Rhetorik',
    'Sprachentwicklung',
    'Medienanalyse',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Textinterpretation',
    'Argumentation & Essay',
    'Sprachliche Analyse',
    'Rechtschreibung',
    'Medienkritik',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Literatur & Interpretation',
    'Gesellschaftliche Themen',
    'Sprachvariationen & Stil',
    'Rechtschreibung',
    'Rhetorik & Argumentation',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Literaturtheorie',
    'Interpretation & Analyse',
    'Sprachentwicklung',
    'Essay & Rhetorik',
    'Medienanalyse',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Abiturvorbereitung: Analyse',
    'Vergleichende Literatur',
    'Sprachphilosophie',
    'Essay & Rhetorik',
    'Medien & Sprache',
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
