import 'package:flutter/material.dart';

class UtilWidgets {
  //Used in auth screens as that has different styles and roundness
  static Widget getOutlinedButton(
    VoidCallback? onPressed,
    String text,
    BuildContext context, {
    Color? foregroundColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: OutlinedButton(
        onPressed: onPressed,
        style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
          side:
              borderColor != null
                  ? WidgetStatePropertyAll(
                    BorderSide(color: borderColor), // remove border if null
                  )
                  : null,
          foregroundColor:
              foregroundColor != null
                  ? WidgetStatePropertyAll(foregroundColor)
                  : null,
          backgroundColor:
              backgroundColor != null
                  ? WidgetStatePropertyAll(backgroundColor)
                  : null,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}
