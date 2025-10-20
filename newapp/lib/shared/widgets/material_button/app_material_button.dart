import 'package:flutter/material.dart';

import '../progress_loader/progress_loader.dart';

class AppMaterialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final double width;
  final double elevation;
  final double borderRadius;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;
  final Widget? child;

  const AppMaterialButton({
    super.key,
    this.label = 'Material Button',
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 48,
    this.width = double.infinity,
    this.elevation = 0,
    this.borderRadius = 8,
    this.shape,
    this.backgroundColor,
    this.disabledColor,
    this.textColor = Colors.white,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectOnChild = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: showLoader()
          )
        : Text(label, style: TextStyle(color: textColor));

    final effectiveOnPressed = (isDisabled || isLoading)
        ? null
        : (onPressed ?? () => Navigator.pop(context));

    return MaterialButton(
      onPressed: effectiveOnPressed,
      elevation: elevation,
      color: backgroundColor ?? Theme.of(context).primaryColor,
      disabledColor: disabledColor ?? Theme.of(context).disabledColor,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius)
      ),
      height: height,
      minWidth: width,
      child: child ?? effectOnChild,
    );
  }
}
