import 'package:flutter/material.dart';
import 'package:presence_alpha/screen/hr/home_screen.dart';
import 'package:presence_alpha/screen/hr/manage_screen.dart';

class HRNavbarProvider with ChangeNotifier {
  List<NavItem> items = [
    NavItem(
        label: "Home", widget: const HomeScreen(), iconData: Icons.dashboard),
    NavItem(
        label: "Setting",
        widget: const ManageScreen(),
        iconData: Icons.settings),
  ];

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }
}

class NavItem {
  String? label;
  Widget? widget;
  IconData? iconData;

  NavItem({this.label, this.widget, this.iconData});
}
