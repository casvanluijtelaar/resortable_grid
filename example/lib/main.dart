import 'package:flutter/material.dart';
import 'package:resortable_grid/resortable_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final items = List.generate(4, (_) => List.generate(10, (j) => j));

  void onReorder(IndexData oldIndex, IndexData newIndex) {
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
}
