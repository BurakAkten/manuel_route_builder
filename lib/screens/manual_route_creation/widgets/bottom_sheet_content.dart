import 'package:flutter/material.dart';
import 'package:manuel_route_builder/configs/manuel_route_builder_config.dart';
import '../../../enums/selection_mode.dart';

class BottomSheetContent extends StatelessWidget {
  final int step;
  final SelectionMode selectionMode;
  final bool hasCircle;
  final bool hasStartPoint;
  final bool isDrawingMode;
  final int pointCount;
  final double radius;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onNextStep;
  final VoidCallback onUseCurrentLoc;
  final VoidCallback onSelectOnMap;
  final VoidCallback onBuildRoute;
  final VoidCallback onSelectCircleMode;
  final VoidCallback onSelectFreeDrawMode;
  final VoidCallback onResetMode;
  final VoidCallback onResetFreeDraw;
  final Color primaryColor;
  final Color successColor;

  const BottomSheetContent({
    super.key,
    required this.step,
    required this.selectionMode,
    required this.hasCircle,
    required this.hasStartPoint,
    required this.isDrawingMode,
    required this.pointCount,
    required this.radius,
    required this.onRadiusChanged,
    required this.onNextStep,
    required this.onUseCurrentLoc,
    required this.onSelectOnMap,
    required this.onBuildRoute,
    required this.onSelectCircleMode,
    required this.onSelectFreeDrawMode,
    required this.onResetMode,
    required this.onResetFreeDraw,
    this.primaryColor = const Color(0xFF534AB7),
    this.successColor = const Color(0xFF1D9E75),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Color(0xFFE0DDD6), width: 0.5))),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Handle(),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    return KeyedSubtree(
      key: ValueKey('$step-$selectionMode'),
      child: step == 0 ? _Step0Container(this) : _Step1Container(this),
    );
  }
}

// ── Step 0 Views ──────────────────────────────────────────────────────

class _Step0Container extends StatelessWidget {
  final BottomSheetContent parent;
  const _Step0Container(this.parent);

  @override
  Widget build(BuildContext context) {
    switch (parent.selectionMode) {
      case SelectionMode.none:
        return _ModeSelectionView(parent: parent);
      case SelectionMode.circle:
        return _CircleSelectionView(parent: parent);
      case SelectionMode.freeDraw:
        return _FreeDrawSelectionView(parent: parent);
    }
  }
}

