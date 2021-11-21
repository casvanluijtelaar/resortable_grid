import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:collection/collection.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// {@template reorderable_grid_view.reorderable_grid}
/// A scrolling container that allows the user to interactively reorder the
/// grid items.
///
/// This widget is similar to one created by [GridView.builder], and uses
/// an [IndexedWidgetBuilder] to create each item.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child such as a drag handle) with a drag listener that will recognize
/// the start of an item drag and then start the reorder by calling
/// [ResortableGridState.startItemDragReorder]. This is most easily achieved
/// by wrapping each child in a [ResortableGridDragStartListener] or a
/// [ResortableGridDelayedDragStartListener]. These will take care of recognizing
/// the start of a drag gesture and call the grid state's
/// [ResortableGridState.startItemDragReorder] method.
///
/// This widget's [ResortableGridState] can be used to manually start an item
/// reorder, or cancel a current drag. To refer to the
/// [ResortableGridState] either provide a [GlobalKey] or use the static
/// [ResortableGrid.of] method from an item's build method.
///
/// See also:
///
///  * [SliverResortableGrid], a sliver grid that allows the user to reorder
///    its items.
/// {@endtemplate}
class ResortableGrid<T> extends StatefulWidget {
  /// {@macro reorderable_grid_view.reorderable_grid}
  /// The [itemCount] must be greater than or equal to zero.
  const ResortableGrid({
    Key? key,
    required this.itemBuilder,
    required this.groupHeaderBuilder,
    this.footerBuilder,
    required this.itemCount,
    required this.onReorder,
    required this.gridDelegate,
    this.proxyDecorator,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(itemCount.length >= 0),
        super(key: key);

  /// Called, as needed, to build grid item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  ///
  /// The [IndexedWidgetBuilder] index parameter indicates the item's
  /// position in the grid. The value of the index parameter will be between
  /// zero and one less than [itemCount]. All items in the grid must have a
  /// unique [Key], and should have some kind of listener to start the drag
  /// (usually a [ResortableGridDragStartListener] or
  /// [ResortableGridDelayedDragStartListener]).
  final SortableWidgetBuilder itemBuilder;

  final List<int> itemCount;

  final ResortCallback onReorder;

  final ResortableItemProxyDecorator? proxyDecorator;

  final FooterWidgetBuilder? footerBuilder;
  final GroupHeaderBuilder groupHeaderBuilder;

  /// {@macro flutter.widgets.reorderable_list.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.anchor}
  final double anchor;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  final SliverGridDelegate gridDelegate;

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [ResortableGrid] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [ResortableGrid] surrounds the given context, then this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [ResortableGrid] ancestor is found.
  static ResortableGridState of(BuildContext context) {
    final ResortableGridState? result =
        context.findAncestorStateOfType<ResortableGridState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'ResortableGrid.of() called with a context that does not contain a ResortableGrid.'),
          ErrorDescription(
            'No ResortableGrid ancestor could be found starting from the context that was passed to ResortableGrid.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same StatefulWidget that '
            'built the ResortableGrid. Please see the ResortableGrid documentation for examples '
            'of how to refer to an ResortableGridState object:\n'
            '  https://api.flutter.dev/flutter/widgets/ResortableGridState-class.html',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [ResortableGrid] item widgets that insert
  /// or remove items in response to user input.
  ///
  /// If no [ResortableGrid] surrounds the context given, then this function will
  /// return null.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [ResortableGrid] ancestor
  ///    is found.
  static ResortableGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<ResortableGridState>();
  }

  @override
  ResortableGridState createState() => ResortableGridState();
}

/// The state for a grid that allows the user to interactively reorder
/// the grid items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [ResortableGrid]'s state with a global key:
///
/// ```dart
/// GlobalKey<ResortableGridState> gridKey = GlobalKey<ResortableGridState>();
/// ...
/// ResortableGrid(key: gridKey, ...);
/// ...
/// gridKey.currentState.cancelReorder();
/// ```
class ResortableGridState extends State<ResortableGrid> {
  final GlobalKey<SliverResortableGridState> _sliverResortableGridKey =
      GlobalKey();

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a cancelled drag.
  /// The grid will take ownership of the returned recognizer and will dispose
  /// it when it is no longer needed.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [ResortableGridDragStartListener] or [ResortableGridDelayedDragStartListener]
  /// which call this for the application.
  void startItemDragReorder({
    required int groupIndex,
    required int itemIndex,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    _sliverResortableGridKey.currentState!.startItemDragReorder(
      groupIndex: groupIndex,
      itemIndex: itemIndex,
      event: event,
      recognizer: recognizer,
    );
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item grid
  /// occur so that any item drags will not get confused by
  /// changes to the underlying grid.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    _sliverResortableGridKey.currentState!.cancelReorder();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverResortableGrid(
            key: _sliverResortableGridKey,
            gridDelegate: widget.gridDelegate,
            itemBuilder: widget.itemBuilder,
            groupHeaderBuilder: widget.groupHeaderBuilder,
            footerBuilder: widget.footerBuilder,
            itemCount: widget.itemCount,
            onReorder: widget.onReorder,
            proxyDecorator: widget.proxyDecorator,
          ),
        ),
      ],
    );
  }
}

