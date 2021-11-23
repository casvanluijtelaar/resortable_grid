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

  void onReorder(ResortableIndex oldIndex, ResortableIndex newIndex) {
    setState(() {
      final item = items[oldIndex.group].removeAt(oldIndex.item);

      if(newIndex.group >= items.length) items.add([item]);
      else items[newIndex.group].insert(newIndex.item, item);
      
      if (items[oldIndex.group].isEmpty) items.removeAt(oldIndex.group);
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
          itemBuilder: (context, index) {
            return Card(
              key: ValueKey('${index.group} ${index.item}'),
              child: Center(
                child: Text('item ${index.group} in group ${index.item}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
