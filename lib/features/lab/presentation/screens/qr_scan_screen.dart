import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/lab_providers.dart';
import '../domain/tool_providers.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  bool _hasScanned = false;
  bool _isSuccess = false;
  String _resultMessage = '';

  @override
  Widget build(BuildContext context) {
    // On web, show a simulator instead of camera
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('QR Simulator (Web)', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bug_report_rounded, size: 64, color: AppColors.yellow),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Simulation Mode',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Choose a QR to simulate for testing:',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.xl),
                _buildSimulationButton('Visitor Check-In', 'GROWLAB-USER-test-id'),
                const SizedBox(height: AppSizes.md),
                _buildSimulationButton('Tool: 3D Printer', 'GROWLAB-TOOL-test-tool-id'),
                const SizedBox(height: AppSizes.xl),
                NeoButton(
                  label: 'Cancel',
                  width: 140,
                  onPressed: () => Navigator.pop(context),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 64),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'Camera Error: ${error.errorCode}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    NeoButton(
                      label: 'Go Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
          // Dark overlay with scanning frame
          _buildOverlay(),
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'Scan QR Code',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Result overlay
          if (_hasScanned) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildSimulationButton(String label, String value) {
    return NeoButton(
      label: label,
      onPressed: () => _processScan(value),
    );
  }

  Widget _buildOverlay() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isSuccess ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: _isSuccess ? AppColors.green : AppColors.red,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              _resultMessage,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    _processScan(barcode.rawValue!);
  }

  Future<void> _processScan(String value) async {
    log('QR Scanned: $value');
    setState(() {
      _hasScanned = true;
    });

    try {
      if (value.startsWith('GROWLAB-USER-')) {
        await _handleUserScan(value);
      } else if (value.startsWith('GROWLAB-TOOL-')) {
        await _handleToolScan(value);
      } else {
        throw Exception('Invalid QR code');
      }
      
      setState(() {
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _resultMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }

    // Auto-close or reset
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      if (_isSuccess) {
        Navigator.pop(context);
      } else {
        setState(() => _hasScanned = false);
      }
    }
  }

  Future<void> _handleUserScan(String value) async {
    final userId = value.replaceFirst('GROWLAB-USER-', '');
    final repo = ref.read(labRepositoryProvider);
    await repo.checkIn(userId, 'QR check-in');
    ref.invalidate(activeSessionProvider);
    ref.invalidate(liveLabVisitorCountProvider);
    _resultMessage = 'User Checked In!';
  }

  Future<void> _handleToolScan(String value) async {
    final toolId = value.replaceFirst('GROWLAB-TOOL-', '');
    final toolRepo = ref.read(toolRepositoryProvider);
    final user = ref.read(currentUserProvider).valueOrNull;
    
    if (user == null) throw Exception('User not logged in');

    // Fetch user bookings for this tool
    final bookings = await toolRepo.getMyBookings(user.id);
    
    // 1. Check for Active booking (Return Flow)
    final activeBooking = bookings.where((b) => b.toolId == toolId && b.status == 'active').firstOrNull;
    if (activeBooking != null) {
      await toolRepo.returnTool(activeBooking.id);
      ref.invalidate(myBookingsProvider);
      _resultMessage = 'Tool Returned! +10 XP';
      return;
    }

    // 2. Check for Approved booking (Checkout Flow)
    final approvedBooking = bookings.where((b) => b.toolId == toolId && b.status == 'approved').firstOrNull;
    if (approvedBooking != null) {
      await toolRepo.checkoutTool(approvedBooking.id);
      ref.invalidate(myBookingsProvider);
      _resultMessage = 'Checkout Successful!';
      return;
    }

    throw Exception('No approved or active booking found for this tool.');
  }
}
