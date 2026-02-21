import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/cashback/cashback_cubit.dart';
import '../../domain/qr/qr_cubit.dart';
import '../../domain/qr/qr_state.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';

/// QR Scan page with camera preview, receipt display, and cashback redemption.
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

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
    _qrCubit = QrCubit(cashbackCubit: _cashbackCubit);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _qrCubit,
      child: Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          title: Text('Scan QR Code', style: kTitleStyle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<QrCubit, QrState>(
          listener: (context, state) {
            if (state.redeemed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cashback added to your wallet!'),
                  backgroundColor: kSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
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
              return _buildLoadingView();
            }
            if (state.receipt != null) {
              return _buildReceiptView(state);
            }
            return _buildScannerView();
          },
        ),
      ),
    );
  }

  Widget _buildScannerView() {
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
                      'Point at receipt QR code',
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
                'Scan the fiscal receipt to earn cashback',
                style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerAccents() {
    return [
      // We'll use a simpler approach — centered overlay corners
      Positioned.fill(
        child: Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              children: [
                // Top-left
                Positioned(
                  top: 0,
                  left: 0,
                  child: _cornerPiece(borderTop: true, borderLeft: true),
                ),
                // Top-right
                Positioned(
                  top: 0,
                  right: 0,
                  child: _cornerPiece(borderTop: true, borderRight: true),
                ),
                // Bottom-left
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _cornerPiece(borderBottom: true, borderLeft: true),
                ),
                // Bottom-right
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

  Widget _buildLoadingView() {
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
            'Fetching receipt...',
            style: kSubtitleStyle.copyWith(color: kTextPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifying with fiscal service',
            style: kBodyStyle.copyWith(color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptView(QrState state) {
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
          Text('Receipt Verified', style: kTitleStyle.copyWith(fontSize: 20)),
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
                  'Restaurant',
                  receipt.restaurantName,
                  icon: Icons.restaurant,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildReceiptRow(
                  'Receipt #',
                  receipt.receiptNumber,
                  icon: Icons.tag,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildReceiptRow(
                  'Date',
                  '${receipt.date.day}.${receipt.date.month.toString().padLeft(2, '0')}.${receipt.date.year}',
                  icon: Icons.calendar_today,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildReceiptRow(
                  'Total Paid',
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
                  'Cashback Earned',
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
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Redeem button
          if (!state.redeemed)
            PrimaryButton(
              label: 'Redeem Cashback',
              onPressed: () => _qrCubit.redeemCashback(),
            )
          else
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSuccess.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kSuccess.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: kSuccess, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Cashback Redeemed!',
                        style: kSubtitleStyle.copyWith(
                          color: kSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Scan Another',
                  onPressed: () {
                    _qrCubit.reset();
                    _resetScanner();
                  },
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Back button (always visible)
          if (!state.redeemed)
            TextButton(
              onPressed: () {
                _qrCubit.reset();
                _resetScanner();
              },
              child: Text(
                'Scan Again',
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
