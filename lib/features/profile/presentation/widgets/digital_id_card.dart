import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../auth/shared/models/user_model.dart';
import '../../../../shared/widgets/neo_card.dart';

class DigitalIdCard extends StatefulWidget {
  const DigitalIdCard({super.key, required this.user});
  final UserModel user;

  @override
  State<DigitalIdCard> createState() => _DigitalIdCardState();
}

class _DigitalIdCardState extends State<DigitalIdCard> with SingleTickerProviderStateMixin {
  bool _isBack = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _isBack = !_isBack);
    if (_isBack) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.14159;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: angle < 1.5708
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return NeoCard(
      color: AppColors.navy,
      borderColor: AppColors.yellow,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GROW~ MEMBER',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Icon(Icons.bolt_rounded, color: AppColors.yellow),
              ],
            ),
            const Spacer(),
            Text(
              widget.user.name.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.user.baseRole.toUpperCase(),
              style: GoogleFonts.dmSans(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EST. 2024',
                  style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 10),
                ),
                const Text(
                  'VERIFIED MAKER',
                  style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return NeoCard(
      color: Colors.white,
      borderColor: AppColors.navy,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SCAN TO IDENTIFY',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use this QR for lab access, tool checkout, and event attendance.',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.md),
            QrImageView(
              data: widget.user.qrCodeData ?? widget.user.id,
              version: QrVersions.auto,
              size: 100,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.navy),
            ),
          ],
        ),
      ),
    );
  }
}
