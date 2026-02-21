import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'aauth_state.dart';

class AauthCubit extends Cubit<AauthState> {
  AauthCubit() : super(AauthInitial());
}
