import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/shared/widgets/neo_card.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  int _selectedAmountIndex = -1;

  @override
  Widget build(BuildContext context) {
    final donationAmounts = ['₹100', '₹500', '₹1000', 'Custom'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Support grow',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text(
              "Don't just dream of a better future",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
                letterSpacing: -1,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'IDEA Lab runs as a community-driven open innovation makerspace. Your contributions directly fund material costs, machine maintenance, and free tech workshops for young creators.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Donation Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: donationAmounts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final amount = donationAmounts[index];
                final isSelected = index == _selectedAmountIndex;
                return NeoCard(
                  color: isSelected ? const Color(0xFFFFEA00) : Colors.white,
                  onTap: () => setState(() => _selectedAmountIndex = index),
                  child: Center(
                    child: Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            NeoCard(
              color: const Color(0xFFFF8EFA),
              padding: const EdgeInsets.symmetric(vertical: 16),
              onTap: () {
                if (_selectedAmountIndex == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select an amount to proceed.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you so much for your support!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volunteer_activism_rounded,
                        color: AppColors.navy),
                    SizedBox(width: 8),
                    Text(
                      'Donate & Support Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
