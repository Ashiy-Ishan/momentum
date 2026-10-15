import 'package:flutter/widgets.dart';

/// Border radius constants and reusable shape helpers for Momentum.
///
/// Designed with rounded corners (12-16px defaults) for Material 3 cards,
/// dialogs, input fields, buttons, and bottom sheets.
abstract class AppRadius {
  // ---------------------------------------------------------------------------
  // Double Constants
  // ---------------------------------------------------------------------------
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double full = 9999.0;

  // ---------------------------------------------------------------------------
  // Radius Objects
  // ---------------------------------------------------------------------------
  static const Radius rNone = Radius.zero;
  static const Radius rXs = Radius.circular(xs);
  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);
  static const Radius rXxl = Radius.circular(xxl);
  static const Radius rFull = Radius.circular(full);

  // ---------------------------------------------------------------------------
  // BorderRadius Objects (All Corners)
  // ---------------------------------------------------------------------------
  static const BorderRadius borderNone = BorderRadius.zero;
  static const BorderRadius borderXs = BorderRadius.all(rXs);
  static const BorderRadius borderSm = BorderRadius.all(rSm);
  static const BorderRadius borderMd = BorderRadius.all(rMd);
  static const BorderRadius borderLg = BorderRadius.all(rLg);
  static const BorderRadius borderXl = BorderRadius.all(rXl);
  static const BorderRadius borderXxl = BorderRadius.all(rXxl);
  static const BorderRadius borderFull = BorderRadius.all(rFull);

  // ---------------------------------------------------------------------------
  // Directional BorderRadius (Top Corners - Sheets, Headers)
  // ---------------------------------------------------------------------------
  static const BorderRadius topSm = BorderRadius.vertical(top: rSm);
  static const BorderRadius topMd = BorderRadius.vertical(top: rMd);
  static const BorderRadius topLg = BorderRadius.vertical(top: rLg);
  static const BorderRadius topXl = BorderRadius.vertical(top: rXl);
  static const BorderRadius topXxl = BorderRadius.vertical(top: rXxl);

  // ---------------------------------------------------------------------------
  // Directional BorderRadius (Bottom Corners)
  // ---------------------------------------------------------------------------
  static const BorderRadius bottomSm = BorderRadius.vertical(bottom: rSm);
  static const BorderRadius bottomMd = BorderRadius.vertical(bottom: rMd);
  static const BorderRadius bottomLg = BorderRadius.vertical(bottom: rLg);
  static const BorderRadius bottomXl = BorderRadius.vertical(bottom: rXl);
  static const BorderRadius bottomXxl = BorderRadius.vertical(bottom: rXxl);

  // ---------------------------------------------------------------------------
  // Directional BorderRadius (Horizontal)
  // ---------------------------------------------------------------------------
  static const BorderRadius rightSm = BorderRadius.horizontal(right: rSm);
  static const BorderRadius rightMd = BorderRadius.horizontal(right: rMd);
  static const BorderRadius rightLg = BorderRadius.horizontal(right: rLg);
  static const BorderRadius rightXl = BorderRadius.horizontal(right: rXl);

  static const BorderRadius leftSm = BorderRadius.horizontal(left: rSm);
  static const BorderRadius leftMd = BorderRadius.horizontal(left: rMd);
  static const BorderRadius leftLg = BorderRadius.horizontal(left: rLg);
  static const BorderRadius leftXl = BorderRadius.horizontal(left: rXl);

  // ---------------------------------------------------------------------------
  // RoundedRectangleBorder Shapes
  // ---------------------------------------------------------------------------
  static const RoundedRectangleBorder shapeXs = RoundedRectangleBorder(
    borderRadius: borderXs,
  );
  static const RoundedRectangleBorder shapeSm = RoundedRectangleBorder(
    borderRadius: borderSm,
  );
  static const RoundedRectangleBorder shapeMd = RoundedRectangleBorder(
    borderRadius: borderMd,
  );
  static const RoundedRectangleBorder shapeLg = RoundedRectangleBorder(
    borderRadius: borderLg,
  );
  static const RoundedRectangleBorder shapeXl = RoundedRectangleBorder(
    borderRadius: borderXl,
  );
  static const RoundedRectangleBorder shapeXxl = RoundedRectangleBorder(
    borderRadius: borderXxl,
  );
  static const RoundedRectangleBorder shapeFull = RoundedRectangleBorder(
    borderRadius: borderFull,
  );
}
