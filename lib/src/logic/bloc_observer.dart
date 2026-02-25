import 'package:bloc/bloc.dart';

/// Custom BlocObserver for logging Cubit/Bloc lifecycle events.
/// Uses overrides with no-op bodies in production.
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}
