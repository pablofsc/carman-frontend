import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

class ExpandableFabOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ExpandableFabOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class ExpandableFab extends riverpod.ConsumerStatefulWidget {
  final List<ExpandableFabOption> options;

  const ExpandableFab({super.key, required this.options});

  @override
  riverpod.ConsumerState<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends riverpod.ConsumerState<ExpandableFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.options.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _FabOptionRow(
                      option: widget.options[i],
                      onTap: () {
                        _toggle();
                        widget.options[i].onTap();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabOptionRow extends StatelessWidget {
  final ExpandableFabOption option;
  final VoidCallback onTap;

  const _FabOptionRow({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              option.label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          heroTag: option.label,
          onPressed: onTap,
          child: Icon(option.icon),
        ),
      ],
    );
  }
}
