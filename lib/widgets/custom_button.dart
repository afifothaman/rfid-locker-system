import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStyle;
  final Widget? child;
  final bool showShadow;
  final double? elevation;
  final Gradient? gradient;
  final bool isCircle;
  final double? iconSize;
  final Color? iconColor;
  final double? iconSpacing;
  final bool enableFeedback;
  final WidgetStateProperty<Color?>? overlayColor;
  final bool autofocus;
  final FocusNode? focusNode;
  final Clip clipBehavior;
  final bool enableInkWell;
  final double? splashRadius;
  final BorderRadius? customBorderRadius;
  final bool dense;
  final VisualDensity? visualDensity;
  final MaterialTapTargetSize? materialTapTargetSize;
  final MouseCursor? mouseCursor;
  final FocusNode? buttonFocusNode;
  final bool? buttonAutofocus;
  final Clip? buttonClipBehavior;
  final ButtonStyle? buttonStyle;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.textStyle,
    this.child,
    this.showShadow = false,
    this.elevation,
    this.gradient,
    this.isCircle = false,
    this.iconSize = 24.0,
    this.iconColor,
    this.iconSpacing = 8.0,
    this.enableFeedback = true,
    this.overlayColor,
    this.autofocus = false,
    this.focusNode,
    this.clipBehavior = Clip.none,
    this.enableInkWell = true,
    this.splashRadius,
    this.customBorderRadius,
    this.dense = false,
    this.visualDensity,
    this.materialTapTargetSize,
    this.mouseCursor,
    this.buttonFocusNode,
    this.buttonAutofocus,
    this.buttonClipBehavior,
    this.buttonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBackgroundColor = isOutlined
        ? Colors.transparent
        : (backgroundColor ?? theme.colorScheme.primary);
    final defaultTextColor = isOutlined
        ? (textColor ?? theme.colorScheme.primary)
        : (textColor ?? theme.colorScheme.onPrimary);
    final defaultBorderColor = borderColor ?? theme.colorScheme.primary;
    final defaultBorderRadius = isCircle
        ? BorderRadius.circular(100.0)
        : (customBorderRadius ?? BorderRadius.circular(borderRadius!));

    final buttonChild = isLoading
        ? SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? defaultTextColor : theme.colorScheme.onPrimary,
              ),
              strokeWidth: 2.0,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? defaultTextColor,
                ),
                SizedBox(width: iconSpacing),
              ],
              Flexible(
                child: Text(
                  text,
                  style: textStyle?.copyWith(color: defaultTextColor) ??
                      theme.textTheme.labelLarge?.copyWith(
                        color: defaultTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final buttonContent = Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isOutlined ? null : defaultBackgroundColor,
        gradient: isOutlined ? null : gradient,
        borderRadius: defaultBorderRadius,
        border: isOutlined
            ? Border.all(
                color: defaultBorderColor,
                width: borderWidth!,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isDisabled || isLoading) ? null : onPressed,
          borderRadius: defaultBorderRadius,
          splashColor: isOutlined ? defaultBorderColor.withOpacity(0.1) : null,
          highlightColor: isOutlined ? defaultBorderColor.withOpacity(0.2) : null,
          child: Center(
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
              child: buttonChild,
            ),
          ),
        ),
      ),
    );

    return buttonContent;
  }

  // Factory constructor for primary button
  factory CustomButton.primary({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    IconData? icon,
    double? width,
    double? height,
    double? borderRadius,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    TextStyle? textStyle,
    bool showShadow = false,
    double? iconSize,
    Color? iconColor,
    double? iconSpacing,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
      isOutlined: false,
      icon: icon,
      width: width,
      height: height,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      textColor: textColor,
      padding: padding,
      margin: margin,
      textStyle: textStyle,
      showShadow: showShadow,
      iconSize: iconSize,
      iconColor: iconColor,
      iconSpacing: iconSpacing,
    );
  }

  // Factory constructor for outlined button
  factory CustomButton.outlined({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    IconData? icon,
    double? width,
    double? height,
    double? borderRadius,
    Color? borderColor,
    Color? textColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    TextStyle? textStyle,
    double? iconSize,
    Color? iconColor,
    double? iconSpacing,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
      isOutlined: true,
      icon: icon,
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderColor: borderColor,
      textColor: textColor,
      borderWidth: borderWidth,
      padding: padding,
      margin: margin,
      textStyle: textStyle,
      iconSize: iconSize,
      iconColor: iconColor,
      iconSpacing: iconSpacing,
    );
  }

  // Factory constructor for text button
  factory CustomButton.text({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    IconData? icon,
    double? width,
    double? height,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    TextStyle? textStyle,
    double? iconSize,
    Color? iconColor,
    double? iconSpacing,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: isFullWidth,
      isOutlined: false,
      icon: icon,
      width: width,
      height: height,
      backgroundColor: Colors.transparent,
      textColor: textColor,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: margin,
      textStyle: textStyle,
      iconSize: iconSize,
      iconColor: iconColor,
      iconSpacing: iconSpacing,
    );
  }

  // Factory constructor for icon button
  factory CustomButton.icon({
    Key? key,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? size,
    Color? backgroundColor,
    Color? iconColor,
    double? iconSize,
    bool isCircle = true,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return CustomButton(
      key: key,
      text: '',
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isFullWidth: false,
      isOutlined: false,
      icon: icon,
      width: size,
      height: size,
      backgroundColor: backgroundColor,
      textColor: iconColor,
      padding: padding ?? const EdgeInsets.all(8.0),
      margin: margin,
      isCircle: isCircle,
      elevation: elevation,
      iconSize: iconSize,
    );
  }
}
