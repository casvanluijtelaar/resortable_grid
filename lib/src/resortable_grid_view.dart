import 'dart:ui' show lerpDouble;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:resortable_grid/src/resortable_grid.dart';

/// A scrollable, reorderable, 2D array of widgets.
///
/// The main axis direction of a grid is the direction in which it scrolls (the
/// [scrollDirection]).
///
/// The most commonly used grid layouts are [ResortableGridView.count], which creates a
/// layout with a fixed number of tiles in the cross axis, and
/// [ResortableGridView.extent], which creates a layout with tiles that have a maximum
/// cross-axis extent. A custom [SliverGridDelegate] can produce an arbitrary 2D
/// arrangement of children, including arrangements that are unaligned or
/// overlapping.
///
/// To create a grid with a large (or infinite) number of children, use the
/// [ResortableGridView.builder] constructor with either a
/// [SliverGridDelegateWithFixedCrossAxisCount] or a
/// [SliverGridDelegateWithMaxCrossAxisExtent] for the [gridDelegate].
///
/// To create a linear array of reorderable children, use a [ReorderableList].
///
/// To control the initial scroll offset of the scroll view, provide a
/// [controller] with its [ScrollController.initialScrollOffset] property set.
///
/// ## Transitioning to [CustomScrollView]
///
/// A [ResortableGridView] is basically a [CustomScrollView] with a single [SliverResortableGrid] in
/// its [CustomScrollView.slivers] property.
///
/// If [ResortableGridView] is no longer sufficient, for example because the scroll view
/// is to have both a grid and a list, or because the grid is to be combined
/// with a [SliverAppBar], etc, it is straight-forward to port code from using
/// [ResortableGridView] to using [CustomScrollView] directly.
///
/// The [key], [scrollDirection], [reverse], [controller], [primary], [physics],
/// and [shrinkWrap] properties on [ResortableGridView] map directly to the identically
/// named properties on [CustomScrollView].
///
/// The [CustomScrollView.slivers] property should be a list containing just a
/// [SliverGrid].
///
/// the [gridDelegate] property on the
/// [ResortableGridView] corresponds to the [SliverGrid.gridDelegate] property.
///
/// The [ResortableGridView], [ResortableGridView.count], and [ResortableGridView.extent]
/// constructors' `children` arguments correspond to the [childrenDelegate]
/// being a [SliverChildListDelegate] with that same argument. The
/// [ResortableGridView.builder] constructor's `itemBuilder` and `childCount` arguments
/// correspond to the [childrenDelegate] being a [SliverChildBuilderDelegate]
/// with the matching arguments.
///
/// The [ResortableGridView.count] and [ResortableGridView.extent] constructors create
/// custom grid delegates, and have equivalently named constructors on
/// [SliverGrid] to ease the transition: [SliverGrid.count] and
/// [SliverGrid.extent] respectively.
///
/// The [padding] property corresponds to having a [SliverPadding] in the
/// [CustomScrollView.slivers] property instead of the grid itself, and having
/// the [SliverGrid] instead be a child of the [SliverPadding].
///
/// Once code has been ported to use [CustomScrollView], other slivers, such as
/// [SliverList] or [SliverAppBar], can be put in the [CustomScrollView.slivers]
/// list.
///
/// {@tool snippet}
/// This example demonstrates how to create a [ResortableGridView] with two columns. The
/// children are spaced apart using the `crossAxisSpacing` and `mainAxisSpacing`
/// properties.
///
/// ```dart
/// ResortableGridView.count(
///   primary: false,
///   padding: const EdgeInsets.all(20),
///   crossAxisSpacing: 10,
///   mainAxisSpacing: 10,
///   crossAxisCount: 2,
///   onReorder: (int oldIndex, int newIndex) {
///     print('from: $oldIndex, to: $newIndex);
///   },
///   children: <Widget>[
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text("He'd have you all unravel at the"),
///       color: Colors.teal[100],
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('Heed not the rabble'),
///       color: Colors.teal[200],
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('Sound of screams but the'),
///       color: Colors.teal[300],
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('Who scream'),
///       color: Colors.teal[400],
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('Revolution is coming...'),
///       color: Colors.teal[500],
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('Revolution, they...'),
///       color: Colors.teal[600],
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows how to create the same grid as the previous example
/// using a [CustomScrollView] and a [SliverGrid].
///
/// ![The CustomScrollView contains a SliverGrid that displays six children with different background colors arranged in two columns](https://flutter.github.io/assets-for-api-docs/assets/widgets/grid_view_custom_scroll.png)
///
/// ```dart
/// CustomScrollView(
///   primary: false,
///   slivers: <Widget>[
///     SliverPadding(
///       padding: const EdgeInsets.all(20),
///       sliver: SliverResortableGrid.count(
///         crossAxisSpacing: 10,
///         mainAxisSpacing: 10,
///         crossAxisCount: 2,
///         onReorder: (int oldIndex, int newIndex) {
///           print('from: $oldIndex, to: $newIndex);
///         },
///         children: <Widget>[
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text("He'd have you all unravel at the"),
///             color: Colors.green[100],
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('Heed not the rabble'),
///             color: Colors.green[200],
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('Sound of screams but the'),
///             color: Colors.green[300],
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('Who scream'),
///             color: Colors.green[400],
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('Revolution is coming...'),
///             color: Colors.green[500],
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('Revolution, they...'),
///             color: Colors.green[600],
///           ),
///         ],
///       ),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// By default, [ResortableGridView] will automatically pad the limits of the
/// grids's scrollable to avoid partial obstructions indicated by
/// [MediaQuery]'s padding. To avoid this behavior, override with a
/// zero [padding] property.
///
/// {@tool snippet}
/// The following example demonstrates how to override the default top padding
/// using [MediaQuery.removePadding].
///
/// ```dart
/// Widget myWidget(BuildContext context) {
///   return MediaQuery.removePadding(
///     context: context,
///     removeTop: true,
///     child: ResortableGridView.builder(
///       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///         crossAxisCount: 3,
///       ),
///       itemCount: 300,
///       itemBuilder: (BuildContext context, int index) {
///         return Card(
///           color: Colors.amber,
///           child: Center(child: Text('$index')),
///         );
///       }
///     ),
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [SingleChildScrollView], which is a scrollable widget that has a single
///    child.
///  * [ReorderableList], which is scrollable, reorderable, linear list of widgets.
///  * [PageView], which is a scrolling list of child widgets that are each the
///    size of the viewport.
///  * [CustomScrollView], which is a scrollable widget that creates custom
///    scroll effects using slivers.
///  * [SliverGridDelegateWithFixedCrossAxisCount], which creates a layout with
///    a fixed number of tiles in the cross axis.
///  * [SliverGridDelegateWithMaxCrossAxisExtent], which creates a layout with
///    tiles that have a maximum cross-axis extent.
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
///  * The [catalog of layout widgets](https://flutter.dev/widgets/layout/).
class ResortableGridView<T> extends StatefulWidget {
  /// Creates a scrollable, 2D array of widgets with a custom
  /// [SliverGridDelegate].
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ResortableGridView({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
    required this.onReorder,
    this.footerBuilder,
    this.groupHeaderBuilder,
    this.cacheExtent,
    List<List<Widget>> children = const <List<Widget>>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.scrollController,
    this.anchor = 0.0,
    this.proxyDecorator,
  })  : assert(
          children
              .every((List<Widget> group) => group.every((w) => w.key != null)),
          'All children of this widget must have a key.',
        ),
        itemBuilder = ((BuildContext context, int g, int i) => children[g][i]),
        itemCount = children.map((e) => e.length).toList(),
        super(key: key);

