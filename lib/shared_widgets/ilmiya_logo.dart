import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class IlmiyaLogo extends StatelessWidget {
  final double size;
  final bool isSquircle;
  final Color? color;

  const IlmiyaLogo({
    super.key,
    this.size = 40,
    this.isSquircle = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isSquircle) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: CustomPaint(
            size: Size(size * 0.65, size * 0.65),
            painter: _IlmiyaSymbolPainter(color: Colors.white),
          ),
        ),
      );
    }

    return CustomPaint(
      size: Size(size, size),
      painter: _IlmiyaSymbolPainter(color: color ?? AppColors.forestSage),
    );
  }
}

class _IlmiyaSymbolPainter extends CustomPainter {
  final Color color;

  _IlmiyaSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..isAntiAlias = true;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Graduation Mortarboard Top Polygon
    final capPath = Path();
    capPath.moveTo(50, 14);
    capPath.lineTo(78, 25);
    capPath.lineTo(50, 36);
    capPath.lineTo(22, 25);
    capPath.close();
    canvas.drawPath(capPath, paint);

    // 2. Skull Cap Base
    final baseCapPath = Path();
    baseCapPath.moveTo(34, 29.5);
    baseCapPath.lineTo(34, 38);
    baseCapPath.cubicTo(34, 44, 66, 44, 66, 38);
    baseCapPath.lineTo(66, 29.5);
    canvas.drawPath(baseCapPath, strokePaint);

    // 3. Tassel
    final tasselPath = Path();
    tasselPath.moveTo(68, 28.5);
    tasselPath.cubicTo(68.5, 35, 69, 40, 69, 44);
    tasselPath.cubicTo(67.5, 45.5, 69, 48, 70, 48);
    tasselPath.cubicTo(71, 48, 72.5, 45.5, 71, 44);
    tasselPath.cubicTo(71, 40, 70.5, 35, 70, 28.5);
    tasselPath.close();
    canvas.drawPath(tasselPath, paint);

    // 4. Open Book Wings - Left Page
    final leftPagePath = Path();
    leftPagePath.moveTo(19, 46.5);
    leftPagePath.lineTo(23, 46.5);
    leftPagePath.lineTo(23, 68);
    leftPagePath.cubicTo(23, 72, 32, 75, 48, 79);
    leftPagePath.lineTo(48, 83.5);
    leftPagePath.cubicTo(30, 79.5, 19, 76, 19, 70);
    leftPagePath.close();
    canvas.drawPath(leftPagePath, paint);

    // 5. Open Book Wings - Right Page
    final rightPagePath = Path();
    rightPagePath.moveTo(81, 46.5);
    rightPagePath.lineTo(77, 46.5);
    rightPagePath.lineTo(77, 68);
    rightPagePath.cubicTo(77, 72, 68, 75, 52, 79);
    rightPagePath.lineTo(52, 83.5);
    rightPagePath.cubicTo(70, 79.5, 81, 76, 81, 70);
    rightPagePath.close();
    canvas.drawPath(rightPagePath, paint);

    // 6. Center Pages
    final centerLeft = Path();
    centerLeft.moveTo(33, 41);
    centerLeft.cubicTo(34, 40, 45, 40, 48, 44.5);
    centerLeft.lineTo(48, 73);
    centerLeft.cubicTo(44, 69.5, 34, 69, 33, 69.5);
    centerLeft.close();
    canvas.drawPath(centerLeft, paint);

    final centerRight = Path();
    centerRight.moveTo(67, 41);
    centerRight.cubicTo(66, 40, 55, 40, 52, 44.5);
    centerRight.lineTo(52, 73);
    centerRight.cubicTo(56, 69.5, 66, 69, 67, 69.5);
    centerRight.close();
    canvas.drawPath(centerRight, paint);

    // 7. Bottom Arc Ribbon
    final ribbonPath = Path();
    ribbonPath.moveTo(20, 73.5);
    ribbonPath.cubicTo(34, 80, 46, 84, 50, 86);
    ribbonPath.cubicTo(54, 84, 66, 80, 80, 73.5);
    ribbonPath.cubicTo(81.5, 73, 82.5, 74, 82, 75.5);
    ribbonPath.cubicTo(76, 83, 62, 88.5, 50, 89);
    ribbonPath.cubicTo(38, 88.5, 24, 83, 18, 75.5);
    ribbonPath.close();
    canvas.drawPath(ribbonPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IlmiyaSymbolPainter oldDelegate) =>
      oldDelegate.color != color;
}
