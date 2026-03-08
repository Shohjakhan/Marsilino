import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../domain/cashback/cashback_cubit.dart';
import '../../domain/qr/qr_cubit.dart';
import '../../domain/qr/qr_state.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../../data/repositories/rating_repository.dart';

/// QR Scan page with camera preview, receipt display, and cashback redemption.
///
/// When opened from a restaurant page, pass [restaurantId], [restaurantName],
/// and [cashbackPercent] so the scanner knows the cashback rate.
/// When opened from the navbar (standalone), leave these null.
class QrScanPage extends StatefulWidget {
  final String? restaurantId;
  final String? restaurantName;
  final int? cashbackPercent;

  const QrScanPage({
    super.key,
    this.restaurantId,
    this.restaurantName,
    this.cashbackPercent,
  });

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  late final QrCubit _qrCubit;
  late final CashbackCubit _cashbackCubit;
  late final MobileScannerController _scannerController;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _cashbackCubit = CashbackCubit();
    _qrCubit = QrCubit(
      cashbackCubit: _cashbackCubit,
      restaurantId: widget.restaurantId,
      restaurantName: widget.restaurantName,
      cashbackPercent: widget.cashbackPercent,
    );
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _qrCubit.close();
    _cashbackCubit.close();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final qrData = barcodes.first.rawValue;
    if (qrData == null || qrData.isEmpty) return;

