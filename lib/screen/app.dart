import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:presence_alpha/provider/navbar_provider.dart';
import 'package:presence_alpha/screen/presence_action_screen.dart';
import 'package:provider/provider.dart';

import 'package:presence_alpha/constant/color_constant.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Konfirmasi'),
              content:
                  const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Tidak'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Ya'),
                ),
              ],
            ),
          ) ??
          false;
    }

    final mp = Provider.of<NavbarProvider>(context);

    return Scaffold(
      body: WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          body: mp.items[mp.selectedIndex].widget,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.lightPrimary,
        onPressed: () {
          //move to PresenceActionScreen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PresenceActionScreen()),
          );
        },
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