typedef GroupHeaderBuilder = Widget Function(
    BuildContext context, int groupIndex);
typedef FooterWidgetBuilder = Widget Function(BuildContext context);

typedef SortableWidgetBuilder = Widget Function(
    BuildContext context, int groupIndex, int itemIndex);

typedef ResortCallback = void Function(IndexData oldItem, IndexData newItem);

class SliverResortableGrid extends StatefulWidget {
  const SliverResortableGrid({
    Key? key,
    required this.itemBuilder,
    required this.groupHeaderBuilder,
    this.footerBuilder,
    required this.itemCount,
    required this.onReorder,
    required this.gridDelegate,
    this.proxyDecorator,
  })  : assert(itemCount.length >= 0),
        super(key: key);

  final SortableWidgetBuilder itemBuilder;
  final GroupHeaderBuilder groupHeaderBuilder;
  final FooterWidgetBuilder? footerBuilder;
  final List<int> itemCount;
  final ResortCallback onReorder;
  final ResortableItemProxyDecorator? proxyDecorator;
  final SliverGridDelegate gridDelegate;

  @override
  SliverResortableGridState createState() => SliverResortableGridState();

  static SliverResortableGridState of(BuildContext context) {
    final result = context.findAncestorStateOfType<SliverResortableGridState>();
    assert(result != null, 'No SliverResortableGridState found above');
    return result!;
  }

  static SliverResortableGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SliverResortableGridState>();
  }
}

class IndexData {
  final int group;
  final int item;

  IndexData(this.group, this.item);

  @override
  operator ==(Object? other) =>
      other is IndexData && other.hashCode == hashCode;

  @override
  int get hashCode => group.hashCode ^ item.hashCode;
}

