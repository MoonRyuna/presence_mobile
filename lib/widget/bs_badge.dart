import 'package:flutter/material.dart';

class BsBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double borderRadius;
  final TextStyle textStyle;
  final EdgeInsets padding;

  const BsBadge({
    super.key,
    required this.text,
    this.backgroundColor = Colors.red,
    this.borderRadius = 4.0,
    this.textStyle = const TextStyle(color: Colors.white),
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
