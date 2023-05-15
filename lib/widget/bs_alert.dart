import 'package:flutter/material.dart';

enum BsAlertType {
  danger,
  primary,
  info,
  warning,
}

class BsAlert extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final BsAlertType type;

  const BsAlert({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.type = BsAlertType.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case BsAlertType.danger:
        color = Colors.red;
        break;
      case BsAlertType.info:
        color = Colors.blue;
        break;
      case BsAlertType.warning:
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
