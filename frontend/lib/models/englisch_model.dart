/// EnglischModel enthält Aufgabenbereiche für Englisch, Klassen 5–13 Gymnasium (Dummy-Daten).

class EnglischModel {
  // Themen für Klasse 5
  static const List<String> _klasse5 = [
    'Wichtige Vokabeln: Alltag & Schule',
    'Fragen im Simple Present',
    'Verneinung im Simple Present',
    'Einfachen Satz bilden (SVO)',
    'Unbestimmte Artikel: a / an',
    'Fragewörter (who, what, where...)',
    'Pluralformen von Nomen',
    'Zahlen & Uhrzeiten verstehen',
    'Leseverständnis kurzer Text',
    'Dialog ergänzen / verstehen',
  ];

  // Themen für Klasse 6
  static const List<String> _klasse6 = [
    'Simple Past: Bildung und Gebrauch',
    'Fragen im Simple Past',
    'Unregelmäßige Verben',
    'Vergleichsformen von Adjektiven',
    'Leseverständnis: längerer Text',
    'Dialoge schreiben',
    'Possessivpronomen',
    'Some/any verwenden',
    'Ortsangaben (prepositions of place)',
    'Kurzgeschichten verstehen',
  ];

  // Themen für Klasse 7
  static const List<String> _klasse7 = [
    'Present Perfect: Bildung und Gebrauch',
    'If-Sätze Typ 1',
    'Gerund und Infinitiv',
    'Leseverständnis: Sachtexte',
    'Wortschatz: Reisen & Freizeit',
    'Relativsätze',
    'Adverbien',
    'Dialoge erweitern',
    'Textzusammenfassung',
    'Fragen mit question tags',
  ];

  // Themen für Klasse 8
  static const List<String> _klasse8 = [
    'If-Sätze Typ 2',
    'Passiv: Bildung und Gebrauch',
    'Direkte und indirekte Rede',
    'Leseverständnis: Zeitungsartikel',
    'Wortschatz: Umwelt & Gesellschaft',
    'Textanalyse: Kurzgeschichten',
    'Adjektivendungen',
    'Präpositionen der Zeit',
    'Meinungen ausdrücken',
    'Essay schreiben',
  ];

  // Themen für Klasse 9
  static const List<String> _klasse9 = [
    'If-Sätze Typ 3',
    'Reported Speech',
    'Leseverständnis: literarische Texte',
    'Wortschatz: Politik & Geschichte',
    'Textanalyse: Gedichte',
    'Nominalisierung',
    'Satzbau: komplexe Sätze',
    'Diskussionen führen',
    'Zusammenfassung längerer Texte',
    'Präsentationen halten',
  ];

  // Themen für Klasse 10
  static const List<String> _klasse10 = [
    'Textanalyse: Sachtexte',
    'Essay: Argumentation',
    'Leseverständnis: wissenschaftliche Texte',
    'Wortschatz: Wissenschaft & Technik',
    'Sprachmittlung',
    'Formelle Briefe schreiben',
    'Diskussionen: Pro und Contra',
    'Präsentationen: Aufbau',
    'Grammatik: Wiederholung',
    'Abschlussprüfungsvorbereitung',
  ];

  // Themen für Klasse 11
  static const List<String> _klasse11 = [
    'Analyse literarischer Werke',
    'Essay: gesellschaftliche Themen',
    'Leseverständnis: anspruchsvolle Texte',
    'Wortschatz: Literatur & Kunst',
    'Sprachliche Mittel analysieren',
    'Debatten führen',
    'Präsentationen: Literatur',
    'Grammatik: komplexe Strukturen',
    'Kreatives Schreiben',
    'Abiturvorbereitung: Teil 1',
  ];

  // Themen für Klasse 12
  static const List<String> _klasse12 = [
    'Analyse politischer Reden',
    'Essay: globale Themen',
    'Leseverständnis: Fachtexte',
    'Wortschatz: Politik & Wirtschaft',
    'Sprachmittlung: komplexe Inhalte',
    'Präsentationen: Fachthemen',
    'Grammatik: Sonderfälle',
    'Kreatives Schreiben: Kurzgeschichten',
    'Abiturvorbereitung: Teil 2',
    'Diskussionen: internationale Themen',
  ];

  // Themen für Klasse 13
  static const List<String> _klasse13 = [
    'Abiturvorbereitung: Textanalyse',
    'Vergleichende Textinterpretation',
    'Essay: Abiturthemen',
    'Leseverständnis: Abiturtexte',
    'Wortschatz: Abiturrelevant',
    'Präsentationen: Abitur',
    'Grammatik: Abiturtraining',
    'Kreatives Schreiben: Abitur',
    'Diskussionen: Abiturthemen',
    'Sprachmittlung: Abitur',
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
