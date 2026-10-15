import 'package:flutter/widgets.dart';

/// Standardized spacing metrics, paddings, and sized gap helpers for Momentum.
///
/// Follows an 8pt grid with 4pt half-steps for fine-grained alignments.
abstract class AppSpacing {
  // ---------------------------------------------------------------------------
  // Base Spacing Tokens
  // ---------------------------------------------------------------------------
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ---------------------------------------------------------------------------
  // EdgeInsets Helpers - All Sides
  // ---------------------------------------------------------------------------
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets allXxs = EdgeInsets.all(xxs);
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  // ---------------------------------------------------------------------------
  // EdgeInsets Helpers - Horizontal Only
  // ---------------------------------------------------------------------------
  static const EdgeInsets hXxs = EdgeInsets.symmetric(horizontal: xxs);
  static const EdgeInsets hXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets hSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets hMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets hLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets hXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets hXxl = EdgeInsets.symmetric(horizontal: xxl);

  // ---------------------------------------------------------------------------
  // EdgeInsets Helpers - Vertical Only
  // ---------------------------------------------------------------------------
  static const EdgeInsets vXxs = EdgeInsets.symmetric(vertical: xxs);
  static const EdgeInsets vXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets vSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets vMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets vLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets vXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets vXxl = EdgeInsets.symmetric(vertical: xxl);

  // ---------------------------------------------------------------------------
  // Component & Screen Paddings
  // ---------------------------------------------------------------------------
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets screenPaddingLg = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingDense = EdgeInsets.all(sm);
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 12.0,
  );
  static const EdgeInsets buttonPaddingDense = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 14.0,
  );

  // ---------------------------------------------------------------------------
  // SizedBox Helpers - Vertical Spacing
  // ---------------------------------------------------------------------------
  static const Widget vGapXxs = SizedBox(height: xxs);
  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGapXl = SizedBox(height: xl);
  static const Widget vGapXxl = SizedBox(height: xxl);
  static const Widget vGapXxxl = SizedBox(height: xxxl);

  // ---------------------------------------------------------------------------
  // SizedBox Helpers - Horizontal Spacing
  // ---------------------------------------------------------------------------
  static const Widget hGapXxs = SizedBox(width: xxs);
  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);
  static const Widget hGapXxl = SizedBox(width: xxl);
  static const Widget hGapXxxl = SizedBox(width: xxxl);

  // ---------------------------------------------------------------------------
  // Dynamic Sized Gap Generators
  // ---------------------------------------------------------------------------
  static Widget vGap(double height) => SizedBox(height: height);
  static Widget hGap(double width) => SizedBox(width: width);
}
