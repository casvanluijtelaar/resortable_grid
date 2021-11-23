import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:sliver_tools/sliver_tools.dart';

typedef ResortableCallback = void Function(
  ResortableIndex oldIndex,
  ResortableIndex newIndex,
);

typedef ResortableWidgetBuilder = Widget Function(
  BuildContext context,
  ResortableIndex index,
);

typedef ResortableHeaderBuilder = Widget Function(
  BuildContext context,
  int group,
);

typedef ResortableItemProxyDecorator = Widget Function(
  Widget child,
  ResortableIndex index,
  Animation<double> animation,
);

/// {@template reorderable_grid_view.reorderable_grid}
/// A scrolling container that allows the user to interactively reorder the
/// grid items.
///
/// This widget is similar to one created by [GridView.builder], and uses
/// an [ResortableWidgetBuilder] to create each item.
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
class ResortableGrid extends StatefulWidget {
  /// {@macro reorderable_grid_view.reorderable_grid}
  /// The [itemCount] must be greater than or equal to zero.
  const ResortableGrid({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    required this.headerBuilder,
    required this.newGroupTargetBuilder,
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
  /// The [ResortableWidgetBuilder] index parameter indicates the item's
  /// position in the grid. The value of the index parameter will be between
  /// zero and one less than [itemCount]. All items in the grid must have a
  /// unique [Key], and should have some kind of listener to start the drag
  /// (usually a [ResortableGridDragStartListener] or
  /// [ResortableGridDelayedDragStartListener]).
  final ResortableWidgetBuilder itemBuilder;

  ///TODO comment
  final ResortableHeaderBuilder headerBuilder;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  final List<int> itemCount;

  ///TODO comment
  final ResortableCallback onReorder;

  ///TODO comment
  final ResortableItemProxyDecorator? proxyDecorator;

  final WidgetBuilder newGroupTargetBuilder;

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
    required ResortableIndex index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    _sliverResortableGridKey.currentState!.startItemDragReorder(
        index: index, event: event, recognizer: recognizer);
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
            headerBuilder: widget.headerBuilder,
            newGroupTargetBuilder: widget.newGroupTargetBuilder,
            itemCount: widget.itemCount,
            onReorder: widget.onReorder,
            proxyDecorator: widget.proxyDecorator,
          ),
        ),
      ],
    );
  }
}

/// A sliver grid that allows the user to interactively reorder the grid items.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child) with a drag listener that will recognize the start of an item drag
/// and then start the reorder by calling
/// [SliverResortableGridState.startItemDragReorder]. This is most easily
/// achieved by wrapping each child in a [ResortableGridDragStartListener] or
/// a [ResortableGridDelayedDragStartListener]. These will take care of
/// recognizing the start of a drag gesture and call the grid state's start
/// item drag method.
///
/// This widget's [SliverResortableGridState] can be used to manually start an item
/// reorder, or cancel a current drag that's already underway. To refer to the
/// [SliverResortableGridState] either provide a [GlobalKey] or use the static
/// [SliverResortableGrid.of] method from an item's build method.
///
/// See also:
///
///  * [ResortableGrid], a regular widget grid that allows the user to reorder
///    its items.
class SliverResortableGrid extends StatefulWidget {
  /// Creates a sliver grid that allows the user to interactively reorder its
  /// items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const SliverResortableGrid({
    Key? key,
    required this.itemBuilder,
    required this.headerBuilder,
    required this.itemCount,
    required this.onReorder,
    required this.gridDelegate,
    required this.newGroupTargetBuilder,
    this.proxyDecorator,
  }) : super(key: key);

  ///TODO comment
  final ResortableWidgetBuilder itemBuilder;

  ///TODO comment
  final ResortableHeaderBuilder headerBuilder;

  final WidgetBuilder newGroupTargetBuilder;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  final List<int> itemCount;

  //TODO comment
  final ResortableCallback onReorder;

  /// {@macro flutter.widgets.reorderable_list.proxyDecorator}
  final ResortableItemProxyDecorator? proxyDecorator;

  //TODO comment
  final SliverGridDelegate gridDelegate;

  @override
  SliverResortableGridState createState() => SliverResortableGridState();

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverResortableGrid] item widgets to
  /// start or cancel an item drag operation.
  ///
  /// If no [SliverResortableGrid] surrounds the context given, this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverResortableGrid] ancestor is found.
  static SliverResortableGridState of(BuildContext context) {
    final SliverResortableGridState? result =
        context.findAncestorStateOfType<SliverResortableGridState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverResortableGrid.of() called with a context that does not contain a SliverResortableGrid.',
          ),
          ErrorDescription(
            'No SliverResortableGrid ancestor could be found starting from the context that was passed to SliverResortableGrid.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same StatefulWidget that '
            'built the SliverResortableGrid. Please see the SliverResortableGrid documentation for examples '
            'of how to refer to an SliverResortableGrid object:\n'
            '  https://api.flutter.dev/flutter/widgets/SliverResortableGridState-class.html',
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
  /// This method is typically used by [SliverResortableGrid] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [SliverResortableGrid] surrounds the context given, this function
  /// will return null.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [SliverResortableGrid]
  ///    ancestor is found.
  static SliverResortableGridState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<SliverResortableGridState>();
  }
}

