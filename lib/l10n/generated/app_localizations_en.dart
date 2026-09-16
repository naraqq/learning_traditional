// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Uigarjin — Mongolian Script';

  @override
  String get mongolianScript => 'Mongolian Script';

  @override
  String get splashSubtitle => 'Master Vertical Writing';

  @override
  String get homeTab => 'Home';

  @override
  String get learnTab => 'Learn';

  @override
  String get reviewTab => 'Review';

  @override
  String get settingsTab => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageDescription =>
      'Choose the language used throughout the app.';

  @override
  String get chooseLanguageTitle => 'Choose your language';

  @override
  String get chooseLanguageSubtitle =>
      'You can always change this later in Settings.';

  @override
  String get englishLanguage => 'English';

  @override
  String get mongolianLanguage => 'Монгол';

  @override
  String get lockedLesson => 'Complete the letter before this one first.';

  @override
  String get loadError =>
      'Your saved progress could not be opened. Please try again.';

  @override
  String get saveError =>
      'Changes could not be saved on this device. Tap retry.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get retrySave => 'Retry save';

  @override
  String get dailyEyebrow => 'A LITTLE PRACTICE, EVERY DAY';

  @override
  String get homeTitle => 'A living script.\nA new beginning.';

  @override
  String get homeDescription =>
      'Make room for a few quiet moments.\nDiscover traditional Mongolian, one stroke at a time.';

  @override
  String get formsPracticed => 'Forms practiced';

  @override
  String get lessonsFinished => 'Lessons finished';

  @override
  String get learningJourney => 'Your learning journey';

  @override
  String get viewAll => 'View all';

  @override
  String get collectionEyebrow => 'INTRODUCTORY COLLECTION';

  @override
  String get firstStrokes => 'First strokes';

  @override
  String unitSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letter forms · Guided handwriting',
      one: '1 letter form · Guided handwriting',
    );
    return '$_temp0';
  }

  @override
  String get collectionProgress => 'Collection progress';

  @override
  String percentSpoken(int percent) {
    return '$percent percent';
  }

  @override
  String percentExplored(int percent) {
    return '$percent% explored';
  }

  @override
  String get exploreLetters => 'Explore the letters';

  @override
  String get nextStepEyebrow => 'YOUR NEXT SMALL STEP';

  @override
  String get allCompleteTitle => 'Look how far\nyou’ve come.';

  @override
  String get firstLetterTitle => 'Meet your\nfirst letter.';

  @override
  String get keepPracticingTitle => 'Keep your\npractice growing.';

  @override
  String get allCompleteDescription =>
      'Revisit your letters and refine each stroke.';

  @override
  String get reviewLetters => 'Review your letters';

  @override
  String get beginPractice => 'Begin your practice';

  @override
  String get continueLearning => 'Continue learning';

  @override
  String get journeyEyebrow => 'YOUR LEARNING JOURNEY';

  @override
  String get learnDescription =>
      'Watch the movement, follow the guide, and find your rhythm. Each lesson opens the next.';

  @override
  String get reviewEyebrow => 'MAKE IT FAMILIAR';

  @override
  String get reviewTitle => 'Return. Refine.\nRemember.';

  @override
  String get reviewDescription =>
      'Revisit the forms you’ve practiced. Your best tracing score is saved for each letter.';

  @override
  String get emptyReviewTitle => 'Your practice grows here';

  @override
  String get emptyReviewDescription =>
      'Finish your first lesson to add a letter to your personal review collection.';

  @override
  String get findFirstLesson => 'Find your first lesson';

  @override
  String get settingsEyebrow => 'YOUR OWN PACE';

  @override
  String get settingsTitle => 'Practice, your way.';

  @override
  String get settingsDescription =>
      'Small adjustments for a more comfortable writing experience.';

  @override
  String get beginnerGuidance => 'Beginner guidance';

  @override
  String get beginnerDescription => 'More forgiving stroke tolerances.';

  @override
  String get polishStrokes => 'Polish accepted strokes';

  @override
  String get polishDescription =>
      'Gently align accepted ink with the guide. Turn off to see your own handwriting.';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get hapticDescription => 'A subtle response as you write.';

  @override
  String get offlineTitle => 'A little space, just for you';

  @override
  String get offlineDescription =>
      'Lessons work offline. Progress and preferences stay on this device. Uninstalling the app can remove them; cloud backup is not included.';

  @override
  String get edition => 'UIGARJIN  /  EARLY LEARNING EDITION';

  @override
  String referencePreview(String letter, String form) {
    return '$letter · $form reference preview';
  }

  @override
  String lessonNumber(String number) {
    return 'LESSON $number';
  }

  @override
  String formBestScore(String form, int score) {
    return '$form · Best $score%';
  }

  @override
  String get collectionNote =>
      'Preview collection · Letter shapes and stroke order are awaiting expert review.';

  @override
  String get isolatedForm => 'Isolated form';

  @override
  String get initialForm => 'Initial form';

  @override
  String get medialForm => 'Medial form';

  @override
  String get finalForm => 'Final form';

  @override
  String get continueButton => 'Continue';

  @override
  String get backToLearning => 'Back to learning';

  @override
  String get handwritingPractice => 'HANDWRITING PRACTICE';

  @override
  String letterTitle(String cyrillic, String latin, String form) {
    return '$cyrillic · $latin — $form';
  }

  @override
  String get letterNote =>
      'Preview letter · Shape and stroke order pending expert review.';

  @override
  String get writingArea =>
      'Writing area. Trace the reference from its marked start point.';

  @override
  String get undo => 'Undo';

  @override
  String get clear => 'Clear';

  @override
  String get showAgain => 'Show again';

  @override
  String get resultsEyebrow => 'ONE STEP FURTHER';

  @override
  String get wellDone => 'Well done!';

  @override
  String letterComplete(String letter) {
    return '$letter complete';
  }

  @override
  String get resultsDescription =>
      'Every stroke is a little more familiar.\nKeep showing up for your practice.';

  @override
  String get tracingScore => 'Tracing score';

  @override
  String get advancedGuidance => 'Advanced guidance';

  @override
  String get beginner => 'Beginner';

  @override
  String get advanced => 'Advanced';

  @override
  String get feedbackTraceFirst => 'Trace the first stroke.';

  @override
  String get feedbackAlreadyComplete => 'This exercise is already complete.';

  @override
  String get feedbackUndo => 'Last stroke removed — try again.';

  @override
  String get feedbackIncomplete => 'Complete the stroke.';

  @override
  String get feedbackIncompleteToEnd =>
      'Complete the stroke all the way to the end.';

  @override
  String get feedbackWrongDirection =>
      'Wrong direction — retrace from the starting dot.';

  @override
  String get feedbackLowSimilarity =>
      'Not quite — try to follow the guide more closely.';

  @override
  String get feedbackCorrect => 'Correct!';

  @override
  String get feedbackStartLower => 'Start a little lower.';

  @override
  String get feedbackStartHigher => 'Start a little higher.';

  @override
  String get feedbackStartRight => 'Start a little further right.';

  @override
  String get feedbackStartLeft => 'Start a little further left.';

  @override
  String lessonProgress(int completed, int total) {
    return 'Stroke $completed of $total completed';
  }
}
