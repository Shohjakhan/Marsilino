// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get home => 'Главная';

  @override
  String get map => 'Карта';

  @override
  String get saved => 'Избранное';

  @override
  String get profile => 'Профиль';

  @override
  String get logOut => 'Выйти';

  @override
  String get cancel => 'Отмена';

  @override
  String get loggedOut => 'Вы вышли из системы';

  @override
  String get editProfile => 'Редактировать';

  @override
  String get editProfileSim => 'Редактирование профиля (симуляция)';

  @override
  String get language => 'Язык';

  @override
  String get redemptions => 'Покупки';

  @override
  String get uzsSaved => 'сэкономлено';

  @override
  String get redemptionHistory => 'История покупок';

  @override
  String get seeAll => 'Все';

  @override
  String get noRedemptions => 'Нет покупок';

  @override
  String get noRedemptionsSub => 'Здесь будет история ваших скидок';

  @override
  String get about => 'О ресторане';

  @override
  String get tags => 'Теги';

  @override
  String get workingHours => 'Часы работы';

  @override
  String get contact => 'Контакты';

  @override
  String get menu => 'Меню';

  @override
  String get viewFullMenu => 'Посмотреть меню';

  @override
  String get redeemDiscount => 'Получить скидку';

  @override
  String get enterAmount => 'Введите сумму счета';

  @override
  String get amountError => 'Сумма должна быть > 0';

  @override
  String get enterCode => 'Введите код кассира';

  @override
  String get codeLengthError => 'Код должен быть 4 цифры';

  @override
  String get codeDigitError => 'Только цифры';

  @override
  String get redeem => 'Активировать';

  @override
  String get billAmount => 'Сумма счета';

  @override
  String get cashierCode => 'Код кассира';

  @override
  String get success => 'Успешно!';

  @override
  String get youSaved => 'Вы сэкономили';

  @override
  String get finalBill => 'Итого к оплате';

  @override
  String get codeExpired => 'Код истек';

  @override
  String get codeInvalid => 'Неверный код';

  @override
  String get codeMismatch => 'Неверный ресторан';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get tryAgain => 'Попробовать снова';
}