class SliverResortableGridState extends State<SliverResortableGrid>
    with TickerProviderStateMixin {
  final _items = <int, Map<int, _ResortableItemState>>{};

  OverlayEntry? _overlayEntry;
  IndexData? _dragIndex;
  _DragInfo? _dragInfo;
  IndexData? _insertIndex;
  Offset? _finalDropPosition;
  MultiDragGestureRecognizer? _recognizer;
  bool _autoScrolling = false;

  @override
  void didUpdateWidget(covariant SliverResortableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    Function eq = const DeepCollectionEquality().equals;
    if (!eq(widget.itemCount, oldWidget.itemCount)) cancelReorder();
  }

  @override
  void dispose() {
    _dragInfo?.dispose();
    super.dispose();
  }

  void startItemDragReorder({
    required int groupIndex,
    required int itemIndex,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    assert(0 <= itemIndex && itemIndex < widget.itemCount[groupIndex]);

    setState(() {
      if (_dragInfo != null) {
        cancelReorder();
      }

      if (_items[groupIndex]?.containsKey(itemIndex) ?? false) {
        _dragIndex = IndexData(groupIndex, itemIndex);
        _recognizer = recognizer
          ..onStart = _dragStart
          ..addPointer(event);
      } else {
        throw Exception('Attempting to start a drag on a non-visible item');
      }
    });
  }

  void cancelReorder() {
    _dragReset();
  }

  void _registerItem(_ResortableItemState item) {
    if (!_items.containsKey(item.groupIndex)) _items[item.groupIndex] = {};
    _items[item.groupIndex]![item.itemIndex] = item;

    if (item.itemIndex == _dragInfo?.itemIndex &&
        item.groupIndex == _dragInfo?.groupindex) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unregisterItem(int group, int index, _ResortableItemState item) {
    final _ResortableItemState? currentItem = _items[group]![index];
    if (currentItem == item) _items[group]!.remove(index);
  }

  Drag? _dragStart(Offset position) {
    assert(_dragInfo == null);
    final _ResortableItemState item =
        _items[_dragIndex!.group]![_dragIndex!.item]!;
    item.dragging = true;
    item.rebuild();

    _insertIndex = IndexData(item.groupIndex, item.itemIndex);

    _dragInfo = _DragInfo(
      item: item,
      initialPosition: position,
      onUpdate: _dragUpdate,
      onCancel: _dragCancel,
      onEnd: _dragEnd,
      onDropCompleted: _dropCompleted,
      proxyDecorator: widget.proxyDecorator,
      tickerProvider: this,
    );
    _dragInfo!.startDrag();

    final OverlayState overlay = Overlay.of(context)!;
    assert(_overlayEntry == null);
    _overlayEntry = OverlayEntry(builder: _dragInfo!.createProxy);
    overlay.insert(_overlayEntry!);

    for (final group in _items.entries) {
      for (final childItem in group.value.values) {
        if (childItem == item || !childItem.mounted) continue;
        if (item.groupIndex != group.key) continue;

        childItem.updateForGap(_insertIndex!.item, false);
      }
    }

    return _dragInfo;
  }

  void _dragUpdate(_DragInfo item, Offset position, Offset delta) {
    setState(() {
      _overlayEntry?.markNeedsBuild();
      _dragUpdateItems();
      _autoScrollIfNecessary();
    });
  }

  void _dragCancel(_DragInfo item) {
    _dragReset();
  }

  void _dragEnd(_DragInfo item) {
    setState(() {
      if (_insertIndex!.item < widget.itemCount[_insertIndex!.group] - 1) {
        // Find the location of the item we want to insert before
        _finalDropPosition =
            _itemOffsetAt(_insertIndex!.group, _insertIndex!.item);
      } else {
        // Inserting into the last spot on the grid. If it's the only spot, put
        // it back where it was. Otherwise, grab the second to last and move
        // down by the gap.
        final int itemIndex = _items[_insertIndex!.group]!.length > 1
            ? _insertIndex!.item - 1
            : _insertIndex!.item;

        _finalDropPosition = item.itemSize.center(
          _itemOffsetAt(_insertIndex!.group, itemIndex),
        );
      }
    });
  }

  void _dropCompleted() {
    final fromIndex = _dragIndex!;
    final toIndex = _insertIndex!;
    if (fromIndex != toIndex) {
      widget.onReorder.call(fromIndex, toIndex);
    }
    _dragReset();
  }

  void _dragReset() {
    setState(() {
      if (_dragInfo == null) return;

      if (_dragIndex != null &&
          _items.containsKey(_dragIndex!.group) &&
          _items[_dragIndex!.group]!.containsKey(_dragIndex!.item)) {
        final _ResortableItemState dragItem =
            _items[_dragIndex!.group]![_dragIndex!.item]!;
        dragItem._dragging = false;
        dragItem.rebuild();
        _dragIndex = null;
      }

      _dragInfo?.dispose();
      _dragInfo = null;
      _resetItemGap();
      _recognizer?.dispose();
      _recognizer = null;
      _overlayEntry?.remove();
      _overlayEntry = null;
      _finalDropPosition = null;
    });
  }

  void _resetItemGap() {
    for (final group in _items.values) {
      for (final _ResortableItemState item in group.values) {
        item.resetGap();
      }
    }
  }

  void _dragUpdateItems() {
    assert(_dragInfo != null);
    IndexData newIndex = _insertIndex!;

    for (final group in _items.values) {
      for (final _ResortableItemState item in group.values) {
        if ((item.groupIndex == _dragIndex!.group &&
                item.itemIndex == _dragIndex!.item) ||
            !item.mounted) continue;

        final Rect geometry = item.targetGeometry();

        if (geometry.contains(_dragInfo!.dragPosition)) {
          newIndex = IndexData(item.groupIndex, item.itemIndex);
        }
      }
    }

    if (newIndex == _insertIndex) return;
    _insertIndex = newIndex;

    for (final group in _items.values) {
      for (final _ResortableItemState item in group.values) {
        if (_insertIndex!.group != item.groupIndex) continue;
        item.updateForGap(_insertIndex!.item, true);
      }
    }
  }

  Future<void> _autoScrollIfNecessary() async {
    if (_autoScrolling || _dragInfo == null || _dragInfo!.scrollable == null) {
      return;
    }

    final ScrollPosition position = _dragInfo!.scrollable!.position;
    double? newOffset;

    const Duration duration = Duration(milliseconds: 14);
    const double step = 1.0;
    const double overDragMax = 20.0;
    const double overDragCoef = 10;

    final RenderBox scrollRenderBox =
        _dragInfo!.scrollable!.context.findRenderObject()! as RenderBox;
    final Offset scrollOrigin = scrollRenderBox.localToGlobal(Offset.zero);

    final scrollStart = scrollOrigin.dy;
    final scrollEnd = scrollStart + scrollRenderBox.size.height;

    final double proxyStart =
        (_dragInfo!.dragPosition - _dragInfo!.dragOffset).dy;
    final double proxyEnd = proxyStart + _dragInfo!.itemSize.height;

    if (proxyStart < scrollStart &&
        position.pixels > position.minScrollExtent) {
      final double overDrag = max(scrollStart - proxyStart, overDragMax);
      newOffset = max(position.minScrollExtent,
          position.pixels - step * overDrag / overDragCoef);
    } else if (proxyEnd > scrollEnd &&
        position.pixels < position.maxScrollExtent) {
      final double overDrag = max(proxyEnd - scrollEnd, overDragMax);
      newOffset = min(position.maxScrollExtent,
          position.pixels + step * overDrag / overDragCoef);
    }

    if (newOffset != null && (newOffset - position.pixels).abs() >= 1.0) {
      _autoScrolling = true;
      await position.animateTo(
        newOffset,
        duration: duration,
        curve: Curves.linear,
      );
      _autoScrolling = false;
      if (_dragInfo != null) {
        _dragUpdateItems();
        _autoScrollIfNecessary();
      }
    }
  }

  Offset _calculateNextDragOffset(int groupIndex, int itemIndex) {
    if (_dragIndex!.group != groupIndex) return Offset.zero;

    int minPos = min(_dragIndex!.item, _insertIndex!.item);
    int maxPos = max(_dragIndex!.item, _insertIndex!.item);

    if (itemIndex < minPos || itemIndex > maxPos) return Offset.zero;

    final int direction = _insertIndex!.item > _dragIndex!.item ? -1 : 1;
    return _itemOffsetAt(groupIndex, itemIndex + direction) -
        _itemOffsetAt(groupIndex, itemIndex);
  }

  Offset _itemOffsetAt(int groupIndex, int itemIndex) {
    final box = _items[groupIndex]?[itemIndex]?.context.findRenderObject()
        as RenderBox?;
    if (box == null) return Offset.zero;

    return box.localToGlobal(Offset.zero);
  }

  Widget _itemBuilder(BuildContext context, int group, int item) {
    if (_dragInfo != null &&
        _dragInfo!.groupindex == group &&
        item >= widget.itemCount[group]) {
      return SizedBox.fromSize(size: _dragInfo!.itemSize);
    }

    final Widget child = widget.itemBuilder(context, group, item);
    assert(child.key != null, 'All grid items must have a key');

    final OverlayState overlay = Overlay.of(context)!;
    return _ResortableItem(
      key: _ResortableItemGlobalKey(child.key!, group, item, this),
      groupIndex: group,
      itemIndex: item,
      capturedThemes:
          InheritedTheme.capture(from: context, to: overlay.context),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    return MultiSliver(
      children: [
        for (var group = 0; group < widget.itemCount.length; group++) ...[
          widget.groupHeaderBuilder(context, group),
          SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (ctx, item) => _itemBuilder(context, group, item),
              childCount: widget.itemCount[group] +
                  (_dragInfo != null && _dragInfo!.groupindex == group ? 1 : 0),
            ),
          ),
        ]
      ],
    );
  }
}

class _ResortableItem extends StatefulWidget {
  const _ResortableItem({
    required Key key,
    required this.itemIndex,
    required this.groupIndex,
    required this.child,
    required this.capturedThemes,
  }) : super(key: key);

  final int itemIndex;
  final int groupIndex;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  _ResortableItemState createState() => _ResortableItemState();
}

class _ResortableItemState extends State<_ResortableItem> {
  late SliverResortableGridState _listState;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _offsetAnimation;

  Key get key => widget.key!;
  int get itemIndex => widget.itemIndex;
  int get groupIndex => widget.groupIndex;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  @override
  void initState() {
    _listState = SliverResortableGrid.of(context);
    _listState._registerItem(this);
    super.initState();
  }

  @override
  void dispose() {
    _offsetAnimation?.dispose();
    _listState._unregisterItem(groupIndex, itemIndex, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ResortableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupIndex != widget.groupIndex ||
        oldWidget.itemIndex != widget.itemIndex) {
      _listState._unregisterItem(
          oldWidget.groupIndex, oldWidget.itemIndex, this);
      _listState._registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      return const SizedBox.shrink();
    }
    _listState._registerItem(this);
    return Transform(
      transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _listState._unregisterItem(groupIndex, itemIndex, this);
    super.deactivate();
  }

  Offset get offset {
    if (_offsetAnimation != null) {
      final double animValue =
          Curves.easeInOut.transform(_offsetAnimation!.value);
      return Offset.lerp(_startOffset, _targetOffset, animValue)!;
    }
    return _targetOffset;
  }

  void updateForGap(int gapIndex, bool animate) {
    if (!mounted) return;

    final newTargetOffset =
        _listState._calculateNextDragOffset(groupIndex, itemIndex);

    if (newTargetOffset == _targetOffset) return;
    _targetOffset = newTargetOffset;

    if (animate) {
      if (_offsetAnimation == null) {
        _offsetAnimation = AnimationController(
          vsync: _listState,
          duration: const Duration(milliseconds: 250),
        )
          ..addListener(rebuild)
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _startOffset = _targetOffset;
              _offsetAnimation!.dispose();
              _offsetAnimation = null;
            }
          })
          ..forward();
      } else {
        _startOffset = offset;
        _offsetAnimation!.forward(from: 0.0);
      }
    } else {
      if (_offsetAnimation != null) {
        _offsetAnimation!.dispose();
        _offsetAnimation = null;
      }
      _startOffset = _targetOffset;
    }
    rebuild();
  }

  void resetGap() {
    if (_offsetAnimation != null) {
      _offsetAnimation!.dispose();
      _offsetAnimation = null;
    }
    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  Rect targetGeometry() {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    final Offset itemPosition =
        itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// A wrapper widget that will recognize the start of a drag on the wrapped
/// widget by a [PointerDownEvent], and immediately initiate dragging the
/// wrapped item to a new location in a reorderable grid.
///
/// See also:
///
///  * [ResortableGridDelayedDragStartListener], a similar wrapper that will
///    only recognize the start after a long press event.
///  * [ResortableGrid], a widget grid that allows the user to reorder
///    its items.
///  * [SliverResortableGrid], a sliver grid that allows the user to reorder
///    its items.
///  * [ResortableGridView], a material design grid that allows the user to
///    reorder its items.
class ResortableGridDragStartListener extends StatelessWidget {
  /// Creates a listener for a drag immediately following a pointer down
  /// event over the given child widget.
  ///
  /// This is most commonly used to wrap part of a grid item like a drag
  /// handle.
  const ResortableGridDragStartListener({
    Key? key,
    required this.child,
    required this.groupIndex,
    required this.itemIndex,
    this.enabled = true,
  }) : super(key: key);

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a reordering drag on a reorderable grid.
  final Widget child;

  /// The index of the associated item that will be dragged in the grid.
  final int groupIndex;
  final int itemIndex;

  /// Whether the [child] item can be dragged and moved in the grid.
  ///
  /// If true, the item can be moved to another location in the grid when the
  /// user taps on the child. If false, tapping on the child will be ignored.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled
          ? (PointerDownEvent event) => _startDragging(context, event)
          : null,
      child: child,
    );
  }

  /// Provides the gesture recognizer used to indicate the start of a reordering
  /// drag operation.
  ///
  /// By default this returns an [ImmediateMultiDragGestureRecognizer] but
  /// subclasses can use this to customize the drag start gesture.
  @protected
  MultiDragGestureRecognizer createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final SliverResortableGridState? list =
        SliverResortableGrid.maybeOf(context);
    list?.startItemDragReorder(
      groupIndex: groupIndex,
      itemIndex: itemIndex,
      event: event,
      recognizer: createRecognizer(),
    );
  }
}

