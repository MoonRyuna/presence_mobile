import 'package:ai_awesome_message/ai_awesome_message.dart';
import 'package:flutter/material.dart';

class AmessageUtility {
  static void show(BuildContext ctx, String title, String message, TipType type,
      [int? duration = 7]) {
    IconData tipIcon;
    Color tipStyleColor;
    Color tipStyleIconColor;
    Color tipStyleBorderColor;

    if (type == TipType.INFO) {
      title = title ?? "Info";
      tipIcon = Icons.info_outline;
      tipStyleColor = Colors.blue[100]!;
      tipStyleIconColor = Colors.blue[500]!;
      tipStyleBorderColor = Colors.blue[300]!;
    } else if (type == TipType.WARN) {
      title = title ?? "Warning";
      tipIcon = Icons.error_outline;
      tipStyleColor = Colors.orange[100]!;
      tipStyleIconColor = Colors.orange[500]!;
      tipStyleBorderColor = Colors.orange[300]!;
    } else if (type == TipType.ERROR) {
      title = title ?? "Error";
      tipIcon = Icons.cancel;
      tipStyleColor = Colors.red[100]!;
      tipStyleIconColor = Colors.red[500]!;
      tipStyleBorderColor = Colors.red[300]!;
    } else if (type == TipType.COMPLETE) {
      title = title ?? "Success";
      tipIcon = Icons.done_outline;
      tipStyleColor = Colors.green[100]!;
      tipStyleIconColor = Colors.green[500]!;
      tipStyleBorderColor = Colors.green[300]!;
    } else {
      title = title ?? "Info";
      tipIcon = Icons.info_outline;
      tipStyleColor = Colors.blue[100]!;
      tipStyleIconColor = Colors.blue[500]!;
      tipStyleBorderColor = Colors.blue[300]!;
    }

    Navigator.push(
      ctx,
      AwesomeMessageRoute(
        awesomeMessage: AwesomeMessage(
          titleText: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
          messageText: Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          icon: Icon(
            tipIcon,
            size: 28.0,
            color: tipStyleIconColor,
          ),
          duration: Duration(
            seconds: duration as int,
          ),
          awesomeMessagePosition: AwesomeMessagePosition.TOP,
          shouldIconPulse: true,
          showProgressIndicator: false,
          awesomeMessageStyle: AwesomeMessageStyle.GROUNDED,
          backgroundColor: tipStyleColor,
          borderColor: tipStyleBorderColor,
        ),
      ),
    );
  }
}
