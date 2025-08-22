import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool expands;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final String? errorText;
  final String? helperText;
  final String? counterText;
  final Color? fillColor;
  final bool filled;
  final AutovalidateMode? autovalidateMode;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final double? cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool enableInteractiveSelection;
  final void Function()? onTap;
  final Widget? suffix;
  final Widget? prefix;
  final String? prefixText;
  final String? suffixText;
  final TextStyle? prefixStyle;
  final TextStyle? suffixStyle;
  final bool isDense;
  final bool isCollapsed;
  final Widget? icon;
  final Color? iconColor;
  final BoxConstraints? constraints;
  final bool? alignLabelWithHint;
  final String? semanticCounterText;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final bool canRequestFocus;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final String obscuringCharacter;
  final Clip clipBehavior;
  
  // Custom styling properties
  final double? height;
  final double? width;
  final double borderRadius;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderWidth;
  final double focusedBorderWidth;
  final double errorBorderWidth;
  final EdgeInsetsGeometry? margin;
  final bool showBorder;
  final bool showShadow;
  final Color? shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final FloatingLabelBehavior? floatingLabelBehavior;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.autofocus = false,
    this.expands = false,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.errorText,
    this.helperText,
    this.counterText,
    this.fillColor,
    this.filled = false,
    this.autovalidateMode,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.suffix,
    this.prefix,
    this.prefixText,
    this.suffixText,
    this.prefixStyle,
    this.suffixStyle,
    this.isDense = false,
    this.isCollapsed = false,
    this.icon,
    this.iconColor,
    this.constraints,
    this.alignLabelWithHint = false,
    this.semanticCounterText,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.canRequestFocus = true,
    this.scrollPhysics,
    this.scrollController,
    this.obscuringCharacter = '•',
    this.clipBehavior = Clip.hardEdge,
    // Custom properties
    this.height,
    this.width,
    this.borderRadius = 8.0,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor = Colors.red,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 2.0,
    this.errorBorderWidth = 1.0,
    this.margin,
    this.showBorder = true,
    this.showShadow = false,
    this.shadowColor,
    this.shadowBlurRadius = 4.0,
    this.shadowOffset = const Offset(0, 2),
    this.floatingLabelBehavior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Define default colors
    final defaultBorderColor = isDark ? Colors.grey[700] : Colors.grey[400];
    final defaultFocusedBorderColor = theme.colorScheme.primary;
    final defaultFillColor = isDark ? Colors.grey[900] : Colors.grey[50];
    
    // Build the text field
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: showShadow ? BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? Colors.black).withValues(alpha: 0.1),
            blurRadius: shadowBlurRadius,
            offset: shadowOffset,
          ),
        ],
      ) : null,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        validator: validator,
        onChanged: onChanged,
        onSaved: onSaved,
        onFieldSubmitted: onFieldSubmitted,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        focusNode: focusNode,
        autofocus: autofocus,
        expands: expands,
        cursorWidth: cursorWidth ?? 2.0,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor ?? theme.colorScheme.primary,
        keyboardAppearance: keyboardAppearance,
        enableSuggestions: enableSuggestions,
        autocorrect: autocorrect,
        enableInteractiveSelection: enableInteractiveSelection,
        onTap: onTap,
        inputFormatters: inputFormatters,
        style: style ?? theme.textTheme.bodyMedium,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        autovalidateMode: autovalidateMode,
        scrollPhysics: scrollPhysics,
        scrollController: scrollController,
        obscuringCharacter: obscuringCharacter,
        enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
        canRequestFocus: canRequestFocus,
        restorationId: restorationId,
        clipBehavior: clipBehavior,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          prefix: prefix,
          suffix: suffix,
          prefixText: prefixText,
          suffixText: suffixText,
          prefixStyle: prefixStyle,
          suffixStyle: suffixStyle,
          isDense: isDense,
          isCollapsed: isCollapsed,
          icon: icon,
          iconColor: iconColor,
          constraints: constraints,
          alignLabelWithHint: alignLabelWithHint,
          semanticCounterText: semanticCounterText,
          errorText: errorText,
          errorStyle: errorStyle ?? TextStyle(color: errorBorderColor),
          helperText: helperText,
          helperStyle: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          counterText: counterText,
          counterStyle: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          filled: filled,
          fillColor: fillColor ?? defaultFillColor,
          floatingLabelBehavior: floatingLabelBehavior ?? FloatingLabelBehavior.auto,
          floatingLabelStyle: labelStyle?.copyWith(color: theme.colorScheme.primary) ??
              theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
          labelStyle: labelStyle ?? theme.textTheme.titleSmall,
          hintStyle: hintStyle ?? theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          border: showBorder
              ? (border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor ?? defaultBorderColor!,
                      width: borderWidth,
                    ),
                  ))
              : InputBorder.none,
          enabledBorder: showBorder
              ? (enabledBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor ?? defaultBorderColor!,
                      width: borderWidth,
                    ),
                  ))
              : InputBorder.none,
          focusedBorder: showBorder
              ? (focusedBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: focusedBorderColor ?? defaultFocusedBorderColor,
                      width: focusedBorderWidth,
                    ),
                  ))
              : InputBorder.none,
          errorBorder: errorBorder ?? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: errorBorderColor!,
              width: errorBorderWidth,
            ),
          ),
          focusedErrorBorder: focusedErrorBorder ?? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: errorBorderColor!,
              width: focusedBorderWidth,
            ),
          ),
        ),
      ),
    );
  }
}