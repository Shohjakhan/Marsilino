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
  String get noRedemptionsSub => 'Здесь будет история вашего кэшбэка';

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
  String get redeemCashback => 'Получить кэшбэк';

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

  @override
  String get signIn => 'Войти';

  @override
  String get enterPhone => 'Введите номер телефона';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get continueText => 'Продолжить';

  @override
  String get termsAgree => 'Продолжая, вы соглашаетесь с';

  @override
  String get termsOfService => 'Условиями';

  @override
  String get privacyPolicy => 'Политикой';

  @override
  String get verification => 'Верификация';

  @override
  String get otpEnterCode => 'Введите код';

  @override
  String get sentCodeTo => 'Мы отправили 6-значный код на';

  @override
  String get verifying => 'Проверка...';

  @override
  String get waitingTelegram => 'Ожидание сообщения в Telegram...';

  @override
  String get resendCode => 'Отправить код снова';

  @override
  String get resendCodeIn => 'Отправить код через';

  @override
  String get verify => 'Подтвердить';

  @override
  String get enterAllDigits => 'Введите все 6 цифр';

  @override
  String get completeProfile => 'Заполните профиль';

  @override
  String get enterDetails => 'Введите данные для продолжения';

  @override
  String get fullName => 'ФИО';

  @override
  String get nameHint => 'напр. Иван Иванов';

  @override
  String get enterNameError => 'Пожалуйста, введите имя';

  @override
  String get saveContinue => 'Сохранить и продолжить';

  @override
  String get findFood => 'Найдите любимую еду';

  @override
  String get searchPlaceholder => 'Поиск ресторанов, еды...';

  @override
  String get all => 'Все';

  @override
  String get welcomeBack => 'Добро пожаловать';

  @override
  String get sendCodeTelegram => 'Отправить код в Telegram';

  @override
  String get codeSentSuccess => 'Код успешно отправлен';

  @override
  String get phoneError => 'Пожалуйста, введите номер телефона';

  @override
  String get phoneInvalid => 'Пожалуйста, введите корректный номер';

  @override
  String get nameLengthError => 'Имя должно быть не менее 2 символов';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get getStarted => 'Начать';

  @override
  String get discover => 'Обзор';

  @override
  String get quickFilters => 'Быстрые фильтры';

  @override
  String get selectCategories => 'Выберите категории';

  @override
  String get clearAll => 'Очистить';

  @override
  String get apply => 'Применить';

  @override
  String get nearbyRestaurants => 'Рестораны рядом';

  @override
  String placesCount(Object count) {
    return '$count мест';
  }

  @override
  String get loading => 'Загрузка...';

  @override
  String get noRestaurantsFound => 'Рестораны не найдены';

  @override
  String get adjustFilters => 'Измените настройки поиска';

  @override
  String get searchNearby => 'Поиск ресторанов рядом';

  @override
  String get loadingRestaurants => 'Загрузка ресторанов...';

  @override
  String get couldNotGetLocation => 'Не удалось получить местоположение';

  @override
  String get locationPermissionDenied =>
      'Доступ к геолокации запрещен. Включите в настройках.';

  @override
  String get gettingLocation => 'Получение местоположения...';

  @override
  String cashbackWallet(String name) {
    return 'Кэшбэк – $name';
  }

  @override
  String get balance => 'Баланс';

  @override
  String get transferToCard => 'Перевести на карту';

  @override
  String recentCashback(String amount) {
    return '+$amount UZS недавно';
  }

  @override
  String get pointAtQr => 'Наведите на QR-код чека';

  @override
  String scanReceiptFor(String name) {
    return 'Сканируйте чек $name';
  }

  @override
  String get scanFiscalReceipt => 'Сканируйте чек для получения кэшбэка';

  @override
  String cashbackRate(int pct) {
    return 'Ставка кэшбэка: $pct%';
  }

  @override
  String get fetchingReceipt => 'Загрузка чека...';

  @override
  String get verifyingFiscal => 'Проверка через фискальную службу';

  @override
  String get receiptVerified => 'Чек подтверждён';

  @override
  String get restaurantLabel => 'Ресторан';

  @override
  String get receiptNumberLabel => 'Чек №';

  @override
  String get dateLabel => 'Дата';

  @override
  String get totalPaidLabel => 'Итого оплачено';

  @override
  String get cashbackEarned => 'Получен кэшбэк';

  @override
  String get redeemCashbackBtn => 'Активировать кэшбэк';

  @override
  String get cashbackRedeemed => 'Кэшбэк активирован!';

  @override
  String get scanAnother => 'Сканировать ещё';

  @override
  String get scanAgain => 'Повторить сканирование';

  @override
  String get cashbackAddedWallet => 'Кэшбэк добавлен в кошелёк!';

  @override
  String cashbackPctFrom(int pct, String name) {
    return '$pct% кэшбэк от $name';
  }

  @override
  String get transferSuccess => 'Баланс переведён на карту!';

  @override
  String get rateYourExperience => 'Оцените свой опыт';

  @override
  String rateExperienceSub(String name) {
    return 'Как прошёл ваш визит в $name?';
  }

  @override
  String get submitRating => 'Отправить оценку';

  @override
  String get skipRating => 'Пропустить';

  @override
  String get ratingThanks => 'Спасибо за ваш отзыв!';

  @override
  String get noFavoritesYet => 'Нет избранных';

  @override
  String get noFavoritesSub =>
      'Нажмите на сердечко у любого ресторана, чтобы сохранить его';

  @override
  String get exploreRestaurants => 'Смотреть рестораны';

  @override
  String get removedFromFavorites => 'Удалено из избранного';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get liked => 'Избранное';

  @override
  String restaurantsCount(int count) {
    return '$count ресторанов';
  }
}
