import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../styles/app_theme.dart';
import '../../logic/cycle_provider.dart'; // For CyclePhase

class CycleRing extends StatefulWidget {
  final int daysRemaining;
  final String label;
  final double progress; // 0.0 to 1.0
  final Color color;
  final bool isPeriod;
  final CyclePhase phase;
  final double periodProbability; // For the fuzzy arc

  const CycleRing({
    super.key,
    required this.daysRemaining,
    required this.label,
    required this.progress,
    required this.color,
    this.isPeriod = false,
    this.phase = CyclePhase.follicular,
    this.periodProbability = 0.0,
  });

  @override
  State<CycleRing> createState() => _CycleRingState();
}

class _CycleRingState extends State<CycleRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CycleRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: oldWidget.progress, end: widget.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPhaseTitle() {
    if (widget.isPeriod) return "Règles";
    switch (widget.phase) {
      case CyclePhase.follicular: return "Folliculaire";
      case CyclePhase.ovulation: return "Ovulation";
      case CyclePhase.luteal: return "Lutéale";
      default: return "";
    }
  }

  String _getPhaseEmoji() {
    if (widget.isPeriod) return "🩸";
    switch (widget.phase) {
      case CyclePhase.follicular: return "⚡"; // Energy
      case CyclePhase.ovulation: return "🥚"; // Fertility
      case CyclePhase.luteal: return "🌙"; // Calm/Cocooning
      default: return "✨";
    }
  }

  String _getPhaseSubtitle() {
    if (widget.isPeriod) return "Jour ${widget.daysRemaining}";
    
    if (widget.daysRemaining == 0) return "Attendue aujourd'hui";
    if (widget.daysRemaining == 1) return "Attendue demain";
    
    return "Règles dans ${widget.daysRemaining}j";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320, // Increased size
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withOpacity(0.15),
                  widget.color.withOpacity(0.0),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          
          // The Compass Painter
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(280, 280),
                painter: _CompassPainter(
                  progress: _animation.value,
                  color: widget.color,
                  trackColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white24 
                      : const Color(0xFFEEEEEE),
                  isIrregular: widget.periodProbability > 0.0 && widget.periodProbability < 0.8,
                ),
              );
            },
          ),

          // Central Content - The "Insight"
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji / Icon
              Container(
                padding: const EdgeInsets.all(16), // Increased padding
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _getPhaseEmoji(),
                  style: const TextStyle(fontSize: 42), // Increased font size
                ),
              ),
              const SizedBox(height: 16),
              
              // Main Phase Title
              Text(
                _getPhaseTitle(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800, // Bolder
                  letterSpacing: -0.5,
                  fontSize: 28, // Increased font size
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Days Remaining (Demoted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined, 
                      size: 16, 
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getPhaseSubtitle(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Slightly larger
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Small "AI Active" Indicator on the ring
          Positioned(
            bottom: 24,
            child: widget.periodProbability > 0.0 ? _buildAIIndicator() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrand,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrand.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 12),
          SizedBox(width: 6),
          Text(
            "IA Active",
            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final bool isIrregular;

  _CompassPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    this.isIrregular = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 16.0; // Thicker ring

    // Draw Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    canvas.drawCircle(center, radius, trackPaint);

    // Draw Ticks
    final tickPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
      
    for (int i = 0; i < 60; i+=2) {
      final tickAngle = (2 * math.pi * i) / 60;
      final innerR = radius - 12;
      final outerR = radius + 12;
      final p1 = Offset(center.dx + innerR * math.cos(tickAngle), center.dy + innerR * math.sin(tickAngle));
      final p2 = Offset(center.dx + outerR * math.cos(tickAngle), center.dy + outerR * math.sin(tickAngle));
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Draw Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (isIrregular) {
       progressPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    }

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      tileMode: TileMode.repeated,
      colors: [
        color.withOpacity(0.1),
        color,
      ],
    );
    progressPaint.shader = gradient.createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
    
    // Draw Indicator Dot
    final angle = -math.pi / 2 + (2 * math.pi * progress);
    final dotX = center.dx + radius * math.cos(angle);
    final dotY = center.dy + radius * math.sin(angle);
    
    final dotPaint = Paint()..color = Colors.white;
    final dotBorder = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4; // Thicker border
    final dotShadow = Paint()..color = color.withOpacity(0.5);
    
    canvas.drawCircle(Offset(dotX, dotY), 16, dotShadow);
    canvas.drawCircle(Offset(dotX, dotY), 12, dotPaint);
    canvas.drawCircle(Offset(dotX, dotY), 12, dotBorder);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.isIrregular != isIrregular;
  }
}
