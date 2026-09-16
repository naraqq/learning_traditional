// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([String locale = 'mn']) : super(locale);

  @override
  String get appTitle => 'Уйгаржин — Монгол бичиг';

  @override
  String get mongolianScript => 'Монгол бичиг';

  @override
  String get homeTab => 'Нүүр';

  @override
  String get learnTab => 'Сурах';

  @override
  String get reviewTab => 'Давтах';

  @override
  String get settingsTab => 'Тохиргоо';

  @override
  String get language => 'Хэл';

  @override
  String get languageDescription => 'Аппын хэлийг сонгоно уу.';

  @override
  String get englishLanguage => 'English';

  @override
  String get mongolianLanguage => 'Монгол';

  @override
  String get lockedLesson => 'Эхлээд өмнөх үсгийн хичээлийг дуусгаарай.';

  @override
  String get loadError => 'Хадгалсан ахицыг нээж чадсангүй. Дахин оролдоно уу.';

  @override
  String get saveError =>
      'Өөрчлөлтийг энэ төхөөрөмжид хадгалж чадсангүй. Дахин оролдоно уу.';

  @override
  String get tryAgain => 'Дахин оролдох';

  @override
  String get retrySave => 'Дахин хадгалах';

  @override
  String get dailyEyebrow => 'ӨДӨР БҮР БАГА БАГААР';

  @override
  String get homeTitle => 'Өв соёлын бичиг.\nШинэ эхлэл.';

  @override
  String get homeDescription =>
      'Өөртөө хэдэн хором зориулаарай.\nЗураас бүрээр монгол бичгээ сурцгаая.';

  @override
  String get formsPracticed => 'Давтсан хэлбэр';

  @override
  String get lessonsFinished => 'Дууссан хичээл';

  @override
  String get learningJourney => 'Таны сурах зам';

  @override
  String get viewAll => 'Бүгдийг үзэх';

  @override
  String get collectionEyebrow => 'АНХНЫ АЛХАМ';

  @override
  String get firstStrokes => 'Эхний зураасууд';

  @override
  String unitSummary(int count) {
    return '$count үсгийн хэлбэр · Загвар дагаж бичих';
  }

  @override
  String get collectionProgress => 'Хичээлийн ахиц';

  @override
  String percentSpoken(int percent) {
    return '$percent хувь';
  }

  @override
  String percentExplored(int percent) {
    return '$percent% үзсэн';
  }

  @override
  String get exploreLetters => 'Үсгүүдтэй танилцах';

  @override
  String get nextStepEyebrow => 'ТАНЫ ДАРААГИЙН АЛХАМ';

  @override
  String get allCompleteTitle => 'Та ихийг\nсурчээ.';

  @override
  String get firstLetterTitle => 'Эхний үсэгтэйгээ\nтанилцаарай.';

  @override
  String get keepPracticingTitle => 'Дасгалаа\nүргэлжлүүлээрэй.';

  @override
  String get allCompleteDescription =>
      'Үсгүүдээ давтаж, зураас бүрээ сайжруулаарай.';

  @override
  String get reviewLetters => 'Үсгүүдээ давтах';

  @override
  String get beginPractice => 'Дасгалаа эхлэх';

  @override
  String get continueLearning => 'Үргэлжлүүлэн сурах';

  @override
  String get journeyEyebrow => 'ТАНЫ СУРАХ ЗАМ';

  @override
  String get learnDescription =>
      'Бичих хөдөлгөөнийг ажиглаж, загварыг дагаарай. Хичээлээ дуусгахад дараагийнх нь нээгдэнэ.';

  @override
  String get reviewEyebrow => 'ДАВТЛАГААР БАТАТГАЯ';

  @override
  String get reviewTitle => 'Давт. Сайжруул.\nТогтоо.';

  @override
  String get reviewDescription =>
      'Дасгал хийсэн үсгийн хэлбэрүүдээ давтаарай. Үсэг бүрийн хамгийн өндөр үнэлгээ хадгалагдана.';

  @override
  String get emptyReviewTitle => 'Таны давтлага эндээс эхэлнэ';

  @override
  String get emptyReviewDescription =>
      'Эхний хичээлээ дуусгахад сурсан үсэг тань давтлагын хэсэгт нэмэгдэнэ.';

  @override
  String get findFirstLesson => 'Эхний хичээлээ үзэх';

  @override
  String get settingsEyebrow => 'ӨӨРИЙН ХЭМНЭЛЭЭР';

  @override
  String get settingsTitle => 'Өөртөө тохируулж сураарай.';

  @override
  String get settingsDescription =>
      'Бичих дасгалаа өөртөө илүү тохиромжтой болгоорой.';

  @override
  String get beginnerGuidance => 'Анхан шатны тусламж';

  @override
  String get beginnerDescription => 'Зураасны бага зэргийн зөрүүг зөвшөөрнө.';

  @override
  String get polishStrokes => 'Зөв бичсэн зураасыг жигдлэх';

  @override
  String get polishDescription =>
      'Зөв бичсэн зураасыг загварт ойртуулж жигдэлнэ. Унтраавал өөрийн бичсэн хэлбэрээр харагдана.';

  @override
  String get hapticFeedback => 'Чичиргээ';

  @override
  String get hapticDescription => 'Бичих үед зөөлөн чичиргээгээр мэдэгдэнэ.';

  @override
  String get offlineTitle => 'Танд зориулсан сурах орон зай';

  @override
  String get offlineDescription =>
      'Хичээлүүд интернэтгүй ажиллана. Ахиц болон тохиргоо энэ төхөөрөмжид хадгалагдана. Аппыг устгавал эдгээр мэдээлэл устаж болно. Үүлэн нөөцлөлт байхгүй.';

  @override
  String get edition => 'УЙГАРЖИН  /  СУРГАЛТЫН ТУРШИЛТЫН ХУВИЛБАР';

  @override
  String referencePreview(String letter, String form) {
    return '$letter · $form загвар';
  }

  @override
  String lessonNumber(String number) {
    return 'ХИЧЭЭЛ $number';
  }

  @override
  String formBestScore(String form, int score) {
    return '$form · Дээд үнэлгээ: $score%';
  }

  @override
  String get collectionNote =>
      'Туршилтын хичээлүүд · Үсгийн хэлбэр, зураасны дарааллыг мэргэжлийн багшаар хянуулах шаардлагатай.';

  @override
  String get isolatedForm => 'Дан хэлбэр';

  @override
  String get initialForm => 'Эхэн хэлбэр';

  @override
  String get medialForm => 'Дунд хэлбэр';

  @override
  String get finalForm => 'Адаг хэлбэр';

  @override
  String get continueButton => 'Үргэлжлүүлэх';

  @override
  String get backToLearning => 'Хичээл рүү буцах';

  @override
  String get handwritingPractice => 'БИЧИХ ДАСГАЛ';

  @override
  String letterTitle(String cyrillic, String latin, String form) {
    return '$cyrillic · $latin — $form';
  }

  @override
  String get letterNote =>
      'Туршилтын үсэг · Хэлбэр, зураасны дарааллыг мэргэжлийн багшаар хянуулах шаардлагатай.';

  @override
  String get writingArea =>
      'Бичих талбар. Тэмдэглэсэн эхлэх цэгээс загварыг дагуулж бичээрэй.';

  @override
  String get undo => 'Буцаах';

  @override
  String get clear => 'Арилгах';

  @override
  String get showAgain => 'Дахин үзүүлэх';

  @override
  String get resultsEyebrow => 'НЭГ АЛХМААР УРАГШИЛЛАА';

  @override
  String get wellDone => 'Сайн байна!';

  @override
  String letterComplete(String letter) {
    return '$letter үсгийн дасгал дууслаа';
  }

  @override
  String get resultsDescription =>
      'Зураас бүр улам танил болж байна.\nДасгалаа тогтмол хийгээрэй.';

  @override
  String get tracingScore => 'Дагуулж бичсэн үнэлгээ';

  @override
  String get advancedGuidance => 'Ахисан шатны тусламж';

  @override
  String get beginner => 'Анхан';

  @override
  String get advanced => 'Ахисан';

  @override
  String get feedbackTraceFirst => 'Эхний зураасыг дагуулж бичээрэй.';

  @override
  String get feedbackAlreadyComplete => 'Энэ дасгал аль хэдийн дууссан байна.';

  @override
  String get feedbackUndo => 'Сүүлийн зураасыг арилгалаа. Дахин бичээрэй.';

  @override
  String get feedbackIncomplete => 'Зураасаа гүйцээж бичээрэй.';

  @override
  String get feedbackIncompleteToEnd =>
      'Зураасаа төгсгөлийн цэг хүртэл гүйцээж бичээрэй.';

  @override
  String get feedbackWrongDirection =>
      'Чиглэл буруу байна. Эхлэх цэгээс дахин бичээрэй.';

  @override
  String get feedbackLowSimilarity =>
      'Арай өөр байна. Загварт илүү ойртуулж бичээрэй.';

  @override
  String get feedbackCorrect => 'Зөв байна!';

  @override
  String get feedbackStartLower => 'Бага зэрэг доороос эхлээрэй.';

  @override
  String get feedbackStartHigher => 'Бага зэрэг дээрээс эхлээрэй.';

  @override
  String get feedbackStartRight => 'Бага зэрэг баруун талаас эхлээрэй.';

  @override
  String get feedbackStartLeft => 'Бага зэрэг зүүн талаас эхлээрэй.';

  @override
  String lessonProgress(int completed, int total) {
    return '$total зурааснаас $completed-ийг бичсэн';
  }
}
