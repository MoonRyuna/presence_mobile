import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:presence_alpha/screen/home_screen.dart';
import 'package:presence_alpha/screen/profile_screen.dart';

class NavbarProvider with ChangeNotifier {
  List<NavItem> items = [
    NavItem(
        label: "Home", widget: const HomeScreen(), iconData: Ionicons.planet),
    NavItem(
        label: "Profile",
        widget: const ProfileScreen(),
        iconData: Ionicons.construct),
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
