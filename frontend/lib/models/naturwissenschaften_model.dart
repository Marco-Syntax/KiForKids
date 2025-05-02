/// NaturwissenschaftenModel enthält Aufgabenbereiche für Naturwissenschaften, Klassen 5–13 Gymnasium (Dummy-Daten).

class NaturwissenschaftenModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = [
    'Photosynthese',
    'Wasser-Kreislauf',
    'Einfache Experimente',
    'Körper & Sinne',
    'Tiere und Pflanzen',
    'Luft und Atmung',
    'Stoffe im Alltag',
    'Wetterbeobachtung',
    'Energiequellen',
    'Umwelt schützen',
  ];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Zellen und Mikroskopie',
    'Stoffkreisläufe',
    'Energie: Formen und Umwandlung',
    'Sinne des Menschen',
    'Wachstum und Entwicklung',
    'Wasser: Eigenschaften',
    'Licht und Schatten',
    'Magnetismus',
    'Wärmelehre',
    'Umwelt: Recycling',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Ökosysteme',
    'Chemische Reaktionen',
    'Körperbau des Menschen',
    'Elektrizität: Grundlagen',
    'Wetter und Klima',
    'Pflanzen: Aufbau und Funktion',
    'Stofftrennung',
    'Energie: erneuerbar',
    'Wellen und Schall',
    'Umweltprobleme',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'Genetik: Grundlagen',
    'Chemische Bindungen',
    'Mechanik: Kräfte und Bewegung',
    'Elektrizität: Stromkreise',
    'Ökologie: Kreisläufe',
    'Säuren und Basen',
    'Wärmelehre: Vertiefung',
    'Licht: Optik',
    'Umwelt: Klimawandel',
    'Technik: Anwendungen',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'Evolution',
    'Organische Chemie',
    'Mechanik: Arbeit und Energie',
    'Elektrizität: Anwendungen',
    'Ökologie: Populationen',
    'Redoxreaktionen',
    'Atommodelle',
    'Radioaktivität',
    'Umwelt: Schadstoffe',
    'Technik: Energiegewinnung',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Genetik: Vererbung',
    'Chemische Gleichgewichte',
    'Mechanik: Impuls und Drehmoment',
    'Elektrizität: Wechselstrom',
    'Ökologie: Nachhaltigkeit',
    'Säuren-Basen-Reaktionen',
    'Wärmelehre: Energieübertragung',
    'Licht: Wellenoptik',
    'Umwelt: Ressourcen',
    'Technik: Innovationen',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Molekularbiologie',
    'Organische Chemie: Vertiefung',
    'Mechanik: Dynamik',
    'Elektrizität: Felder',
    'Ökologie: globale Aspekte',
    'Redoxreaktionen: Anwendungen',
    'Atomphysik',
    'Radioaktivität: Anwendungen',
    'Umwelt: globale Probleme',
    'Technik: Forschung',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Genetik: Molekulare Grundlagen',
    'Chemische Thermodynamik',
    'Mechanik: Schwingungen',
    'Elektrizität: Quantenphysik',
    'Ökologie: Klimawandel',
    'Säuren-Basen-Gleichgewichte',
    'Wärmelehre: Thermodynamik',
    'Licht: Quantenoptik',
    'Umwelt: Nachhaltigkeit',
    'Technik: Zukunft',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Abiturvorbereitung: Biologie',
    'Abiturvorbereitung: Chemie',
    'Abiturvorbereitung: Physik',
    'Genetik: Abiturthemen',
    'Chemie: Abiturthemen',
    'Physik: Abiturthemen',
    'Ökologie: Abitur',
    'Umwelt: Abitur',
    'Technik: Abitur',
    'Naturwissenschaften: interdisziplinär',
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