  /// Creates a scrollable, 2D array of widgets that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null `itemCount` improves the ability of the [ResortableGridView] to
  /// estimate the maximum scroll extent.
  ///
  /// `itemBuilder` will be called only with indices greater than or equal to
  /// zero and less than `itemCount`.
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
  const ResortableGridView.builder({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
    required this.itemBuilder,
    required this.itemCount,
    required this.onReorder,
    this.groupHeaderBuilder,
    this.footerBuilder,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollController,
    this.anchor = 0.0,
    this.proxyDecorator,
  })  : assert(itemCount.length >= 0),
        super(key: key);

  /// Creates a scrollable, 2D array of widgets with a fixed number of tiles in
  /// the cross axis.
  ///
  /// Uses a [SliverGridDelegateWithFixedCrossAxisCount] as the [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.count], the equivalent constructor for [SliverGrid].
  ResortableGridView.count({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required int crossAxisCount,
    required this.onReorder,
    this.groupHeaderBuilder,
    this.footerBuilder,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    this.cacheExtent,
    List<List<Widget>> children = const <List<Widget>>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollController,
    this.anchor = 0.0,
    this.proxyDecorator,
  })  : gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        assert(
          children
              .every((List<Widget> group) => group.every((w) => w.key != null)),
          'All children of this widget must have a key.',
        ),
        itemBuilder = ((BuildContext context, int g, int i) => children[g][i]),
        itemCount = children.map((e) => e.length).toList(),
        super(key: key);

