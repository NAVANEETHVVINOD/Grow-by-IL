import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../models/user_model.dart';
import 'neo_card.dart';

/// Widget that shows the user's personal QR code for lab check-in.
class UserQrCard extends StatelessWidget {
  const UserQrCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final qrData = user.qrCodeData ?? 'GROWLAB-USER-${user.id}';

    return NeoCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.navy,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            user.name,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            '@${user.username ?? 'user'}',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (user.collegeRoll != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              user.collegeRoll!,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper to show the user's QR card in a bottom sheet.
void showUserQrCard(BuildContext context, UserModel user) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My QR Card',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            UserQrCard(user: user),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      );
    },
  );
}
