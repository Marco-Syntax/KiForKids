/// SachkundeModel enthält Aufgabenbereiche für Sachkunde, Klassen 5–13 Gymnasium (Dummy-Daten).

class SachkundeModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = [
    'Bäume & Pflanzen',
    'Tiere & Lebensräume',
    'Wetter & Jahreszeiten',
    'Wasser & Umwelt',
    'Energiequellen',
  ];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Religionen & Kulturen',
    'Karten & Orientierung',
    'Mittelalter & Geschichte',
    'Natur & Lebensräume',
    'Umweltschutz',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Technik & Erfindungen',
    'Energieformen',
    'Klimawandel',
    'Landwirtschaft & Ressourcen',
    'Verkehr & Mobilität',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'Politik & Demokratie',
    'Industrie & Arbeit',
    'Ernährung & Gesundheit',
    'Globalisierung',
    'Klimaschutz',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'Menschenrechte',
    'Internationale Politik',
    'Wirtschaft & Globalisierung',
    'Nachhaltigkeit',
    'Technik & Gesellschaft',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Politik & Gesellschaft',
    'Wirtschaftssysteme',
    'Umwelt & Ressourcen',
    'Soziales & Gesundheit',
    'Zukunft der Arbeit',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Internationale Beziehungen',
    'Globaler Handel',
    'Technologische Innovationen',
    'Soziale Bewegungen',
    'Klimaschutzabkommen',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Konflikte & Friedenspolitik',
    'Weltwirtschaft',
    'Digitale Transformation',
    'Diversität & Gesellschaft',
    'Nachhaltige Entwicklung',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Politik: Abitur',
    'Wirtschaft: Abitur',
    'Umwelt: Abitur',
    'Gesellschaft & Verantwortung',
    'Zukunft & Nachhaltigkeit',
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
