import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../domain/auth/auth_cubit.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../main_shell.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().completeProfile(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to MainShell and clear the navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainShell()),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppBar(
            title: Text(l10n.completeProfile, style: kTitleStyle),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(l10n.welcome, style: kTitleStyle.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.enterDetails,
                    style: kBodyStyle.copyWith(color: kTextSecondary),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isLoading,
                      style: kBodyStyle,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        labelStyle: kBodyStyle.copyWith(color: kTextSecondary),
                        hintText: l10n.nameHint,
                        hintStyle: kBodyStyle.copyWith(
                          color: kTextSecondary.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: kPrimary,
                        ),
                        filled: true,
                        fillColor: kCardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.enterNameError;
                        }
                        if (value.trim().length < 2) {
                          return l10n.nameLengthError;
                        }
                        return null;
                      },
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: l10n.getStarted,
                    onPressed: isLoading ? null : _handleSubmit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
