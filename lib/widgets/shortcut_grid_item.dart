import 'package:flutter/material.dart';
import '../models/shortcut_item.dart';

class ShortcutGridItem extends StatelessWidget {
  final ShortcutItem item;

  const ShortcutGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
    final countStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
    );
    if (item.title == 'Ủng hộ') {
      return _ScintillatingShortcutItem(item: item);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              const SizedBox(height: 2),
              if (item.subtitle != null && item.subtitle!.isNotEmpty)
                Text(
                  item.subtitle!,
                  textAlign: TextAlign.center,
                  style: countStyle,
                )
              else
                Text(
                  item.count != null ? '${item.count} câu' : ' ',
                  style: countStyle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScintillatingShortcutItem extends StatefulWidget {
  final ShortcutItem item;
  const _ScintillatingShortcutItem({required this.item});

  @override
  State<_ScintillatingShortcutItem> createState() => _ScintillatingShortcutItemState();
}

class _ScintillatingShortcutItemState extends State<_ScintillatingShortcutItem> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flipController;
  late Animation<double> _scaleAnim;
  late Animation<Color?> _colorAnim;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _colorAnim = ColorTween(begin: widget.item.color, end: Colors.pinkAccent).animate(_pulseController);

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _startPeriodicFlip();
  }

  void _startPeriodicFlip() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _flipController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );
    final countStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_pulseController, _flipController]),
                  builder: (context, child) {
                    final angle = _flipAnim.value * 3.1415926535 * 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: Transform.scale(
                        scale: 1.05 * _scaleAnim.value,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_colorAnim.value ?? widget.item.color).withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.item.icon,
                              color: _colorAnim.value ?? widget.item.color,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                const SizedBox(height: 2),
                if (widget.item.subtitle != null && widget.item.subtitle!.isNotEmpty)
                  Text(
                    widget.item.subtitle!,
                    textAlign: TextAlign.center,
                    style: countStyle,
                  )
                else
                  Text(
                    widget.item.count != null ? '${widget.item.count} câu' : ' ',
                    style: countStyle,
                  ),
              ],
            ),
          ),
        ),
    );
  }
}
