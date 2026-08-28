import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/requests_provider.dart';
import '../../../theme/app_theme.dart';

class DecisionActionBar extends ConsumerStatefulWidget {
  final String requestId;
  final String? existingNotes;

  const DecisionActionBar({super.key, required this.requestId, this.existingNotes});

  @override
  ConsumerState<DecisionActionBar> createState() => _DecisionActionBarState();
}

class _DecisionActionBarState extends ConsumerState<DecisionActionBar> {
  late final TextEditingController _notesController;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.existingNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _decide(String status) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final notes = _notesController.text.trim();
      await ref.read(decisionActionsProvider).decide(
            widget.requestId,
            status,
            notes.isEmpty ? null : notes,
          );
    } catch (e) {
      setState(() => _error = "Couldn't save your decision. Try again.");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR DECISION',
            style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(color: AppColors.cream, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Add an optional note...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Approve',
                  icon: Icons.check,
                  color: AppColors.sage,
                  onTap: _submitting ? null : () => _decide('approved'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Reject',
                  icon: Icons.close,
                  color: AppColors.coral,
                  onTap: _submitting ? null : () => _decide('rejected'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Info',
                  icon: Icons.help_outline,
                  color: AppColors.dustyBlue,
                  onTap: _submitting ? null : () => _decide('needs_review'),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!, style: const TextStyle(color: AppColors.coral, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: AppColors.ink),
      label: Text(label, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 0,
      ),
    );
  }
}
