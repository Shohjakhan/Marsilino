import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get loggedOut;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editProfileSim.
  ///
  /// In en, this message translates to:
  /// **'Edit profile (simulation)'**
  String get editProfileSim;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @redemptions.
  ///
  /// In en, this message translates to:
  /// **'Redemptions'**
  String get redemptions;

  /// No description provided for @uzsSaved.
  ///
  /// In en, this message translates to:
  /// **'UZS Saved'**
  String get uzsSaved;

  /// No description provided for @redemptionHistory.
  ///
  /// In en, this message translates to:
  /// **'Redemption History'**
  String get redemptionHistory;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noRedemptions.
  ///
  /// In en, this message translates to:
  /// **'No redemptions yet'**
  String get noRedemptions;

  /// No description provided for @noRedemptionsSub.
  ///
  /// In en, this message translates to:
  /// **'Your cashback redemptions will appear here'**
  String get noRedemptionsSub;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @viewFullMenu.
  ///
  /// In en, this message translates to:
  /// **'View Full Menu'**
  String get viewFullMenu;

  /// No description provided for @redeemCashback.
  ///
  /// In en, this message translates to:
  /// **'Redeem Cashback'**
  String get redeemCashback;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the bill amount'**
  String get enterAmount;

  /// No description provided for @amountError.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountError;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the cashier code'**
  String get enterCode;

  /// No description provided for @codeLengthError.
  ///
  /// In en, this message translates to:
  /// **'Code must be 4 digits'**
  String get codeLengthError;

  /// No description provided for @codeDigitError.
  ///
  /// In en, this message translates to:
  /// **'Code must contain only digits'**
  String get codeDigitError;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @billAmount.
  ///
  /// In en, this message translates to:
  /// **'Bill Amount'**
  String get billAmount;

  /// No description provided for @cashierCode.
  ///
  /// In en, this message translates to:
  /// **'Cashier Code'**
  String get cashierCode;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @youSaved.
  ///
  /// In en, this message translates to:
  /// **'You saved'**
  String get youSaved;

  /// No description provided for @finalBill.
  ///
  /// In en, this message translates to:
  /// **'Final bill'**
  String get finalBill;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired'**
  String get codeExpired;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid cashier code'**
  String get codeInvalid;

  /// No description provided for @codeMismatch.
  ///
  /// In en, this message translates to:
  /// **'Code does not match restaurant'**
  String get codeMismatch;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @termsAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get termsAgree;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Code'**
  String get otpEnterCode;

  /// No description provided for @sentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get sentCodeTo;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @waitingTelegram.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Telegram message...'**
  String get waitingTelegram;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @enterAllDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits'**
  String get enterAllDigits;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to continue'**
  String get enterDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get nameHint;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterNameError;

  /// No description provided for @saveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveContinue;

  /// No description provided for @findFood.
  ///
  /// In en, this message translates to:
  /// **'Find Your Favorite Food'**
  String get findFood;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants, food...'**
  String get searchPlaceholder;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @sendCodeTelegram.
  ///
  /// In en, this message translates to:
  /// **'Send code via Telegram'**
  String get sendCodeTelegram;

  /// No description provided for @codeSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code sent successfully'**
  String get codeSentSuccess;

  /// No description provided for @phoneError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneError;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @nameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameLengthError;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @quickFilters.
  ///
  /// In en, this message translates to:
  /// **'Quick Filters'**
  String get quickFilters;

  /// No description provided for @selectCategories.
  ///
  /// In en, this message translates to:
  /// **'Select categories to filter restaurants'**
  String get selectCategories;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @nearbyRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Nearby Restaurants'**
  String get nearbyRestaurants;

  /// No description provided for @placesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} places'**
  String placesCount(Object count);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noRestaurantsFound.
  ///
  /// In en, this message translates to:
  /// **'No restaurants found'**
  String get noRestaurantsFound;

  /// No description provided for @adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustFilters;

  /// No description provided for @searchNearby.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants nearby'**
  String get searchNearby;

  /// No description provided for @loadingRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Loading restaurants...'**
  String get loadingRestaurants;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get couldNotGetLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Enable in settings.'**
  String get locationPermissionDenied;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// No description provided for @cashbackWallet.
  ///
  /// In en, this message translates to:
  /// **'Cashback – {name}'**
  String cashbackWallet(String name);

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @transferToCard.
  ///
  /// In en, this message translates to:
  /// **'Transfer to Card'**
  String get transferToCard;

  /// No description provided for @enterCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 16-digit card number.'**
  String get enterCardNumber;

  /// No description provided for @cardNumberLengthError.
  ///
  /// In en, this message translates to:
  /// **'Card number must be 16 digits.'**
  String get cardNumberLengthError;

  /// No description provided for @transferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get transferFailed;

  /// No description provided for @recentCashback.
  ///
  /// In en, this message translates to:
  /// **'+UZS {amount} recent'**
  String recentCashback(String amount);

  /// No description provided for @pointAtQr.
  ///
  /// In en, this message translates to:
  /// **'Point at receipt QR code'**
  String get pointAtQr;

  /// No description provided for @scanReceiptFor.
  ///
  /// In en, this message translates to:
  /// **'Scan your {name} receipt'**
  String scanReceiptFor(String name);

  /// No description provided for @scanFiscalReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan the fiscal receipt to earn cashback'**
  String get scanFiscalReceipt;

  /// No description provided for @cashbackRate.
  ///
  /// In en, this message translates to:
  /// **'Cashback rate: {pct}%'**
  String cashbackRate(int pct);

  /// No description provided for @fetchingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Fetching receipt...'**
  String get fetchingReceipt;

  /// No description provided for @verifyingFiscal.
  ///
  /// In en, this message translates to:
  /// **'Verifying with fiscal service'**
  String get verifyingFiscal;

  /// No description provided for @receiptVerified.
  ///
  /// In en, this message translates to:
  /// **'Receipt Verified'**
  String get receiptVerified;

  /// No description provided for @restaurantLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantLabel;

  /// No description provided for @receiptNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt #'**
  String get receiptNumberLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @totalPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaidLabel;

  /// No description provided for @cashbackEarned.
  ///
  /// In en, this message translates to:
  /// **'Cashback Earned'**
  String get cashbackEarned;

  /// No description provided for @redeemCashbackBtn.
  ///
  /// In en, this message translates to:
  /// **'Redeem Cashback'**
  String get redeemCashbackBtn;

  /// No description provided for @cashbackRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Cashback Redeemed!'**
  String get cashbackRedeemed;

  /// No description provided for @scanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another'**
  String get scanAnother;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @cashbackAddedWallet.
  ///
  /// In en, this message translates to:
  /// **'Cashback added to your wallet!'**
  String get cashbackAddedWallet;

  /// No description provided for @cashbackPctFrom.
  ///
  /// In en, this message translates to:
  /// **'{pct}% cashback from {name}'**
  String cashbackPctFrom(int pct, String name);

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Balance transferred to your card!'**
  String get transferSuccess;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateYourExperience;

  /// No description provided for @rateExperienceSub.
  ///
  /// In en, this message translates to:
  /// **'How was your visit to {name}?'**
  String rateExperienceSub(String name);

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @skipRating.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipRating;

  /// No description provided for @ratingThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get ratingThanks;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @noFavoritesSub.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any restaurant to save it here'**
  String get noFavoritesSub;

  /// No description provided for @exploreRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Explore Restaurants'**
  String get exploreRestaurants;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @restaurantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} restaurants'**
  String restaurantsCount(int count);

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @failedUpdateFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite'**
  String get failedUpdateFavorite;

  /// No description provided for @callingSimulation.
  ///
  /// In en, this message translates to:
  /// **'Calling {phone} (simulation)'**
  String callingSimulation(String phone);

  /// No description provided for @openingSocialSimulation.
  ///
  /// In en, this message translates to:
  /// **'Opening {platform}: {handle} (simulation)'**
  String openingSocialSimulation(String platform, String handle);

  /// No description provided for @openingMapLink.
  ///
  /// In en, this message translates to:
  /// **'Opening map link: {link}'**
  String openingMapLink(String link);

  /// No description provided for @errorMissingRestaurantId.
  ///
  /// In en, this message translates to:
  /// **'Error: Missing restaurant ID'**
  String get errorMissingRestaurantId;

  /// No description provided for @failedLoadRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Failed to load restaurant'**
  String get failedLoadRestaurant;

  /// No description provided for @shareSimulation.
  ///
  /// In en, this message translates to:
  /// **'Share (simulation)'**
  String get shareSimulation;

  /// No description provided for @reportLoggedConsole.
  ///
  /// In en, this message translates to:
  /// **'Report logged to console'**
  String get reportLoggedConsole;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @failedCreateBooking.
  ///
  /// In en, this message translates to:
  /// **'Failed to create booking'**
  String get failedCreateBooking;

  /// No description provided for @bookTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a Table'**
  String get bookTableTitle;

  /// No description provided for @bookTableBtn.
  ///
  /// In en, this message translates to:
  /// **'Book Table'**
  String get bookTableBtn;

  /// No description provided for @failedRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove from favorites'**
  String get failedRemoveFavorite;

  /// No description provided for @tokenCopied.
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard'**
  String get tokenCopied;

  /// No description provided for @failedLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedLoadProfile;

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @upcomingReservations.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Reservations'**
  String get upcomingReservations;

  /// No description provided for @bookingRef.
  ///
  /// In en, this message translates to:
  /// **'Ref: #{id}'**
  String bookingRef(String id);
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
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
