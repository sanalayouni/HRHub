import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/labels.dart';
import 'form_controls.dart';

/// Mobile counterpart to the web `TopNav`: the logo pill on the left and the
/// settings / account controls on the right. Section links live in the bottom
/// nav instead.
class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final me = ref.watch(meProvider).valueOrNull;
    final displayName = me?.displayName ?? 'HR Manager';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              decoration: BoxDecoration(
                color: palette.shell,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/hrhub-logo.png', height: 30, width: 30),
                  ),
                  const SizedBox(width: 8),
                  Text('HRHub', style: heading(size: 17, color: palette.ink)),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: palette.shell,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleButton(
                    icon: Icons.settings_outlined,
                    tooltip: 'Settings',
                    onTap: () => _showSettings(context, ref),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAccount(context, ref, displayName, me?.email),
                    child: Monogram(
                      text: initials(displayName),
                      size: 34,
                      background: palette.accent,
                      foreground: palette.inkFixed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final palette = sheetContext.palette;
        return Consumer(
          builder: (consumerContext, sheetRef, _) {
            final mode = sheetRef.watch(themeModeProvider);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(sheetContext).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: heading(size: 17, color: palette.ink)),
                  const SizedBox(height: 16),
                  Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: palette.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: palette.cream,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        _ThemeOption(
                          icon: Icons.light_mode_outlined,
                          label: 'Light',
                          selected: mode == ThemeMode.light,
                          onTap: () =>
                              sheetRef.read(themeModeProvider.notifier).set(ThemeMode.light),
                        ),
                        _ThemeOption(
                          icon: Icons.dark_mode_outlined,
                          label: 'Dark',
                          selected: mode == ThemeMode.dark,
                          onTap: () =>
                              sheetRef.read(themeModeProvider.notifier).set(ThemeMode.dark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAccount(BuildContext context, WidgetRef ref, String name, String? email) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final palette = sheetContext.palette;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheetContext).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Monogram(
                    text: initials(name),
                    size: 44,
                    background: palette.accent,
                    foreground: palette.inkFixed,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}',
                        style: heading(size: 15, color: palette.ink),
                      ),
                      Text(
                        'Axia Solutions',
                        style: TextStyle(fontSize: 12, color: palette.inkSoft),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.cream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: TextStyle(fontSize: 11, color: palette.inkSoft)),
                    const SizedBox(height: 2),
                    Text(
                      email ?? '—',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Log out'),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.ink,
                    foregroundColor: palette.cream,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: palette.surface, shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: palette.inkSoft),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? palette.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? palette.cream : palette.inkSoft),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? palette.cream : palette.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
