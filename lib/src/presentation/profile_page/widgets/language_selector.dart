import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/locale_provider.dart';
import '../../common/rounded_card.dart';

/// Language selector segmented control widget.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uz':
        return "O'zbek";
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<LocaleProvider>(context);
    final currentCode = provider.locale.languageCode;

    final languages = ['en', 'ru', 'uz'];

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: kPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.language,
                style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: languages.map((code) {
                final isSelected = currentCode == code;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => provider.setLocale(Locale(code)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: kPrimary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _getLanguageLabel(code),
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected ? Colors.white : kTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
