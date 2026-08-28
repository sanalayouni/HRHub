import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const _items = [
  _NavItem(Icons.dashboard_rounded, 'Dashboard'),
  _NavItem(Icons.inbox_rounded, 'Requests'),
  _NavItem(Icons.fact_check_rounded, 'Decisions'),
  _NavItem(Icons.people_alt_rounded, 'Employees'),
];

/// Floating pill nav mirroring the web's rounded `bg-shell` nav bar, with the
/// active section filled in ink.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: palette.shell,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: palette.glassShadow,
                blurRadius: 30,
                spreadRadius: -14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: i == currentIndex ? palette.ink : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _items[i].icon,
                            size: 19,
                            color: i == currentIndex ? palette.cream : palette.inkSoft,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _items[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: i == currentIndex ? palette.cream : palette.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
