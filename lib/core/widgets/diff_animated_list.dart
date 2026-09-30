import 'package:flutter/material.dart';

/// Builds an item with the animation driving its appearance/disappearance.
typedef AnimatedItemBuilder<T> =
    Widget Function(BuildContext context, T item, Animation<double> animation);

/// A list that animates items in and out whenever [items] changes, matching
/// them by [keyOf]. Removed items keep their last look while they collapse.
class DiffAnimatedList<T> extends StatefulWidget {
  const DiffAnimatedList({
    super.key,
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    this.padding,
    this.insertDuration = const Duration(milliseconds: 320),
    this.removeDuration = const Duration(milliseconds: 380),
  });

  final List<T> items;
  final Object Function(T item) keyOf;
  final AnimatedItemBuilder<T> itemBuilder;
  final EdgeInsetsGeometry? padding;
  final Duration insertDuration;
  final Duration removeDuration;

  @override
  State<DiffAnimatedList<T>> createState() => _DiffAnimatedListState<T>();
}

class _DiffAnimatedListState<T> extends State<DiffAnimatedList<T>> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<T> _items = List.of(widget.items);

  @override
  void didUpdateWidget(covariant DiffAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final list = _listKey.currentState;
    if (list == null) {
      _items = List.of(widget.items);
      return;
    }
    final newKeys = {for (final item in widget.items) widget.keyOf(item)};

    // Remove from the end so indices stay valid.
    for (var i = _items.length - 1; i >= 0; i--) {
      if (!newKeys.contains(widget.keyOf(_items[i]))) {
        final removed = _items.removeAt(i);
        list.removeItem(
          i,
          (context, animation) => widget.itemBuilder(context, removed, animation),
          duration: widget.removeDuration,
        );
      }
    }

    // Insert new items at their target positions.
    final oldKeys = {for (final item in _items) widget.keyOf(item)};
    for (var j = 0; j < widget.items.length; j++) {
      final item = widget.items[j];
      if (!oldKeys.contains(widget.keyOf(item))) {
        final index = j.clamp(0, _items.length);
        _items.insert(index, item);
        list.insertItem(index, duration: widget.insertDuration);
      }
    }

    // Same set of items now: take the fresh data (and order).
    _items = List.of(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      padding: widget.padding,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        if (index >= _items.length) return const SizedBox.shrink();
        return widget.itemBuilder(context, _items[index], animation);
      },
    );
  }
}

/// Standard enter/exit transition for list items: fade + collapse + slide.
class ListItemTransition extends StatelessWidget {
  const ListItemTransition({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    // Like SizeTransition, but clips only while the size animates: at rest the
    // card's shadow can spill outside its slot.
    final content = FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, content) => ClipRect(
        clipBehavior: curved.value >= 1 ? Clip.none : Clip.hardEdge,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          heightFactor: curved.value.clamp(0.0, 1.0),
          child: content,
        ),
      ),
      child: content,
    );
  }
}