class _ModeSelectionView extends StatelessWidget {
  final BottomSheetContent parent;
  const _ModeSelectionView({required this.parent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(ManuelRouteBuilderConfig.l10n.wayOfAreaSelection),
        const SizedBox(height: 4),
        _StatusText(ManuelRouteBuilderConfig.l10n.selectAreaOnMap,
            active: false),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModeCard(
                icon: Icons.radio_button_checked,
                label: ManuelRouteBuilderConfig.l10n.circleSelectionMode,
                description:
                    ManuelRouteBuilderConfig.l10n.drawCircleByClickingOnMap,
                color: parent.primaryColor,
                onTap: parent.onSelectCircleMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeCard(
                icon: Icons.gesture,
                label: ManuelRouteBuilderConfig.l10n.freeDrawSelectionMode,
                description: ManuelRouteBuilderConfig.l10n.freeDrawOnMap,
                color: parent.primaryColor,
                onTap: parent.onSelectFreeDrawMode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleSelectionView extends StatelessWidget {
  final BottomSheetContent parent;
  const _CircleSelectionView({required this.parent});

  @override
  Widget build(BuildContext context) {
    final canProceed = parent.pointCount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderWithBack(
            title: ManuelRouteBuilderConfig.l10n.circleSelectionMode,
            onBack: parent.onResetMode,
            color: parent.primaryColor),
        const SizedBox(height: 4),
        _StatusText(
          parent.hasCircle
              ? ManuelRouteBuilderConfig.l10n
                  .pointsCountInArea(parent.pointCount)
              : ManuelRouteBuilderConfig.l10n.drawCircleByClickingOnMap,
          active: parent.hasCircle,
          activeColor: parent.successColor,
        ),
        const SizedBox(height: 12),
        _RadiusSlider(
          radius: parent.radius,
          onChanged: parent.onRadiusChanged,
          color: parent.primaryColor,
        ),
        const SizedBox(height: 8),
        _PrimaryButton(
          label: canProceed
              ? ManuelRouteBuilderConfig.l10n
                  .pointsCountInArea(parent.pointCount)
              : (parent.hasCircle
                  ? ManuelRouteBuilderConfig.l10n.noPointsInArea
                  : ManuelRouteBuilderConfig.l10n.continueButton),
          onPressed: canProceed ? parent.onNextStep : null,
          color: parent.primaryColor,
        ),
      ],
    );
  }
}

class _FreeDrawSelectionView extends StatelessWidget {
  final BottomSheetContent parent;
  const _FreeDrawSelectionView({required this.parent});

  @override
  Widget build(BuildContext context) {
    final canProceed = parent.pointCount > 0;
    final isDrawing = parent.isDrawingMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderWithBack(
            title: ManuelRouteBuilderConfig.l10n.freeDrawSelectionMode,
            onBack: parent.onResetMode,
            color: parent.primaryColor),
        const SizedBox(height: 4),
        _StatusText(
          isDrawing
              ? ManuelRouteBuilderConfig.l10n.freeDrawOnMap
              : canProceed
                  ? ManuelRouteBuilderConfig.l10n
                      .pointsCountInArea(parent.pointCount)
                  : ManuelRouteBuilderConfig.l10n.areaNotDrawnYet,
          active: canProceed && !isDrawing,
          activeColor: parent.successColor,
        ),
        const SizedBox(height: 16),
        if (!isDrawing && !canProceed)
          _PrimaryButton(
              label: ManuelRouteBuilderConfig.l10n.startDrawing,
              onPressed: parent.onSelectFreeDrawMode,
              color: parent.primaryColor),
        if (isDrawing) _DrawingInfoBox(color: parent.primaryColor),
        if (canProceed && !isDrawing) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _PrimaryButton(
                      label: ManuelRouteBuilderConfig.l10n.reset,
                      onPressed: parent.onResetFreeDraw,
                      color: parent.primaryColor.withOpacity(0.4))),
              const SizedBox(width: 4),
              Expanded(
                  child: _PrimaryButton(
                      label: ManuelRouteBuilderConfig.l10n.continueButton,
                      onPressed: parent.onNextStep,
                      color: parent.primaryColor)),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Step 1 Views ──────────────────────────────────────────────────────

class _Step1Container extends StatelessWidget {
  final BottomSheetContent parent;
  const _Step1Container(this.parent);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(ManuelRouteBuilderConfig.l10n.startPointTitle),
        const SizedBox(height: 4),
        _StatusText(
          parent.hasStartPoint
              ? ManuelRouteBuilderConfig.l10n.startPointSelected
              : ManuelRouteBuilderConfig.l10n.selectOptionOrTapMap,
          active: parent.hasStartPoint,
          activeColor: parent.successColor,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OutlineButton(
                label: ManuelRouteBuilderConfig.l10n.myLocation,
                icon: Icons.my_location,
                onPressed: parent.onUseCurrentLoc,
                foregroundColor: const Color(0xFF085041),
                borderColor: parent.successColor,
                backgroundColor: const Color(0xFFE1F5EE),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineButton(
                label: ManuelRouteBuilderConfig.l10n.selectFromMap,
                icon: Icons.touch_app,
                onPressed: parent.onSelectOnMap,
                foregroundColor: const Color(0xFF3C3489),
                borderColor: parent.primaryColor,
                backgroundColor: const Color(0xFFEEEDFE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PrimaryButton(
          label: ManuelRouteBuilderConfig.l10n.buildRoute,
          onPressed: parent.hasStartPoint ? parent.onBuildRoute : null,
          color: parent.successColor,
        ),
      ],
    );
  }
}

// ── Reusable UI Components ──────────────────────────────────────────

class _HeaderWithBack extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Color color;

  const _HeaderWithBack(
      {required this.title, required this.onBack, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Icon(Icons.arrow_back_ios, size: 16, color: color),
        ),
        const SizedBox(width: 4),
        _SectionTitle(title),
      ],
    );
  }
}

class _RadiusSlider extends StatelessWidget {
  final double radius;
  final ValueChanged<double> onChanged;
  final Color color;
  final double _maxRadius = 5000, _minRadius = 50; //can be parametric

  const _RadiusSlider(
      {required this.radius, required this.onChanged, required this.color});

  String _formatRadius(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(ManuelRouteBuilderConfig.l10n.radius,
                style: TextStyle(fontSize: 13)),
            Text(
              "${_formatRadius(radius)} / ${_formatRadius(_maxRadius)}",
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
        Slider(
          value: radius,
          label: _formatRadius(radius),
          min: _minRadius,
          max: _maxRadius,
          divisions: (_maxRadius / _minRadius).toInt(),
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DrawingInfoBox extends StatelessWidget {
  final Color color;
  const _DrawingInfoBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ManuelRouteBuilderConfig.l10n.dragOnMapToDraw,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFD3D1C7),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}

class _StatusText extends StatelessWidget {
  final String text;
  final bool active;
  final Color activeColor;

  const _StatusText(this.text,
      {required this.active, this.activeColor = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: active ? activeColor : const Color(0xFF888780),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  const _PrimaryButton(
      {required this.label, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: const Color(0xFFD3D1C7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color foregroundColor;
  final Color borderColor;
  final Color backgroundColor;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.foregroundColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side: BorderSide(color: borderColor),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
