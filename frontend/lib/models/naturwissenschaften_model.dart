/// NaturwissenschaftenModel enthält Aufgabenbereiche für Naturwissenschaften, Klassen 5–13 Gymnasium (Dummy-Daten).

class NaturwissenschaftenModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = [
    'Lebewesen & Sinne',
    'Pflanzen & Tiere',
    'Wasser & Wetter',
    'Stoffe & Materialien',
    'Energie & Umwelt',
  ];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Zellen & Mikroskopie',
    'Körper & Gesundheit',
    'Licht & Magnetismus',
    'Stoffkreisläufe',
    'Umwelt & Energie',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Ökosysteme',
    'Elektrizität & Energie',
    'Chemische Reaktionen',
    'Körperbau & Organe',
    'Wetter & Klima',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'Genetik & Vererbung',
    'Chemische Bindungen',
    'Mechanik & Bewegung',
    'Optik & Wärme',
    'Nachhaltigkeit',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'Evolution & Anpassung',
    'Organische Chemie',
    'Mechanik & Energie',
    'Radioaktivität',
    'Ökologie & Umwelt',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Vererbung & Gentechnik',
    'Chemische Reaktionen',
    'Elektrizität & Magnetismus',
    'Nachhaltige Entwicklung',
    'Physik: Bewegung & Kraft',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Molekularbiologie',
    'Organische Chemie',
    'Dynamik & Felder',
    'Radioaktivität & Atomphysik',
    'Ökologie: Global',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Molekulargenetik',
    'Thermodynamik',
    'Quantenphysik',
    'Klimawandel & Umwelt',
    'Forschung & Technik',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Biologie: Abiturthemen',
    'Chemie: Abiturthemen',
    'Physik: Abiturthemen',
    'Ökologie: Abitur',
    'Technik & Wissenschaft',
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