    setState(() => _hasScanned = true);
    _scannerController.stop();
    _qrCubit.onQrScanned(qrData);
  }

  void _resetScanner() {
    setState(() => _hasScanned = false);
    _scannerController.start();
  }

  String _formatNumber(double number) {
    final intValue = number.round();
    final text = intValue.toString();
    final buffer = StringBuffer();
    final len = text.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  /// Whether this page was opened from a restaurant page (vs. navbar).
  bool get _hasRestaurantContext => widget.restaurantId != null;

  void _showRatingSheet() {
    if (widget.restaurantId == null || widget.restaurantName == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RatingBottomSheet(
        restaurantId: widget.restaurantId!,
        restaurantName: widget.restaurantName!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _qrCubit,
      child: Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          title: Text(
            _hasRestaurantContext
                ? 'Scan Receipt — ${widget.restaurantName}'
                : 'Scan QR Code',
            style: kTitleStyle.copyWith(fontSize: 17),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<QrCubit, QrState>(
          listener: (context, state) {
            if (state.redeemed && state.receipt?.alreadyRedeemed == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.cashbackAddedWallet),
                  backgroundColor: kSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
              // Show rating sheet after redeeming
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) _showRatingSheet();
              });
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: kError,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoadingReceipt) {
              return _buildLoadingView(l10n);
            }
            if (state.receipt != null) {
              return _buildReceiptView(state, l10n);
            }
            return _buildScannerView(l10n);
          },
        ),
      ),
    );
  }

  Widget _buildScannerView(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kCardRadius),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                  // Scanner overlay
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kPrimaryBold.withValues(alpha: 0.6),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                  // Corner accents
                  ..._buildCornerAccents(),
                ],
              ),
            ),
          ),
        ),
        // Instructions
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [kCardShadow],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: kPrimaryBold,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.pointAtQr,
                      style: kSubtitleStyle.copyWith(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _hasRestaurantContext
                    ? l10n.scanReceiptFor(widget.restaurantName!)
                    : l10n.scanFiscalReceipt,
                style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 13),
              ),
              if (_hasRestaurantContext && widget.cashbackPercent != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.cashbackRate(widget.cashbackPercent!),
                  style: kBodyStyle.copyWith(
                    color: kPrimaryBold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerAccents() {
    return [
      Positioned.fill(
        child: Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: _cornerPiece(borderTop: true, borderLeft: true),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _cornerPiece(borderTop: true, borderRight: true),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _cornerPiece(borderBottom: true, borderLeft: true),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _cornerPiece(borderBottom: true, borderRight: true),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _cornerPiece({
    bool borderTop = false,
    bool borderBottom = false,
    bool borderLeft = false,
    bool borderRight = false,
  }) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: borderTop
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          bottom: borderBottom
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          left: borderLeft
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          right: borderRight
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoadingView(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: kPrimaryBold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBold),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.fetchingReceipt,
            style: kSubtitleStyle.copyWith(color: kTextPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.verifyingFiscal,
            style: kBodyStyle.copyWith(color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptView(QrState state, AppLocalizations l10n) {
    final receipt = state.receipt!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kSuccess.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long, size: 40, color: kSuccess),
          ),
          const SizedBox(height: 16),
          Text(l10n.receiptVerified, style: kTitleStyle.copyWith(fontSize: 20)),
          const SizedBox(height: 32),

          // Receipt card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(kCardRadius),
              boxShadow: const [kCardShadow],
            ),
            child: Column(
              children: [
                _buildReceiptRow(
                  l10n.restaurantLabel,
                  receipt.restaurantName,
                  icon: Icons.restaurant,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildReceiptRow(
                  l10n.receiptNumberLabel,
                  receipt.receiptNumber,
                  icon: Icons.tag,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildReceiptRow(
                  l10n.dateLabel,
                  '${receipt.createdAt.day}.${receipt.createdAt.month.toString().padLeft(2, '0')}.${receipt.createdAt.year}',
                  icon: Icons.calendar_today,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildReceiptRow(
                  l10n.totalPaidLabel,
                  'UZS ${_formatNumber(receipt.totalAmount)}',
                  icon: Icons.payments,
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cashback card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryBold, kPrimaryBold.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(kCardRadius),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryBold.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  l10n.cashbackEarned,
                  style: kBodyStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'UZS ${_formatNumber(state.calculatedCashback)}',
                  style: kTitleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_hasRestaurantContext &&
                    widget.cashbackPercent != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.cashbackPctFrom(
                      widget.cashbackPercent!,
                      widget.restaurantName!,
                    ),
                    style: kBodyStyle.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Redeem button / Success State
          if (!state.redeemed)
            PrimaryButton(
              label: l10n.redeemCashbackBtn,
              onPressed: () => _qrCubit.redeemCashback(),
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        (receipt.alreadyRedeemed ? kSecondaryLight : kSuccess)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          (receipt.alreadyRedeemed ? kSecondaryLight : kSuccess)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        receipt.alreadyRedeemed
                            ? Icons.info_outline
                            : Icons.check_circle,
                        color: receipt.alreadyRedeemed
                            ? kSecondaryLight
                            : kSuccess,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        receipt.alreadyRedeemed
                            ? 'Receipt already redeemed'
                            : l10n.cashbackRedeemed,
                        style: kSubtitleStyle.copyWith(
                          color: receipt.alreadyRedeemed
                              ? kSecondaryLight
                              : kSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.scanAnother,
                  onPressed: () {
                    _qrCubit.reset();
                    _resetScanner();
                  },
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Scan again (always visible before redeem)
          if (!state.redeemed)
            TextButton(
              onPressed: () {
                _qrCubit.reset();
                _resetScanner();
              },
              child: Text(
                l10n.scanAgain,
                style: kSubtitleStyle.copyWith(
                  color: kPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    IconData? icon,
    bool bold = false,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: kTextSecondary),
          const SizedBox(width: 10),
        ],
        Text(label, style: kBodyStyle.copyWith(color: kTextSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: kBodyStyle.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rating bottom sheet
// ---------------------------------------------------------------------------

class _RatingBottomSheet extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const _RatingBottomSheet({
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<_RatingBottomSheet>
    with TickerProviderStateMixin {
  int _selectedRating = 0;
  bool _isSubmitting = false;
  bool _submitted = false;
  final RatingRepository _ratingRepository = RatingRepository();

  // Animation controllers for each star
  late final List<AnimationController> _starControllers;
  late final List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();
    _starControllers = List.generate(
      5,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _starAnimations = _starControllers.map((c) {
      return Tween<double>(
        begin: 1.0,
        end: 1.35,
      ).animate(CurvedAnimation(parent: c, curve: Curves.elasticOut));
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _starControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _selectRating(int rating) {
    setState(() => _selectedRating = rating);
    // Animate all filled stars
    for (int i = 0; i < 5; i++) {
      if (i < rating) {
        Future.delayed(Duration(milliseconds: i * 60), () {
          if (mounted) {
            _starControllers[i].forward(from: 0);
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) return;
    setState(() => _isSubmitting = true);

    try {
      await _ratingRepository.submitRating(
        restaurantId: widget.restaurantId,
        rating: _selectedRating,
      );
    } catch (_) {
      // Silently ignore — rating is optional
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kTextSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          if (_submitted) ...[
            // Success state
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kSuccess.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: kSuccess,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.ratingThanks,
              style: kTitleStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            // Rating emoji based on selection
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _selectedRating == 0
                    ? '🤔'
                    : _selectedRating == 1
                    ? '😞'
                    : _selectedRating == 2
                    ? '😐'
                    : _selectedRating == 3
                    ? '🙂'
                    : _selectedRating == 4
                    ? '😊'
                    : '🤩',
                key: ValueKey(_selectedRating),
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.rateYourExperience,
              style: kTitleStyle.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.rateExperienceSub(widget.restaurantName),
              style: kBodyStyle.copyWith(color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _selectedRating;
                return GestureDetector(
                  onTap: () => _selectRating(i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedBuilder(
                      animation: _starAnimations[i],
                      builder: (_, child) => Transform.scale(
                        scale: filled ? _starAnimations[i].value : 1.0,
                        child: child,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: filled
                              ? const Color(0xFFFFB800)
                              : kTextSecondary.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            // Rating label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _selectedRating == 0
                    ? ''
                    : _selectedRating == 1
                    ? 'Poor'
                    : _selectedRating == 2
                    ? 'Fair'
                    : _selectedRating == 3
                    ? 'Good'
                    : _selectedRating == 4
                    ? 'Great'
                    : 'Excellent!',
                key: ValueKey(_selectedRating),
                style: kSubtitleStyle.copyWith(
                  color: _selectedRating >= 4
                      ? const Color(0xFFFFB800)
                      : kTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedRating == 0 || _isSubmitting
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBold,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kTextSecondary.withValues(
                    alpha: 0.15,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kButtonRadius),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        l10n.submitRating,
                        style: kSubtitleStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Skip
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.skipRating,
                style: kBodyStyle.copyWith(color: kTextSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
