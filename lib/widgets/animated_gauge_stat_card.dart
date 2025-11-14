import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AnimatedGaugeStatCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final int value;
  final int maxValue;
  final Color color;
  final Color? backgroundColor;
  final Color? borderColor;

  const AnimatedGaugeStatCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.maxValue,
    required this.color,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<AnimatedGaugeStatCard> createState() => _AnimatedGaugeStatCardState();
}

class _AnimatedGaugeStatCardState extends State<AnimatedGaugeStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double percent;

  @override
  void initState() {
    super.initState();
    percent = widget.maxValue == 0 ? 0 : widget.value / widget.maxValue;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: percent).animate(_controller)
      ..addListener(() => setState(() {}));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.backgroundColor ?? Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.borderColor ?? Colors.indigo, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 30),
            const SizedBox(height: 8),
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 6.0,
              animation: true,
              percent: _animation.value.clamp(0.0, 1.0),
              center: Text(
                "${widget.value}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              progressColor: widget.color,
              backgroundColor: Colors.grey.shade300.withOpacity(0.3),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
