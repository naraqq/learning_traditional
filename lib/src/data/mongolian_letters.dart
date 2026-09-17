import '../models/character_definition.dart';
import 'chart_letters.dart';

// Preserve the six existing IDs and their lesson order for saved progress.
// All geometry now comes from the supplied chart; remaining forms follow
// its row order, including alternatives. No initial ng form is invented.
final CharacterDefinition letterNInitial = _byId('n_initial');
final CharacterDefinition letterNMedial = _byId('n_medial');
final CharacterDefinition letterBInitial = _byId('b_initial');
final CharacterDefinition letterMInitial = _byId('m_initial');
final CharacterDefinition letterLInitial = _byId('l_initial');
final CharacterDefinition letterGInitial = _byId('g_initial');

CharacterDefinition _byId(String id) =>
    chartLetters.firstWhere((c) => c.id == id);

final List<CharacterDefinition> mongolianLetters = [
  letterNInitial,
  letterNMedial,
  letterBInitial,
  letterMInitial,
  letterLInitial,
  letterGInitial,
  ...chartLetters.where(
    (c) => !const {
      'n_initial',
      'n_medial',
      'b_initial',
      'm_initial',
      'l_initial',
      'g_initial',
    }.contains(c.id),
  ),
];

/// A chart may use the same shape for several sounds. Return all matching
/// labels so a context-free quiz never marks a valid reading as wrong.
List<CharacterDefinition> recognitionAnswersFor(
  CharacterDefinition question,
  List<CharacterDefinition> letters,
) {
  final answers = <String, CharacterDefinition>{question.cyrillic: question};
  if (question.recognitionGroup != null) {
    for (final letter in letters) {
      if (letter.recognitionGroup == question.recognitionGroup) {
        answers.putIfAbsent(letter.cyrillic, () => letter);
      }
    }
  }
  return answers.values.toList();
}

/// One dictionary entry: a base letter together with its available
/// positional forms, each already resolved to a single representative shape
/// even when the chart also records an alternate for that position.
class LetterDictionaryEntry {
  const LetterDictionaryEntry({
    required this.cyrillic,
    required this.transliteration,
    required this.forms,
  });

  final String cyrillic;
  final String transliteration;
  final List<CharacterDefinition> forms;
}

const _dictionaryFormOrder = [
  CharacterForm.initial,
  CharacterForm.medial,
  CharacterForm.final_,
  CharacterForm.isolated,
];

/// Groups every character form by base letter (e.g. `n_initial`,
/// `n_medial`, `n_medial_alternate`, `n_final` all become one entry for
/// "n") so a dictionary view can show one card per letter with up to one
/// glyph per position, preferring the primary (non-alternate) shape.
List<LetterDictionaryEntry> buildLetterDictionary(
  List<CharacterDefinition> letters,
) {
  final order = <String>[];
  final byBase = <String, List<CharacterDefinition>>{};
  for (final letter in letters) {
    final base = letter.id.split('_').first;
    (byBase[base] ??= []).add(letter);
    if (byBase[base]!.length == 1) order.add(base);
  }
  return [
    for (final base in order) _dictionaryEntryFor(byBase[base]!),
  ];
}

LetterDictionaryEntry _dictionaryEntryFor(List<CharacterDefinition> group) {
  final forms = <CharacterDefinition>[];
  for (final form in _dictionaryFormOrder) {
    final candidates = group.where((c) => c.form == form).toList();
    if (candidates.isEmpty) continue;
    forms.add(
      candidates.firstWhere(
        (c) => !c.alternate,
        orElse: () => candidates.first,
      ),
    );
  }
  return LetterDictionaryEntry(
    cyrillic: group.first.cyrillic,
    transliteration: group.first.transliteration,
    forms: forms,
  );
}
