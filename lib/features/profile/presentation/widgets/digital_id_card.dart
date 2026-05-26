import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:grow/shared/widgets/neo_card.dart';

import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class DigitalIdCard extends StatefulWidget {
  const DigitalIdCard({
    super.key,
    required this.user,
    this.onAvatarTap,
    this.isUploading = false,
  });
  final UserModel user;
  final VoidCallback? onAvatarTap;
  final bool isUploading;

  @override
  State<DigitalIdCard> createState() => _DigitalIdCardState();
}

class _DigitalIdCardState extends State<DigitalIdCard>
    with SingleTickerProviderStateMixin {
  bool _isBack = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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
      color: Colors.white,
      borderColor: const Color(0xFF111111),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF111111),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                ),
                const Icon(Icons.bolt_rounded, color: Color(0xFF111111), size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onAvatarTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RC5Avatar(
                        imageUrl: widget.user.avatarUrl,
                        displayName: widget.user.name,
                        size: 56,
                      ),
                      if (widget.isUploading)
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white54,
                          child: CircularProgressIndicator(
                            color: Color(0xFF111111),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFF111111),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF111111),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.user.role.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EST. 2024',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF5D7),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF111111), width: 1.5),
                  ),
                  child: const Text(
                    'VERIFIED MAKER',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
      borderColor: const Color(0xFF111111),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Use this QR for lab access, tool checkout, and event attendance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            QrImageView(
              data: widget.user.qrCodeData ?? widget.user.id,
              version: QrVersions.auto,
              size: 80,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
