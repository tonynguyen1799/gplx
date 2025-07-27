import 'package:flutter/material.dart';
import '../models/shortcut_item.dart';
import '../utils/app_colors.dart';

class ShortcutGridItem extends StatelessWidget {
  final ShortcutItem item;

  const ShortcutGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (item.title == 'Ủng hộ') {
      return _ScintillatingShortcutItem(item: item);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.shortcutsText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.count != null ? '${item.count} câu' : ' ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.shortcutsCountText,
                ),
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_pulseController, _flipController]),
                builder: (context, child) {
                  final angle = _flipAnim.value * 3.1415926535 * 2; // 0 to 2pi (360deg)
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _colorAnim.value?.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: _colorAnim.value,
                          size: 26,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.shortcutsText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.item.count != null ? '${widget.item.count} câu' : ' ',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.shortcutsCountText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
