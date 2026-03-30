import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color doneColor;
  final Color inactiveColor;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 2,
    this.activeColor = Colors.white,
    this.doneColor = const Color(0xFF1D9E75),
    this.inactiveColor = const Color(0x80FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, _buildDot),
      ),
    );
  }

  Widget _buildDot(int i) {
    final isDone = i < currentStep;
    final isActive = i == currentStep;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isDone
            ? doneColor
            : isActive
                ? activeColor
                : inactiveColor,
      ),
    );
  }
}
