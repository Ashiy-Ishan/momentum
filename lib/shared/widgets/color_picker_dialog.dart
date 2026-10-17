import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class ColorPickerDialog extends StatefulWidget {
  final String? selectedColorHex;

  const ColorPickerDialog({
    super.key,
    this.selectedColorHex,
  });

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
    '#C4A480',
    '#A87C5C',
    '#C28D4E',
    '#4E9B78',
    '#5D8568',
    '#5B82A6',
    '#6889A4',
    '#5E7A96',
    '#A06B82',
    '#BD5B5B',
    '#B85454',
    '#7E7B92',
    '#788D98',
    '#94A3B8',
    '#64748B',
    '#1E293B',
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
      final val = int.tryParse('FF$clean', radix: 16);
      if (val != null) return Color(val);
    } else if (clean.length == 8) {
      final val = int.tryParse(clean, radix: 16);
      if (val != null) return Color(val);
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
