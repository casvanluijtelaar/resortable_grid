 # :black_square_button: Resortable Grid

[![Pub Version](https://img.shields.io/pub/v/resortable_grid?label=version&style=flat-square)](https://pub.dev/packages/resortable_grid/changelog)
[![Likes](https://badges.bar/resortable_grid/likes)](https://pub.dev/packages/resortable_grid/score)
[![Pub points](https://badges.bar/resortable_grid/pub%20points)](https://pub.dev/packages/resortable_grid/score) 
[![Pub](https://img.shields.io/github/stars/casvanluijtelaar/resortable_grid)](https://github.com/casvanluijtelaar/resortable_grid)
[![codecov](https://codecov.io/gh/casvanluijtelaar/resortable_grid/branch/master/graph/badge.svg?token=V047CJZ1RU)](https://codecov.io/gh/casvanluijtelaar/resortable_grid)


A resortable grid that allows you to order entries by dragging and dropping them into their desired locations


<p align="center">
  <img src="https://github.com/casvanluijtelaar/resortable_grid/blob/master/assets/example.gif?raw=true" alt="gif showing basic usage" width="600"/>
<p\>

## :hammer: How it works 
`ResortableGridView` is a drop in replacement for the existing `GridView` and adds an `onReorder` callback that provides the original and new index of the reordered item.

``` dart
/// create a new list of data
final items = List.generate(4, (_) => List.generate(10, (j) => j));

/// when the reorder completes remove the list entry from its old position
/// and insert it at its new index
void _onReorder(IndexData oldIndex, IndexData newIndex) {
  setState(() {
    final item = items[oldIndex.group].removeAt(oldIndex.item);
    items[newIndex.group].insert(newIndex.item, item);
  });
}

@override
Widget build(BuildContext context) {
return MaterialApp(
    home: Scaffold(
      body: ResortableGridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 2,
          ),
          onReorder: onReorder,
          itemCount: items.map((i) => i.length).toList(),
          itemBuilder: (context, groupIndex, itemIndex) {
            return Card(
              key: ValueKey('$groupIndex $itemIndex'),
              child: Center(
                child: Text('item $itemIndex in group $groupIndex'),
              ),
            );
          },
        ),
    ),
);
}
```

`ResortableGrid` provides all the constructors and parameters the normal `GridView` has. The package also includes:
  * `ResortableGridView`, which is a prebuild Material-ish implementation of the grid. 
  * `ResortableGrid`, A barebones widget that allows you to customize the grid however you want
  * `SliverResortableGrid`, a resortable grid sliver for custom scroll implementations


## :wave: Get Involved

If this package is useful to you please :thumbsup: on [pub.dev](https://pub.dev/packages/resortable_grid) and :star: on [github](https://github.com/casvanluijtelaar/resortable_grid). If you have any Issues, recommendations or pull requests I'd love to see them!