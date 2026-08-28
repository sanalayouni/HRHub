import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// Rounded search box with the leading icon chip, as on the web filter bars.
class SearchField extends StatelessWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.creamSoft),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: palette.slateSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.search_rounded, size: 18, color: palette.slate),
          ),
          Expanded(
            child: TextFormField(
              initialValue: value,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: palette.ink),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: palette.inkSoft.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill dropdown used for the category / status / department filters.
class FilterDropdown<T> extends StatelessWidget {
  final T value;
  final String placeholder;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.placeholder,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.creamSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: palette.surface,
          icon: Icon(Icons.expand_more_rounded, size: 18, color: palette.inkSoft),
          style: TextStyle(fontSize: 13, color: palette.inkSoft),
          items: options.entries
              .map((e) => DropdownMenuItem<T>(
                    value: e.key,
                    child: Text(
                      e.value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: palette.inkSoft),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Full-width accent button — the web's primary action style.
class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.inkFixed,
          disabledBackgroundColor: palette.accent.withValues(alpha: 0.5),
          disabledForegroundColor: palette.inkFixed.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: busy
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: palette.inkFixed),
              )
            : Text(label),
      ),
    );
  }
}

/// Circular monogram avatar used for employees and the account button.
class Monogram extends StatelessWidget {
  final String text;
  final double size;
  final Color? background;
  final Color? foreground;

  const Monogram({
    super.key,
    required this.text,
    this.size = 36,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? palette.slateSoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: foreground ?? palette.slate,
        ),
      ),
    );
  }
}
