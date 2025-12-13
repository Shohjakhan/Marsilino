import 'package:bloc/bloc.dart';

/// Custom BlocObserver for logging Cubit/Bloc lifecycle events.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('[Bloc] onCreate: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('[Bloc] onChange: ${bloc.runtimeType} | $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('[Bloc] onError: ${bloc.runtimeType} | $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('[Bloc] onClose: ${bloc.runtimeType}');
  }
}
