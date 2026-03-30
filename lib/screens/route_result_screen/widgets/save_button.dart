import 'package:flutter/material.dart';
import 'package:manuel_route_builder/configs/manuel_route_builder_config.dart';

class SaveButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onPressed;

  const SaveButton({required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0DDD6), width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            ManuelRouteBuilderConfig.l10n.save,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
