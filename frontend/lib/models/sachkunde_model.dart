/// SachkundeModel enthält Aufgabenbereiche für Sachkunde, Klassen 5–13 Gymnasium (Dummy-Daten).

class SachkundeModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = [
    'Heimische Bäume',
    'Tiere im Wald',
    'Wetter und Klima',
    'Umwelt und Nachhaltigkeit',
    'Wasser: Kreislauf',
    'Boden und Pflanzen',
    'Jahreszeiten',
    'Nahrungsketten',
    'Landschaften in Deutschland',
    'Energiequellen',
  ];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Weltreligionen',
    'Karten lesen',
    'Leben im Mittelalter',
    'Städte und Dörfer',
    'Wasser: Nutzung und Schutz',
    'Bodenarten',
    'Klima: global',
    'Tiere in anderen Lebensräumen',
    'Umweltschutz: Recycling',
    'Energie sparen',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Erfindungen und Technik',
    'Energie: erneuerbar und fossil',
    'Klimawandel',
    'Wirtschaftskreislauf',
    'Landwirtschaft',
    'Verkehr und Mobilität',
    'Rohstoffe',
    'Naturschutzgebiete',
    'Wasser: Weltweit',
    'Umweltprobleme',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'Politik: Demokratie',
    'Industrialisierung',
    'Globalisierung',
    'Ernährung und Gesundheit',
    'Klimaschutz',
    'Ressourcenmanagement',
    'Stadtentwicklung',
    'Migration',
    'Wirtschaft: Angebot und Nachfrage',
    'Umweltethik',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'Menschenrechte',
    'Internationale Organisationen',
    'Wirtschaft: Global',
    'Klimapolitik',
    'Energiepolitik',
    'Gesellschaftlicher Wandel',
    'Technikfolgen',
    'Umweltrecht',
    'Nachhaltige Entwicklung',
    'Konsum und Verantwortung',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Politische Systeme',
    'Wirtschaftssysteme',
    'Umweltpolitik',
    'Technik und Gesellschaft',
    'Klimawandel: Ursachen und Folgen',
    'Ressourcen: Nutzung und Schutz',
    'Gesundheitssysteme',
    'Soziale Gerechtigkeit',
    'Globalisierung: Chancen und Risiken',
    'Zukunft der Arbeit',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Internationale Beziehungen',
    'Wirtschaft: Märkte und Handel',
    'Umwelt: globale Herausforderungen',
    'Technik: Innovationen',
    'Gesellschaft: Wandel und Werte',
    'Klimaschutz: internationale Abkommen',
    'Ressourcenmanagement: global',
    'Gesundheit: globale Aspekte',
    'Soziale Bewegungen',
    'Zukunftsszenarien',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Politik: internationale Konflikte',
    'Wirtschaft: Entwicklungsländer',
    'Umwelt: nachhaltige Strategien',
    'Technik: Digitalisierung',
    'Gesellschaft: Diversität',
    'Klimawandel: Anpassung',
    'Ressourcen: globale Verteilung',
    'Gesundheit: Prävention',
    'Soziale Innovationen',
    'Zukunft: nachhaltige Entwicklung',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Abiturvorbereitung: Politik',
    'Abiturvorbereitung: Wirtschaft',
    'Abiturvorbereitung: Umwelt',
    'Technik: Zukunftstrends',
    'Gesellschaft: Herausforderungen',
    'Klimawandel: globale Lösungen',
    'Ressourcen: Abiturthemen',
    'Gesundheit: globale Perspektiven',
    'Soziale Verantwortung',
    'Nachhaltigkeit: Abitur',
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
