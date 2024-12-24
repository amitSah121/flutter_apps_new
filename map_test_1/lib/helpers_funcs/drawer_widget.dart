import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';

Drawer appDrawer(context) {
    var keys = drawerConstHome.keys.toList();
    return Drawer(
        child: ListView.builder(
            itemCount: keys.length,
            itemBuilder: (ctx, index) {
              return drawerElement(
                  label: keys[index],
                  press: () {
                    drawerElementFuncs(index,context);
                  },
                  icon: Icon(drawerConstHome[keys[index]]));
            }));
  }

  void drawerElementFuncs(index,context) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, "/journey_notes");
        break;
      case 1:
        Navigator.pushNamed(context, "/settings");
        break;
      case 2:
        Navigator.pushNamed(context, "/manualPage");
        break;
    }
  }

  ListTile drawerElement(
      {required label, required VoidCallback press, required icon}) {
    return ListTile(
      leading: icon,
      title: TextButton(
        onPressed: press,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
      ),
    );
  }