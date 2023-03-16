import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/provider/navbar_provider.dart';
import 'package:provider/provider.dart';

import '../constant/color_constant.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<NavbarProvider>(context);

    return Scaffold(
      body: mp.items[mp.selectedIndex].widget,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.lightPrimary,
        onPressed: () {},
        child: const Icon(
          Icons.fingerprint,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: mp.items
            .map((item) => item.iconData)
            .whereType<IconData>()
            .toList(),
        activeIndex: mp.selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        onTap: (index) => {mp.selectedIndex = index},
        inactiveColor: Colors.grey,
        activeColor: ColorConstant.lightPrimary, //other params
      ),
    );
  }
}
