# Run this from your project root: 
# PS C:\Users\stive\OneDrive\Desktop\MediFlow_Flutter> .\fix_light_mode.ps1

# Step 1: Create AppBackground widget file
$appBackground = @'
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Theme-aware background — dark mode gets deep navy gradient + stars,
/// light mode gets a clean soft teal-white gradient.
/// Drop-in replacement for StarfieldBackground.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: isDark ? const _DarkBg() : const _LightBg(),
        ),
        child,
      ],
    );
  }
}

class _DarkBg extends StatelessWidget {
  const _DarkBg();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.55),
              radius: 1.6,
              colors: [Color(0xFF0D2040), Color(0xFF05101E)],
            ),
          ),
        ),
        Positioned(
          bottom: -120, left: -80,
          child: Container(
            width: 320, height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x12006880), Color(0x00000000)],
              ),
            ),
          ),
        ),
        const _StarField(),
      ],
    );
  }
}

class _LightBg extends StatelessWidget {
  const _LightBg();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F8FA), Color(0xFFF5FDFE), Color(0xFFEAF7F5)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _StarPainter(), child: const SizedBox.expand());
}

class _StarPainter extends CustomPainter {
  static final _rng = math.Random(42);
  static final _stars = List.generate(55, (_) => (
    x: _rng.nextDouble(),
    y: _rng.nextDouble(),
    r: _rng.nextDouble() * 1.3 + 0.4,
    a: _rng.nextDouble() * 0.04 + 0.02,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()..color = Colors.white.withValues(alpha: s.a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
'@

Set-Content -Path "lib\core\widgets\app_background.dart" -Value $appBackground
Write-Host "✅ Created lib\core\widgets\app_background.dart"

# Step 2: In each screen file:
#   - Add import for app_background.dart
#   - Replace StarfieldBackground( with AppBackground(
#   - Replace scaffold backgroundColor hardcoded dark with Theme.of(context).scaffoldBackgroundColor

$screenFiles = Get-ChildItem -Path "lib\features" -Recurse -Filter "*.dart" |
    Where-Object { (Get-Content $_.FullName -Raw) -match "StarfieldBackground" }

foreach ($file in $screenFiles) {
    $content = Get-Content $file.FullName -Raw

    # Add import if not already present
    if ($content -notmatch "app_background\.dart") {
        $content = $content -replace "(import 'package:flutter/material\.dart';)", "`$1`nimport '../../../core/widgets/app_background.dart';"
        # Handle different import path depths
        $depth = ($file.FullName -split "\\features\\" | Select-Object -Last 1).Split("\").Count - 1
        $prefix = "../" * $depth + "../../"
        $content = $content -replace "import '\.\.\/\.\.\/\.\.\/core\/widgets\/app_background\.dart';", "import '${prefix}core/widgets/app_background.dart';"
    }

    # Replace StarfieldBackground( with AppBackground(
    $content = $content -replace "StarfieldBackground\(", "AppBackground("

    Set-Content -Path $file.FullName -Value $content
    Write-Host "✅ Updated $($file.Name)"
}

# Step 3: Fix scaffold background color to be theme-aware in screens
# (screens that hardcode backgroundColor: AppColors.bgPrimary or bgDark)
# We leave scaffold color as-is since AppBackground covers it — 
# the Scaffold itself should be transparent so AppBackground shows through.

$allDart = Get-ChildItem -Path "lib\features" -Recurse -Filter "*.dart"
foreach ($file in $allDart) {
    $content = Get-Content $file.FullName -Raw
    # Replace hardcoded dark scaffold bg with Colors.transparent so AppBackground shows
    $content = $content -replace "backgroundColor: AppColors\.bgPrimary,\s*(\r?\n\s*body: AppBackground)", "backgroundColor: Colors.transparent,`n      body: AppBackground"
    $content = $content -replace "backgroundColor: AppColors\.bgDark,\s*(\r?\n\s*body: AppBackground)", "backgroundColor: Colors.transparent,`n      body: AppBackground"
    Set-Content -Path $file.FullName -Value $content
}

Write-Host ""
Write-Host "✅ Light mode fix complete. Now run: dart analyze lib"