/// The state for a sliver grid that allows the user to interactively reorder
/// the grid items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [SliverResortableGrid]'s state with a global key:
///
/// ```dart
/// GlobalKey<SliverResortableGridState> gridKey = GlobalKey<SliverResortableGridState>();
/// ...
/// SliverResortableGrid(key: gridKey, ...);
/// ...
/// gridKey.currentState.cancelReorder();
/// ```
///
/// [ResortableGridDragStartListener] and [ResortableGridDelayedDragStartListener]
/// refer to their [SliverResortableGrid] with the static
/// [SliverResortableGrid.of] method.
class SliverResortableGridState extends State<SliverResortableGrid>
    with TickerProviderStateMixin {
  // Map of index -> child state used manage where the dragging item will need
  // to be inserted.
  final _items = <int, Map<int, _ReorderableItemState>>{};
  final _newGroupTargetKey = GlobalKey();

  OverlayEntry? _overlayEntry;

  ResortableIndex? _dragIndex;
  _DragInfo? _dragInfo;
  ResortableIndex? _insertIndex;

  Offset? _finalDropPosition;
  MultiDragGestureRecognizer? _recognizer;
  bool _autoScrolling = false;

  @override
  void didUpdateWidget(covariant SliverResortableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount) {
      cancelReorder();
    }
  }

  @override
  void dispose() {
    _dragInfo?.dispose();
    super.dispose();
  }

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a cancelled drag.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [ResortableGridDragStartListener] or [ResortableGridDelayedDragStartListener]
  /// which call this method when they detect the gesture that triggers a drag
  /// start.
  void startItemDragReorder({
    required ResortableIndex index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    assert(0 <= index.item && index.item < widget.itemCount[index.group]);
    setState(() {
      if (_dragInfo != null) {
        cancelReorder();
      }
      if (getItemFromIndex(index) != null) {
        _dragIndex = index;
        _recognizer = recognizer
          ..onStart = _dragStart
          ..addPointer(event);
      } else {
        throw Exception('Attempting to start a drag on a non-visible item');
      }
    });
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item grid
  /// occur so that any item drags will not get confused by
  /// changes to the underlying grid.
  ///
  /// If a drag operation is in progress, this will immediately reset
  /// the grid to back to its pre-drag state.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    _dragReset();
  }

  _ReorderableItemState? getItemFromIndex(ResortableIndex index) {
    return _items[index.group]?[index.item];
  }

  void _registerItem(_ReorderableItemState item) {
    if (_items[item.index.group] == null) _items[item.index.group] = {};
    _items[item.index.group]![item.index.item] = item;

    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unregisterItem(ResortableIndex index, _ReorderableItemState item) {
    final _ReorderableItemState? currentItem = getItemFromIndex(index);
    if (currentItem == item) _items.remove(index);
  }

  Drag? _dragStart(Offset position) {
    assert(_dragInfo == null);
    final _ReorderableItemState item = getItemFromIndex(_dragIndex!)!;
    item.dragging = true;
    item.rebuild();

    _insertIndex = item.index;

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

    for (final groupData in _items.values) {
      for (final itemData in groupData.values) {
        if (item == itemData || !itemData.mounted) continue;
        itemData.updateForGap(_insertIndex!, false);
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
      
      if (_insertIndex!.group > widget.itemCount.length - 1) {
        _finalDropPosition = _newGrouptargetGeometry().center;
        return;
      }

      //TODO: if it doesn't work match group
      if (_insertIndex!.item < widget.itemCount[_insertIndex!.group] - 1) {
        // Find the location of the item we want to insert before
        _finalDropPosition = _itemOffsetAt(_insertIndex!);
        return;
      }

      // Inserting into the last spot on the grid. If it's the only spot, put
      // it back where it was. Otherwise, grab the second to last and move
      // down by the gap.
      final ResortableIndex index = _insertIndex!.copyWith(
        item: _items[_insertIndex!.group]!.length > 1
            ? _insertIndex!.item - 1
            : _insertIndex!.item,
      );
      _finalDropPosition = item.itemSize.center(_itemOffsetAt(index));
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
      if (_dragInfo != null) {
        if (_dragIndex != null && _items.containsKey(_dragIndex)) {
          final _ReorderableItemState dragItem = getItemFromIndex(_dragIndex!)!;
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
      }
    });
  }

  void _resetItemGap() {
    for (final group in _items.values) {
      for (final item in group.values) {
        item.resetGap();
      }
    }
  }

  Rect _newGrouptargetGeometry() {
    final targetContext = _newGroupTargetKey.currentContext!;
    final targetBox = targetContext.findRenderObject()! as RenderBox;

    final targetSize = targetBox.size;
    final targetPosition = targetBox.localToGlobal(Offset.zero);

    return targetPosition & targetSize;
  }

  void _dragUpdateItems() {
    assert(_dragInfo != null);

    ResortableIndex newIndex = _insertIndex!;

    /// if we are hovering over the 'new group' target, we want to set
    /// the newIndex to the last group + 1, otherwise check if we are hovering
    /// over an item and if so, set the newIndex to the item's index
    if (_newGrouptargetGeometry().contains(_dragInfo!.dragPosition)) {
      newIndex = ResortableIndex(widget.itemCount.length, 0);
    } else {
      for (final group in _items.values) {
        for (final item in group.values) {
          if (item.index == _dragIndex! || !item.mounted) continue;

          final Rect geometry = item.targetGeometry();
          if (geometry.contains(_dragInfo!.dragPosition)) {
            newIndex = item.index;
          }
        }
      }
    }

    if (newIndex == _insertIndex) return;
    _insertIndex = newIndex;

    for (final group in _items.values) {
      for (final item in group.values) {
        item.updateForGap(_insertIndex!, true);
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

  ///TODO broken
  Offset _calculateNextDragOffset(ResortableIndex index) {
    if (index.group != _insertIndex!.group) return Offset.zero;

    int minPos = min(_dragIndex!.item, _insertIndex!.item);
    int maxPos = max(_dragIndex!.item, _insertIndex!.item);

    if (index.item < minPos || index.item > maxPos) return Offset.zero;

    final int direction = _insertIndex!.item > _dragIndex!.item ? -1 : 1;
    return _itemOffsetAt(index.copyWith(item: index.item + direction)) -
        _itemOffsetAt(index);
  }

  Offset _itemOffsetAt(ResortableIndex index) {
    final item = getItemFromIndex(index);
    if (item == null || !item.mounted) return Offset.zero;

    final box = item.context.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  Widget _itemBuilder(BuildContext context, ResortableIndex index) {
    if (_dragInfo != null && index.item >= widget.itemCount[index.group]) {
      return SizedBox.fromSize(size: _dragInfo!.itemSize);
    }

    final Widget child = widget.itemBuilder(context, index);
    assert(child.key != null, 'All grid items must have a key');

    return _ReorderableItem(
      key: _ResortableItemGlobalKey(child.key!, index, this),
      index: index,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: Overlay.of(context)!.context,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));

    return MultiSliver(
      children: [
        for (var group = 0; group < widget.itemCount.length; group++) ...[
          // group header
          SliverToBoxAdapter(child: widget.headerBuilder(context, group)),
          // group grid
          SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (ctx, item) => _itemBuilder(ctx, ResortableIndex(group, item)),
              childCount: widget.itemCount[group],
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: KeyedSubtree(
            key: _newGroupTargetKey,
            child: widget.newGroupTargetBuilder(context),
          ),
        ),
      ],
    );
  }
}

class _ReorderableItem extends StatefulWidget {
  const _ReorderableItem({
    required Key key,
    required this.index,
    required this.child,
    required this.capturedThemes,
  }) : super(key: key);

  final ResortableIndex index;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  _ReorderableItemState createState() => _ReorderableItemState();
}

class _ReorderableItemState extends State<_ReorderableItem> {
  late SliverResortableGridState _listState;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _offsetAnimation;

  Key get key => widget.key!;
  ResortableIndex get index => widget.index;

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
    _listState._unregisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ReorderableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState._unregisterItem(oldWidget.index, this);
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
    _listState._unregisterItem(index, this);
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

  void updateForGap(ResortableIndex gapIndex, bool animate) {
    if (!mounted) return;

    final Offset newTargetOffset = _listState._calculateNextDragOffset(index);

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
    final itemRenderBox = context.findRenderObject()! as RenderBox;
    final itemPosition =
        itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  void rebuild() {
    if (mounted) setState(() {});
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
    required this.index,
    this.enabled = true,
  }) : super(key: key);

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a reordering drag on a reorderable grid.
  final Widget child;

  /// The index of the associated item that will be dragged in the grid.
  final ResortableIndex index;

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
      index: index,
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
    required ResortableIndex index,
    bool enabled = true,
  }) : super(key: key, child: child, index: index, enabled: enabled);

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
    required _ReorderableItemState item,
    Offset initialPosition = Offset.zero,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.onDropCompleted,
    this.proxyDecorator,
    required this.tickerProvider,
  }) {
    final RenderBox itemRenderBox =
        item.context.findRenderObject()! as RenderBox;
    listState = item._listState;
    index = item.index;
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
  late ResortableIndex index;
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
        index: index,
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

class _DragItemProxy extends StatelessWidget {
  const _DragItemProxy({
    Key? key,
    required this.listState,
    required this.index,
    required this.child,
    required this.position,
    required this.size,
    required this.animation,
    required this.proxyDecorator,
  }) : super(key: key);

  final SliverResortableGridState listState;
  final ResortableIndex index;
  final Widget child;
  final Offset position;
  final Size size;
  final AnimationController animation;
  final ResortableItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    final Widget proxyChild =
        proxyDecorator?.call(child, index, animation.view) ?? child;
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
  const _ResortableItemGlobalKey(this.subKey, this.index, this.state)
      : super(subKey);

  final Key subKey;
  final ResortableIndex index;
  final SliverResortableGridState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _ResortableItemGlobalKey &&
        other.subKey == subKey &&
        other.index == index &&
        other.state == state;
  }

  @override
  int get hashCode => hashValues(subKey, index, state);
}

/// class holding group and item index data
class ResortableIndex {
  const ResortableIndex(this.group, this.item);

  final int group;
  final int item;

  ResortableIndex copyWith({int? group, int? item}) => ResortableIndex(
        group ?? this.group,
        item ?? this.item,
      );

  @override
  String toString() => 'group: $group, item: $item';

  @override
  bool operator ==(Object? other) =>
      other is ResortableIndex && other.group == group && other.item == item;

  @override
  int get hashCode => group.hashCode ^ item.hashCode;
}
