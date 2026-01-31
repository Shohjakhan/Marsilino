import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import 'package:provider/provider.dart';
import 'src/logic/auth_cubit.dart';
import 'src/logic/bloc_observer.dart';
import 'src/logic/like_cubit.dart';
import 'src/logic/restaurants_cubit.dart';
import 'src/presentation/onboarding/onboarding_page.dart';
import 'src/theme/app_theme.dart';
import 'src/providers/locale_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/services/push/firebase_push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebasePushService().initialize();
  Bloc.observer = AppBlocObserver();
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => RestaurantsCubit()),
        BlocProvider(create: (_) => LikeCubit()),
      ],
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => LocaleProvider())],
        child: const AppMaterialShell(),
      ),
    );
  }
}

class AppMaterialShell extends StatelessWidget {
  const AppMaterialShell({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant App',
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingPage(),
    );
  }
}
