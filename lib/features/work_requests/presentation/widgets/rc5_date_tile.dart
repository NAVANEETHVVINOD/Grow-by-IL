import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';

class RC5DateTile extends StatelessWidget {
  const RC5DateTile({
    super.key,
    required this.date,
    required this.onPickDate,
    required this.onClearDate,
  });

  final DateTime? date;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: date == null
          ? 'Select preferred completion date'
          : 'Preferred completion date is ${DateFormat.yMMMd().format(date!)}',
      child: RC5Card(
        onTap: onPickDate,
        padding: const EdgeInsets.all(16),
        radius: 18,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: RC5DesignTokens.accent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: RC5DesignTokens.ink,
                  width: RC5DesignTokens.borderWidth,
                ),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: RC5DesignTokens.ink,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferred completion date',
                    style: RC5DesignTokens.body.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date == null
                        ? 'Tap to select target date'
                        : DateFormat.yMMMMd().format(date!),
                    style: RC5DesignTokens.body.copyWith(
                      fontSize: 12,
                      color: date == null
                          ? RC5DesignTokens.textSecondary
                          : RC5DesignTokens.ink,
                      fontWeight:
                          date == null ? FontWeight.normal : FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null)
              IconButton(
                tooltip: 'Clear selected date',
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onClearDate,
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: RC5DesignTokens.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