  /// Creates a scrollable, 2D array of widgets with tiles that each have a
  /// maximum cross-axis extent.
  ///
  /// Uses a [SliverGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.extent], the equivalent constructor for [SliverGrid].
  ResortableGridView.extent({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required double maxCrossAxisExtent,
    required this.onReorder,
    this.groupHeaderBuilder,
    this.footerBuilder,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    this.cacheExtent,
    List<List<Widget>> children = const <List<Widget>>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollController,
    this.anchor = 0.0,
    this.proxyDecorator,
  })  : gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        assert(
          children
              .every((List<Widget> group) => group.every((w) => w.key != null)),
          'All children of this widget must have a key.',
        ),
        itemBuilder = ((BuildContext context, int g, int i) => children[g][i]),
        itemCount = children.map((e) => e.length).toList(),
        super(key: key);

  /// A delegate that controls the layout of the children within the [ResortableGridView].
  ///
  /// The [ResortableGridView], [ResortableGridView.builder], and [ResortableGridView.custom] constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverGridDelegate gridDelegate;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.scroll_view.primary}

  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [scrollController] is null.
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

  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final int? semanticChildCount;

  final SortableWidgetBuilder itemBuilder;

  final List<int> itemCount;

  final ResortCallback onReorder;

  final ResortableItemProxyDecorator? proxyDecorator;

  final GroupHeaderBuilder? groupHeaderBuilder;
  final FooterWidgetBuilder? footerBuilder;

  @override
  _ResortableGridViewState createState() => _ResortableGridViewState();
}

class _ResortableGridViewState extends State<ResortableGridView> {
  Widget _itemBuilder(BuildContext context, int groupIndex, int itemIndex) {
    final Widget item = widget.itemBuilder(context, groupIndex, itemIndex);
    assert(() {
      if (item.key == null) {
        throw FlutterError(
          'Every item of ResortableGridView must have a key.',
        );
      }
      return true;
    }());

    final Key itemGlobalKey =
        _ResortableGridViewChildGlobalKey(item.key!, this);

    switch (Theme.of(context).platform) {
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
        return ResortableGridDragStartListener(
          key: itemGlobalKey,
          groupIndex: groupIndex,
          itemIndex: itemIndex,
          child: item,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return ResortableGridDelayedDragStartListener(
          key: itemGlobalKey,
          groupIndex: groupIndex,
          itemIndex: itemIndex,
          child: item,
        );
    }
  }

  Widget _proxyDecorator(Widget child, int groupIndex, int itemIndex,
      Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _groupHeaderBuilder(BuildContext context, int groupIndex) {
    // has to be a sliver
    return const SliverAppBar();
  }

  Widget _footerBuilder(BuildContext context) {
    return const SizedBox(
      width: double.maxFinite,
      height: 200,
      child: Center(
        child: Text('new Group'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasOverlay(context));

    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.scrollController,
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
            groupHeaderBuilder:
                widget.groupHeaderBuilder ?? _groupHeaderBuilder,
            footerBuilder: widget.footerBuilder ?? _footerBuilder,
            itemBuilder: _itemBuilder,
            gridDelegate: widget.gridDelegate,
            itemCount: widget.itemCount,
            onReorder: widget.onReorder,
            proxyDecorator: widget.proxyDecorator ?? _proxyDecorator,
          ),
        ),
      ],
    );
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ResortableGridViewChildGlobalKey extends GlobalObjectKey {
  const _ResortableGridViewChildGlobalKey(this.subKey, this.state)
      : super(subKey);

  final Key subKey;
  final State state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ResortableGridViewChildGlobalKey &&
        other.subKey == subKey &&
        other.state == state;
  }

  @override
  int get hashCode => hashValues(subKey, state);
}
