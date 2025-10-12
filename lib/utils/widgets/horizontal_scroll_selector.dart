import 'dart:math' as math;
import 'package:flutter/material.dart';

class HorizontalScrollSelector extends StatefulWidget {
  final List<Widget> items;
  final int initialIndex;
  final double itemWidth;
  final double spacing;
  final ValueChanged<int>? onSelectedChanged;

  const HorizontalScrollSelector({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.itemWidth = 80,
    this.spacing = 12,
    this.onSelectedChanged,
  });

  @override
  State<HorizontalScrollSelector> createState() =>
      _HorizontalScrollSelectorState();
}

class _HorizontalScrollSelectorState extends State<HorizontalScrollSelector> {
  late final ScrollController _controller;
  late int _selectedIndex;
  bool _isAnimating = false;

  double get _totalItemWidth => widget.itemWidth + widget.spacing;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _controller = ScrollController();

    // Wait for the list to be laid out, then position to the initial index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(_selectedIndex, animate: false);
    });
  }

  void _scrollToIndex(int index, {bool animate = true}) {
    index = index.clamp(0, widget.items.length - 1);
    final target = index * _totalItemWidth;

    // If controller not attached yet, try again next frame.
    if (!_controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_controller.hasClients) return;
        _scrollToIndex(index, animate: animate);
      });
      return;
    }

    final max = _controller.position.maxScrollExtent;
    final finalTarget = target.clamp(0.0, max);

    if (animate) {
      _isAnimating = true;
      _controller
          .animateTo(
            finalTarget,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .whenComplete(() => _isAnimating = false);
    } else {
      _controller.jumpTo(finalTarget);
    }

    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
      widget.onSelectedChanged?.call(index);
    }
  }

  void _onScrollEnd() {
    if (_isAnimating || !_controller.hasClients) return;

    // Correct index detection: use offset divided by the step (item+spacing)
    final rawIndex = _controller.offset / _totalItemWidth;
    int index = rawIndex.round().clamp(0, widget.items.length - 1);

    _scrollToIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = math.max(
      0,
      viewportWidth / 2 - widget.itemWidth / 2,
    );

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        _onScrollEnd();
        return true;
      },
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding.toDouble()),
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.1 : 0.95,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.7,
              child: SizedBox(
                width: widget.itemWidth,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _scrollToIndex(index),
                    child: widget.items[index],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