/// A wrapper widget that will recognize the start of a drag operation by
/// looking for a long press event. Once it is recognized, it will start
/// a drag operation on the wrapped item in the reorderable grid.
///
/// See also:
///
///  * [ResortableGridDragStartListener], a similar wrapper that will
///    recognize the start of the drag immediately after a pointer down event.
///  * [ResortableGrid], a widget grid that allows the user to reorder
///    its items.
///  * [SliverResortableGrid], a sliver grid that allows the user to reorder
///    its items.
///  * [ResortableGridView], a material design grid that allows the user to
///    reorder its items.
class ResortableGridDelayedDragStartListener
    extends ResortableGridDragStartListener {
  /// Creates a listener for an drag following a long press event over the
  /// given child widget.
  ///
  /// This is most commonly used to wrap an entire grid item in a reorderable
  /// grid.
  const ResortableGridDelayedDragStartListener({
    Key? key,
    required Widget child,
    required int itemIndex,
    required int groupIndex,
    bool enabled = true,
  }) : super(
          key: key,
          child: child,
          groupIndex: groupIndex,
          itemIndex: itemIndex,
          enabled: enabled,
        );

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }
}

typedef _DragItemUpdate = void Function(
    _DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_DragInfo item);

class _DragInfo extends Drag {
  _DragInfo({
    required _ResortableItemState item,
    Offset initialPosition = Offset.zero,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.onDropCompleted,
    this.proxyDecorator,
    required this.tickerProvider,
  }) {
    final itemRenderBox = item.context.findRenderObject()! as RenderBox;
    listState = item._listState;
    itemIndex = item.itemIndex;
    groupindex = item.groupIndex;
    child = item.widget.child;
    capturedThemes = item.widget.capturedThemes;
    dragPosition = initialPosition;
    dragOffset = itemRenderBox.globalToLocal(initialPosition);
    itemSize = item.context.size!;
    scrollable = Scrollable.of(item.context);
  }

  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onEnd;
  final _DragItemCallback? onCancel;
  final VoidCallback? onDropCompleted;
  final ResortableItemProxyDecorator? proxyDecorator;
  final TickerProvider tickerProvider;

