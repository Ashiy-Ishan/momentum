import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Modal dialog allowing the user to select a color from a preset palette.
class ColorPickerDialog extends StatefulWidget {
  final String? selectedColorHex;

  const ColorPickerDialog({
    super.key,
    this.selectedColorHex,
  });

  /// Displays the color picker and returns hex string (e.g. "#4F46E5") or null.
  static Future<String?> show(
    BuildContext context, {
    String? selectedColorHex,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => ColorPickerDialog(selectedColorHex: selectedColorHex),
    );
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  static const List<String> _presetHexColors = [
    '#4F46E5', // Indigo
    '#6366F1', // Light Indigo
    '#8B5CF6', // Violet
    '#A855F7', // Purple
    '#EC4899', // Pink
    '#F43F5E', // Rose
    '#EF4444', // Red
    '#F97316', // Orange
    '#F59E0B', // Amber
    '#84CC16', // Lime
    '#10B981', // Emerald
    '#14B8A6', // Teal
    '#06B6D4', // Cyan
    '#3B82F6', // Blue
    '#64748B', // Slate
    '#1E293B', // Dark Slate
  ];

  late String _selectedHex;

  @override
  void initState() {
    super.initState();
    _selectedHex = widget.selectedColorHex ?? _presetHexColors.first;
  }

  Color _colorFromHex(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    } else if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: AppSpacing.allMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Color',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              AppSpacing.vGapSm,
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _presetHexColors.map((hex) {
                  final color = _colorFromHex(hex);
                  final isSelected =
                      _selectedHex.toLowerCase() == hex.toLowerCase();

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedHex = hex);
                      Navigator.of(context).pop(hex);
                    },
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.vGapLg,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  AppSpacing.hGapSm,
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selectedHex),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
