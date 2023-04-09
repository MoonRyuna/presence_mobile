import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:presence_alpha/constant/api_constant.dart';
import 'package:presence_alpha/provider/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              profileInfo(),
              profileActions(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget profileInfo() {
  return Stack(
    alignment: Alignment.topCenter,
    children: <Widget>[
      SizedBox(
        height: 240.0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              ClipOval(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) => Image.network(
                    userProvider.user?.profilePicture != null
                        ? "${ApiConstant.publicUrl}/${userProvider.user?.profilePicture}"
                        : "https://sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) => Text(
                  userProvider.user?.name ?? "N/A",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Karyawan',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget profileActions() {
  return Column(
    children: <Widget>[
      Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'Ubah Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              log("Ubah Profile");
            },
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.lock),
            title: const Text(
              'Ubah Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              log("Ubah Password");
            },
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              log("Keluar");
            },
          ),
        ),
      ),
    ],
  );
}