  late SliverResortableGridState listState;
  late int itemIndex;
  late int groupindex;
  late Widget child;
  late Offset dragPosition;
  late Offset dragOffset;
  late Size itemSize;
  late CapturedThemes capturedThemes;
  ScrollableState? scrollable;
  AnimationController? _proxyAnimation;

  void dispose() {
    _proxyAnimation?.dispose();
  }

  void startDrag() {
    _proxyAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 250),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _dropCompleted();
        }
      })
      ..forward();
  }

  @override
  void update(DragUpdateDetails details) {
    dragPosition += details.delta;
    onUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    _proxyAnimation!.reverse();
    onEnd?.call(this);
  }

  @override
  void cancel() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onCancel?.call(this);
  }

  void _dropCompleted() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onDropCompleted?.call();
  }

  Widget createProxy(BuildContext context) {
    return capturedThemes.wrap(
      _DragItemProxy(
        listState: listState,
        itemIndex: itemIndex,
        groupIndex: groupindex,
        size: itemSize,
        animation: _proxyAnimation!,
        position: dragPosition - dragOffset - _overlayOrigin(context),
        proxyDecorator: proxyDecorator,
        child: child,
      ),
    );
  }
}

Offset _overlayOrigin(BuildContext context) {
  final OverlayState overlay = Overlay.of(context)!;
  final RenderBox overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

typedef ResortableItemProxyDecorator = Widget Function(
  Widget child,
  int groupIndex,
  int itemIndex,
  Animation<double> animation,
);

class _DragItemProxy extends StatelessWidget {
  const _DragItemProxy({
    Key? key,
    required this.listState,
    required this.groupIndex,
    required this.itemIndex,
    required this.child,
    required this.position,
    required this.size,
    required this.animation,
    required this.proxyDecorator,
  }) : super(key: key);

  final SliverResortableGridState listState;
  final int groupIndex;
  final int itemIndex;
  final Widget child;
  final Offset position;
  final Size size;
  final AnimationController animation;
  final ResortableItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    final Widget proxyChild = proxyDecorator?.call(
          child,
          groupIndex,
          itemIndex,
          animation.view,
        ) ??
        child;

    final Offset overlayOrigin = _overlayOrigin(context);

    return MediaQuery(
      // Remove the top padding so that any nested grid views in the item
      // won't pick up the scaffold's padding in the overlay.
      data: MediaQuery.of(context).removePadding(removeTop: true),
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          Offset effectivePosition = position;
          final Offset? dropPosition = listState._finalDropPosition;

          if (dropPosition != null) {
            effectivePosition = Offset.lerp(dropPosition - overlayOrigin,
                effectivePosition, Curves.easeOut.transform(animation.value))!;
          }

          return Positioned(
            left: effectivePosition.dx,
            top: effectivePosition.dy,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          );
        },
        child: proxyChild,
      ),
    );
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ResortableItemGlobalKey extends GlobalObjectKey {
  const _ResortableItemGlobalKey(
      this.subKey, this.groupIndex, this.itemIndex, this.state)
      : super(subKey);

  final Key subKey;
  final int groupIndex;
  final int itemIndex;
  final SliverResortableGridState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _ResortableItemGlobalKey &&
        other.subKey == subKey &&
        other.groupIndex == groupIndex &&
        other.itemIndex == itemIndex &&
        other.state == state;
  }

  @override
  int get hashCode => hashValues(subKey, groupIndex, itemIndex, state);
}
