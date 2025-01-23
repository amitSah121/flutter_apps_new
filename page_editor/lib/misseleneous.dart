import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:page_editor/file_funcs.dart';
import 'package:page_editor/model.dart';
import 'package:page_editor/provider.dart';
import 'package:provider/provider.dart';

Future<dynamic> pageNodeCreate(BuildContext context, setState) {
  return showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          alignment: Alignment.center,
          title: const Text("Title"),
          content: TextField(
            controller: controller,
            onSubmitted: (val) async {
              Navigator.pop(context);
              var time = DateTime.now().toString().replaceAll(":", "-");
              var title = "untitled";
              if (val.isNotEmpty) {
                title = val;
              }
              PageNode pageNode = PageNode(
                rows: RowMap(
                  rows: {},
                ),
                metadata:
                    "fileName=$time;title=$title;backgroundColor=${Colors.white.value.toString()}",
              );
              await Future.microtask(() async {
                await getFile("pageNode/$time");
                await writeFile(
                    "pageNode/$time", jsonEncode(pageNode.toJson()));
                final myModel =
                    Provider.of<CustomProvider>(context, listen: false);
                myModel.pageNodes.add(pageNode);
                await Navigator.pushNamed(context, "/pageEditor",
                    arguments: {"node": pageNode, "path": "pageNode/$time"});
                setState(() {});
              });
            },
          ),
        );
      });
}

void moveElement(List list, int currentIndex, int newIndex) {
  if (currentIndex < 0 ||
      currentIndex >= list.length ||
      newIndex < 0 ||
      newIndex >= list.length) {
    // throw RangeError('Indices are out of bounds.');
    return;
  }

  final element = list.removeAt(currentIndex);

  list.insert(newIndex, element);
}