// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get map => 'Map';

  @override
  String get saved => 'Saved';

  @override
  String get profile => 'Profile';

  @override
  String get logOut => 'Log Out';

  @override
  String get cancel => 'Cancel';

  @override
  String get loggedOut => 'Logged out';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editProfileSim => 'Edit profile (simulation)';

  @override
  String get language => 'Language';

  @override
  String get redemptions => 'Redemptions';

  @override
  String get uzsSaved => 'UZS Saved';

  @override
  String get redemptionHistory => 'Redemption History';

  @override
  String get seeAll => 'See all';

  @override
  String get noRedemptions => 'No redemptions yet';

  @override
  String get noRedemptionsSub => 'Your cashback redemptions will appear here';

  @override
  String get about => 'About';

  @override
  String get tags => 'Tags';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get contact => 'Contact';

  @override
  String get menu => 'Menu';

  @override
  String get viewFullMenu => 'View Full Menu';

  @override
  String get redeemCashback => 'Redeem Cashback';

  @override
  String get enterAmount => 'Please enter the bill amount';

  @override
  String get amountError => 'Amount must be greater than 0';

  @override
  String get enterCode => 'Please enter the cashier code';

  @override
  String get codeLengthError => 'Code must be 4 digits';

  @override
  String get codeDigitError => 'Code must contain only digits';

  @override
  String get redeem => 'Redeem';

  @override
  String get billAmount => 'Bill Amount';

  @override
  String get cashierCode => 'Cashier Code';

  @override
  String get success => 'Success!';

  @override
  String get youSaved => 'You saved';

  @override
  String get finalBill => 'Final bill';

  @override
  String get codeExpired => 'This code has expired';

  @override
  String get codeInvalid => 'Invalid cashier code';

  @override
  String get codeMismatch => 'Code does not match restaurant';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get signIn => 'Sign In';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get continueText => 'Continue';

  @override
  String get termsAgree => 'By continuing, you agree to our';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get verification => 'Verification';

  @override
  String get otpEnterCode => 'Enter Code';

  @override
  String get sentCodeTo => 'We sent a 6-digit code to';

  @override
  String get verifying => 'Verifying...';

  @override
  String get waitingTelegram => 'Waiting for Telegram message...';

  @override
  String get resendCode => 'Resend code';

  @override
  String get resendCodeIn => 'Resend code in';

  @override
  String get verify => 'Verify';

  @override
  String get enterAllDigits => 'Please enter all 6 digits';

  @override
  String get completeProfile => 'Complete Profile';

  @override
  String get enterDetails => 'Enter your details to continue';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameHint => 'e.g. John Doe';

  @override
  String get enterNameError => 'Please enter your name';

  @override
  String get saveContinue => 'Save & Continue';

  @override
  String get findFood => 'Find Your Favorite Food';

  @override
  String get searchPlaceholder => 'Search restaurants, food...';

  @override
  String get all => 'All';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get sendCodeTelegram => 'Send code via Telegram';

  @override
  String get codeSentSuccess => 'Code sent successfully';

  @override
  String get phoneError => 'Please enter your phone number';

  @override
  String get phoneInvalid => 'Please enter a valid phone number';

  @override
  String get nameLengthError => 'Name must be at least 2 characters';

  @override
  String get welcome => 'Welcome';

  @override
  String get getStarted => 'Get Started';

  @override
  String get discover => 'Discover';

  @override
  String get quickFilters => 'Quick Filters';

  @override
  String get selectCategories => 'Select categories to filter restaurants';

  @override
  String get clearAll => 'Clear All';

  @override
  String get apply => 'Apply';

  @override
  String get nearbyRestaurants => 'Nearby Restaurants';

  @override
  String placesCount(Object count) {
    return '$count places';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get noRestaurantsFound => 'No restaurants found';

  @override
  String get adjustFilters => 'Try adjusting your search or filters';

  @override
  String get searchNearby => 'Search restaurants nearby';

  @override
  String get loadingRestaurants => 'Loading restaurants...';

  @override
  String get couldNotGetLocation => 'Could not get location';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Enable in settings.';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String cashbackWallet(String name) {
    return 'Cashback – $name';
  }

  @override
  String get balance => 'Balance';

  @override
  String get transferToCard => 'Transfer to Card';

  @override
  String get enterCardNumber => 'Please enter your 16-digit card number.';

  @override
  String get cardNumberLengthError => 'Card number must be 16 digits.';

  @override
  String get transferFailed => 'Transfer failed';

  @override
  String recentCashback(String amount) {
    return '+UZS $amount recent';
  }

  @override
  String get pointAtQr => 'Point at receipt QR code';

  @override
  String scanReceiptFor(String name) {
    return 'Scan your $name receipt';
  }

  @override
  String get scanFiscalReceipt => 'Scan the fiscal receipt to earn cashback';

  @override
  String cashbackRate(int pct) {
    return 'Cashback rate: $pct%';
  }

  @override
  String get fetchingReceipt => 'Fetching receipt...';

  @override
  String get verifyingFiscal => 'Verifying with fiscal service';

  @override
  String get receiptVerified => 'Receipt Verified';

  @override
  String get restaurantLabel => 'Restaurant';

  @override
  String get receiptNumberLabel => 'Receipt #';

  @override
  String get dateLabel => 'Date';

  @override
  String get totalPaidLabel => 'Total Paid';

  @override
  String get cashbackEarned => 'Cashback Earned';

  @override
  String get redeemCashbackBtn => 'Redeem Cashback';

  @override
  String get cashbackRedeemed => 'Cashback Redeemed!';

  @override
  String get scanAnother => 'Scan Another';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get cashbackAddedWallet => 'Cashback added to your wallet!';

  @override
  String cashbackPctFrom(int pct, String name) {
    return '$pct% cashback from $name';
  }

  @override
  String get transferSuccess => 'Balance transferred to your card!';

  @override
  String get rateYourExperience => 'Rate Your Experience';

  @override
  String rateExperienceSub(String name) {
    return 'How was your visit to $name?';
  }

  @override
  String get submitRating => 'Submit Rating';

  @override
  String get skipRating => 'Skip';

  @override
  String get ratingThanks => 'Thank you for your feedback!';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get noFavoritesSub =>
      'Tap the heart icon on any restaurant to save it here';

  @override
  String get exploreRestaurants => 'Explore Restaurants';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get liked => 'Liked';

  @override
  String restaurantsCount(int count) {
    return '$count restaurants';
  }

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get people => 'People';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get failedUpdateFavorite => 'Failed to update favorite';

  @override
  String callingSimulation(String phone) {
    return 'Calling $phone (simulation)';
  }

  @override
  String openingSocialSimulation(String platform, String handle) {
    return 'Opening $platform: $handle (simulation)';
  }

  @override
  String openingMapLink(String link) {
    return 'Opening map link: $link';
  }

  @override
  String get errorMissingRestaurantId => 'Error: Missing restaurant ID';

  @override
  String get failedLoadRestaurant => 'Failed to load restaurant';

  @override
  String get shareSimulation => 'Share (simulation)';

  @override
  String get reportLoggedConsole => 'Report logged to console';

  @override
  String get retryButton => 'Retry';

  @override
  String get failedCreateBooking => 'Failed to create booking';

  @override
  String get bookTableTitle => 'Book a Table';

  @override
  String get bookTableBtn => 'Book Table';

  @override
  String get failedRemoveFavorite => 'Failed to remove from favorites';

  @override
  String get tokenCopied => 'Token copied to clipboard';

  @override
  String get failedLoadProfile => 'Failed to load profile';

  @override
  String get defaultUser => 'User';

  @override
  String get upcomingReservations => 'Upcoming Reservations';

  @override
  String bookingRef(String id) {
    return 'Ref: #$id';
  }
}
