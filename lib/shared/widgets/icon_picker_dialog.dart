import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// A searchable dialog that allows users to select an icon from [AppIcons].
///
/// Features:
/// - Category tabs (Productivity, Learning, Content Creation, Social Media, Personal, Technical)
/// - Real-time search filter by icon name or category
/// - Grid layout with hover feedback and clear selection indicators
/// - Helper [show] method returning the selected icon name string.
class IconPickerDialog extends StatefulWidget {
  final String? initialIconName;

  const IconPickerDialog({
    super.key,
    this.initialIconName,
  });

  /// Displays the icon picker dialog and returns the selected icon name, or `null` if cancelled.
  static Future<String?> show(
    BuildContext context, {
    String? initialIconName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => IconPickerDialog(
        initialIconName: initialIconName,
      ),
    );
  }

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  String? _selectedIconName;
  String _searchQuery = '';

  final List<IconCategory> _categories = AppIcons.categories;

  @override
  void initState() {
    super.initState();
    _selectedIconName = widget.initialIconName;
    _searchController = TextEditingController();
    _tabController = TabController(length: _categories.length, vsync: this);

    // If initial icon is provided, attempt to switch to its category tab
    if (_selectedIconName != null) {
      final initialItem = AppIcons.allIcons.firstWhere(
        (i) => i.name.toLowerCase() == _selectedIconName!.toLowerCase(),
        orElse: () => AppIcons.allIcons.first,
      );
      final catIndex = _categories.indexWhere(
        (c) => c.name.toLowerCase() == initialItem.category.toLowerCase(),
      );
      if (catIndex != -1) {
        _tabController.index = catIndex;
      }
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSearching = _searchQuery.isNotEmpty;

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: AppRadius.shapeLg,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 580,
          maxHeight: 640,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -----------------------------------------------------------------
            // Header
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: AppSpacing.allSm,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainerLight,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: Text(
                      'Choose Icon',
                      style: AppTypography.titleLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // Search Input
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search icons by name or category...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            AppSpacing.vGapXs,

            // -----------------------------------------------------------------
            // Category Tabs or Search Results Header
            // -----------------------------------------------------------------
            if (!isSearching)
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                tabs: _categories
                    .map((cat) => Tab(text: cat.name))
                    .toList(growable: false),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'Search Results for "$_searchQuery"',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            const Divider(height: 1),

            // -----------------------------------------------------------------
            // Icon Grids Content
            // -----------------------------------------------------------------
            Expanded(
              child: isSearching
                  ? _buildSearchResultsGrid(colorScheme)
                  : TabBarView(
                      controller: _tabController,
                      children: _categories.map((category) {
                        return _buildIconGrid(category.icons, colorScheme);
                      }).toList(growable: false),
                    ),
            ),

            const Divider(height: 1),

            // -----------------------------------------------------------------
            // Dialog Action Buttons & Selected Preview
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (_selectedIconName != null) ...[
                    Container(
                      padding: AppSpacing.allSm,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(color: colorScheme.primary, width: 1),
                      ),
                      child: Icon(
                        AppIcons.fromName(_selectedIconName!),
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Text(
                        _selectedIconName!,
                        style: AppTypography.labelMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        'No icon selected',
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  AppSpacing.hGapSm,
                  ElevatedButton(
                    onPressed: _selectedIconName != null
                        ? () => Navigator.of(context).pop(_selectedIconName)
                        : null,
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsGrid(ColorScheme colorScheme) {
    final results = AppIcons.search(_searchQuery);

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: colorScheme.onSurfaceVariant.withAlpha(120),
              ),
              AppSpacing.vGapSm,
              Text(
                'No icons found matching "$_searchQuery"',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return _buildIconGrid(results, colorScheme);
  }

  Widget _buildIconGrid(List<IconItem> icons, ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 80,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.9,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final item = icons[index];
        final isSelected = _selectedIconName?.toLowerCase() == item.name.toLowerCase();

        return _IconGridTile(
          item: item,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedIconName = item.name;
            });
          },
          onDoubleTap: () {
            Navigator.of(context).pop(item.name);
          },
        );
      },
    );
  }
}

class _IconGridTile extends StatelessWidget {
  final IconItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const _IconGridTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: '${item.name} (${item.category})',
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withAlpha(80),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: BorderSide(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          borderRadius: AppRadius.borderMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.iconData,
                  size: 26,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                AppSpacing.vGapXxs,
                Text(
                  item.name,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
