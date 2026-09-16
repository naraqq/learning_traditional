import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Uigarjin — Mongolian Script'**
  String get appTitle;

  /// No description provided for @mongolianScript.
  ///
  /// In en, this message translates to:
  /// **'Mongolian Script'**
  String get mongolianScript;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @learnTab.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTab;

  /// No description provided for @reviewTab.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used throughout the app.'**
  String get languageDescription;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @mongolianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Монгол'**
  String get mongolianLanguage;

  /// No description provided for @lockedLesson.
  ///
  /// In en, this message translates to:
  /// **'Complete the letter before this one first.'**
  String get lockedLesson;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Your saved progress could not be opened. Please try again.'**
  String get loadError;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Changes could not be saved on this device. Tap retry.'**
  String get saveError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @retrySave.
  ///
  /// In en, this message translates to:
  /// **'Retry save'**
  String get retrySave;

  /// No description provided for @dailyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'A LITTLE PRACTICE, EVERY DAY'**
  String get dailyEyebrow;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'A living script.\nA new beginning.'**
  String get homeTitle;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'Make room for a few quiet moments.\nDiscover traditional Mongolian, one stroke at a time.'**
  String get homeDescription;

  /// No description provided for @formsPracticed.
  ///
  /// In en, this message translates to:
  /// **'Forms practiced'**
  String get formsPracticed;

  /// No description provided for @lessonsFinished.
  ///
  /// In en, this message translates to:
  /// **'Lessons finished'**
  String get lessonsFinished;

  /// No description provided for @learningJourney.
  ///
  /// In en, this message translates to:
  /// **'Your learning journey'**
  String get learningJourney;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @collectionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'INTRODUCTORY COLLECTION'**
  String get collectionEyebrow;

  /// No description provided for @firstStrokes.
  ///
  /// In en, this message translates to:
  /// **'First strokes'**
  String get firstStrokes;

  /// No description provided for @unitSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 letter form · Guided handwriting} other{{count} letter forms · Guided handwriting}}'**
  String unitSummary(int count);

  /// No description provided for @collectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Collection progress'**
  String get collectionProgress;

  /// No description provided for @percentSpoken.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String percentSpoken(int percent);

  /// No description provided for @percentExplored.
  ///
  /// In en, this message translates to:
  /// **'{percent}% explored'**
  String percentExplored(int percent);

  /// No description provided for @exploreLetters.
  ///
  /// In en, this message translates to:
  /// **'Explore the letters'**
  String get exploreLetters;

  /// No description provided for @nextStepEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR NEXT SMALL STEP'**
  String get nextStepEyebrow;

  /// No description provided for @allCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Look how far\nyou’ve come.'**
  String get allCompleteTitle;

  /// No description provided for @firstLetterTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet your\nfirst letter.'**
  String get firstLetterTitle;

  /// No description provided for @keepPracticingTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your\npractice growing.'**
  String get keepPracticingTitle;

  /// No description provided for @allCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Revisit your letters and refine each stroke.'**
  String get allCompleteDescription;

  /// No description provided for @reviewLetters.
  ///
  /// In en, this message translates to:
  /// **'Review your letters'**
  String get reviewLetters;

  /// No description provided for @beginPractice.
  ///
  /// In en, this message translates to:
  /// **'Begin your practice'**
  String get beginPractice;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get continueLearning;

  /// No description provided for @journeyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR LEARNING JOURNEY'**
  String get journeyEyebrow;

  /// No description provided for @learnDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch the movement, follow the guide, and find your rhythm. Each lesson opens the next.'**
  String get learnDescription;

  /// No description provided for @reviewEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MAKE IT FAMILIAR'**
  String get reviewEyebrow;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Return. Refine.\nRemember.'**
  String get reviewTitle;

  /// No description provided for @reviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Revisit the forms you’ve practiced. Your best tracing score is saved for each letter.'**
  String get reviewDescription;

  /// No description provided for @emptyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your practice grows here'**
  String get emptyReviewTitle;

  /// No description provided for @emptyReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Finish your first lesson to add a letter to your personal review collection.'**
  String get emptyReviewDescription;

  /// No description provided for @findFirstLesson.
  ///
  /// In en, this message translates to:
  /// **'Find your first lesson'**
  String get findFirstLesson;

  /// No description provided for @settingsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'YOUR OWN PACE'**
  String get settingsEyebrow;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice, your way.'**
  String get settingsTitle;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Small adjustments for a more comfortable writing experience.'**
  String get settingsDescription;

  /// No description provided for @beginnerGuidance.
  ///
  /// In en, this message translates to:
  /// **'Beginner guidance'**
  String get beginnerGuidance;

  /// No description provided for @beginnerDescription.
  ///
  /// In en, this message translates to:
  /// **'More forgiving stroke tolerances.'**
  String get beginnerDescription;

  /// No description provided for @polishStrokes.
  ///
  /// In en, this message translates to:
  /// **'Polish accepted strokes'**
  String get polishStrokes;

  /// No description provided for @polishDescription.
  ///
  /// In en, this message translates to:
  /// **'Gently align accepted ink with the guide. Turn off to see your own handwriting.'**
  String get polishDescription;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticDescription.
  ///
  /// In en, this message translates to:
  /// **'A subtle response as you write.'**
  String get hapticDescription;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'A little space, just for you'**
  String get offlineTitle;

  /// No description provided for @offlineDescription.
  ///
  /// In en, this message translates to:
  /// **'Lessons work offline. Progress and preferences stay on this device. Uninstalling the app can remove them; cloud backup is not included.'**
  String get offlineDescription;

  /// No description provided for @edition.
  ///
  /// In en, this message translates to:
  /// **'UIGARJIN  /  EARLY LEARNING EDITION'**
  String get edition;

  /// No description provided for @referencePreview.
  ///
  /// In en, this message translates to:
  /// **'{letter} · {form} reference preview'**
  String referencePreview(String letter, String form);

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'LESSON {number}'**
  String lessonNumber(String number);

  /// No description provided for @formBestScore.
  ///
  /// In en, this message translates to:
  /// **'{form} · Best {score}%'**
  String formBestScore(String form, int score);

  /// No description provided for @collectionNote.
  ///
  /// In en, this message translates to:
  /// **'Preview collection · Letter shapes and stroke order are awaiting expert review.'**
  String get collectionNote;

  /// No description provided for @isolatedForm.
  ///
  /// In en, this message translates to:
  /// **'Isolated form'**
  String get isolatedForm;

  /// No description provided for @initialForm.
  ///
  /// In en, this message translates to:
  /// **'Initial form'**
  String get initialForm;

  /// No description provided for @medialForm.
  ///
  /// In en, this message translates to:
  /// **'Medial form'**
  String get medialForm;

  /// No description provided for @finalForm.
  ///
  /// In en, this message translates to:
  /// **'Final form'**
  String get finalForm;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @backToLearning.
  ///
  /// In en, this message translates to:
  /// **'Back to learning'**
  String get backToLearning;

  /// No description provided for @handwritingPractice.
  ///
  /// In en, this message translates to:
  /// **'HANDWRITING PRACTICE'**
  String get handwritingPractice;

  /// No description provided for @letterTitle.
  ///
  /// In en, this message translates to:
  /// **'{cyrillic} · {latin} — {form}'**
  String letterTitle(String cyrillic, String latin, String form);

  /// No description provided for @letterNote.
  ///
  /// In en, this message translates to:
  /// **'Preview letter · Shape and stroke order pending expert review.'**
  String get letterNote;

  /// No description provided for @writingArea.
  ///
  /// In en, this message translates to:
  /// **'Writing area. Trace the reference from its marked start point.'**
  String get writingArea;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @showAgain.
  ///
  /// In en, this message translates to:
  /// **'Show again'**
  String get showAgain;

  /// No description provided for @resultsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ONE STEP FURTHER'**
  String get resultsEyebrow;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get wellDone;

  /// No description provided for @letterComplete.
  ///
  /// In en, this message translates to:
  /// **'{letter} complete'**
  String letterComplete(String letter);

  /// No description provided for @resultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Every stroke is a little more familiar.\nKeep showing up for your practice.'**
  String get resultsDescription;

  /// No description provided for @tracingScore.
  ///
  /// In en, this message translates to:
  /// **'Tracing score'**
  String get tracingScore;

  /// No description provided for @advancedGuidance.
  ///
  /// In en, this message translates to:
  /// **'Advanced guidance'**
  String get advancedGuidance;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @feedbackTraceFirst.
  ///
  /// In en, this message translates to:
  /// **'Trace the first stroke.'**
  String get feedbackTraceFirst;

  /// No description provided for @feedbackAlreadyComplete.
  ///
  /// In en, this message translates to:
  /// **'This exercise is already complete.'**
  String get feedbackAlreadyComplete;

  /// No description provided for @feedbackUndo.
  ///
  /// In en, this message translates to:
  /// **'Last stroke removed — try again.'**
  String get feedbackUndo;

  /// No description provided for @feedbackIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete the stroke.'**
  String get feedbackIncomplete;

  /// No description provided for @feedbackIncompleteToEnd.
  ///
  /// In en, this message translates to:
  /// **'Complete the stroke all the way to the end.'**
  String get feedbackIncompleteToEnd;

  /// No description provided for @feedbackWrongDirection.
  ///
  /// In en, this message translates to:
  /// **'Wrong direction — retrace from the starting dot.'**
  String get feedbackWrongDirection;

  /// No description provided for @feedbackLowSimilarity.
  ///
  /// In en, this message translates to:
  /// **'Not quite — try to follow the guide more closely.'**
  String get feedbackLowSimilarity;

  /// No description provided for @feedbackCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get feedbackCorrect;

  /// No description provided for @feedbackStartLower.
  ///
  /// In en, this message translates to:
  /// **'Start a little lower.'**
  String get feedbackStartLower;

  /// No description provided for @feedbackStartHigher.
  ///
  /// In en, this message translates to:
  /// **'Start a little higher.'**
  String get feedbackStartHigher;

  /// No description provided for @feedbackStartRight.
  ///
  /// In en, this message translates to:
  /// **'Start a little further right.'**
  String get feedbackStartRight;

  /// No description provided for @feedbackStartLeft.
  ///
  /// In en, this message translates to:
  /// **'Start a little further left.'**
  String get feedbackStartLeft;

  /// No description provided for @lessonProgress.
  ///
  /// In en, this message translates to:
  /// **'Stroke {completed} of {total} completed'**
  String lessonProgress(int completed, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mn':
      return AppLocalizationsMn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
